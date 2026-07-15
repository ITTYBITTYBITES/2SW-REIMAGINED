extends Node
## AudioService - Centralized audio management
## Supports BGM, SFX, UI sounds, per-bus volume, mute states
## Designed to be extendable with AudioStreamPlayers pooled

signal volume_changed(bus: String, volume_db: float, linear: float)
signal bus_muted(bus: String, muted: bool)
signal sound_played(sound_id: String, bus: String)

## Minimum linear volume to avoid -inf dB (which causes NaN errors)
const MIN_LINEAR_VOLUME: float = 0.0001
## Minimum dB value for volume_db (effectively silent)
const MIN_VOLUME_DB: float = -80.0

## Converts linear volume (0.0-1.0) to decibels, clamping to avoid -inf/NaN.
static func linear_to_db(linear: float) -> float:
	if is_nan(linear) or is_inf(linear) or linear <= 0.0:
		return MIN_VOLUME_DB
	var safe_linear: float = clampf(linear, MIN_LINEAR_VOLUME, 1.0)
	var db: float = 20.0 * (log(safe_linear) / log(10.0))
	if is_nan(db) or is_inf(db):
		return MIN_VOLUME_DB
	return clampf(db, MIN_VOLUME_DB, 0.0)

static func _sanitize_linear_volume(value: Variant, fallback: float = 1.0) -> float:
	var safe_value: float = fallback
	var value_type: int = typeof(value)
	if value_type == TYPE_FLOAT or value_type == TYPE_INT:
		safe_value = float(value)
	elif value_type == TYPE_STRING:
		safe_value = str(value).to_float()
	if is_nan(safe_value) or is_inf(safe_value):
		safe_value = fallback
	if is_nan(safe_value) or is_inf(safe_value):
		safe_value = 1.0
	return clampf(safe_value, 0.0, 1.0)

static func _sanitize_db(value: float, fallback: float = MIN_VOLUME_DB) -> float:
	var safe_value: float = fallback if is_nan(value) or is_inf(value) else value
	return clampf(safe_value, MIN_VOLUME_DB, 24.0)

static func _safe_linear_db(linear: Variant, fallback: float = MIN_VOLUME_DB) -> float:
	var safe_linear: float = _sanitize_linear_volume(linear, MIN_LINEAR_VOLUME)
	return _sanitize_db(linear_to_db(safe_linear), fallback)

static func _sanitize_duration(seconds: float, fallback: float = 0.05) -> float:
	if is_nan(seconds) or is_inf(seconds) or seconds <= 0.0:
		return fallback
	return maxf(0.05, seconds)

enum Bus { MASTER, BGM, SFX, UI }

const BUS_NAMES := {
	Bus.MASTER: "Master",
	Bus.BGM: "BGM",
	Bus.SFX: "SFX",
	Bus.UI: "UI"
}

var _bgm_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _ui_player: AudioStreamPlayer
var _stream_cache: Dictionary = {}
var _initialized: bool = false

const PACKAGED_SOUND_IDS: Array[String] = [
	"ui_click", "ui_hover", "ui_back", "ui_navigate",
	"ui_success", "ui_failure", "ui_unlock", "ui_achievement",
	"observation_start", "flash_pulse", "flash_pulse_short",
	"conceal", "flash_interval", "flash_reveal_click",
	"flash_correct", "flash_incorrect",
	"reveal_correct", "reveal_incorrect",
	"object_settle", "pattern_step", "difference_switch",
	"result_settle", "mastery_up"
]

const BGM_TRACKS := {
	"publisher": "bgm_publisher",
	"home": "bgm_home",
	"gameplay": "bgm_gameplay",
	"results": "bgm_results",
	"tutorial": "bgm_tutorial"
}

const SCENE_BGM: Dictionary = {
	"publisher_splash": "publisher",
	"title_splash": "publisher",
	"home": "home",
	"tutorial": "tutorial",
	"observation": "gameplay",
	"memory_question": "gameplay",
	"result": "results",
	"profile": "home",
	"settings": "home",
	"about": "home",
	"programs": "home",
	"achievements": "home",
	"experiences": "home"
}

const BGM_PLAYBACK_GAIN: float = 0.58

const SOUND_GAINS: Dictionary = {
	"ui_click": 0.55,
	"ui_hover": 0.32,
	"ui_back": 0.52,
	"ui_navigate": 0.58,
	"ui_success": 0.70,
	"ui_failure": 0.66,
	"ui_unlock": 0.78,
	"ui_achievement": 0.82,
	"observation_start": 0.82,
	"flash_pulse": 0.58,
	"flash_pulse_short": 0.46,
	"conceal": 0.70,
	"flash_interval": 0.44,
	"flash_reveal_click": 0.58,
	"flash_correct": 0.88,
	"flash_incorrect": 0.78,
	"reveal_correct": 0.92,
	"reveal_incorrect": 0.82,
	"object_settle": 0.48,
	"pattern_step": 0.50,
	"difference_switch": 0.54,
	"result_settle": 0.78,
	"mastery_up": 0.86
}

var _volumes: Dictionary = {
	"Master": 0.95,
	"BGM": 0.62,
	"SFX": 0.78,
	"UI": 0.58
}

var _muted: Dictionary = {
	"Master": false,
	"BGM": false,
	"SFX": false,
	"UI": false
}

func _ready() -> void:
	EventBus.audio_requested.connect(_on_audio_requested)

func initialize() -> void:
	if _initialized:
		return

	# Create audio buses if not present (gl_compatibility still supports buses)
	_ensure_buses()

	# Create players
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = BUS_NAMES[Bus.BGM]
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)

	_ui_player = AudioStreamPlayer.new()
	_ui_player.bus = BUS_NAMES[Bus.UI]
	_ui_player.name = "UIPlayer"
	add_child(_ui_player)

	# SFX pool of 6 players
	for i in range(6):
		var p := AudioStreamPlayer.new()
		p.bus = BUS_NAMES[Bus.SFX]
		p.name = "SFXPool_%d" % i
		add_child(p)
		_sfx_pool.append(p)

	# Load settings
	if SettingsService:
		_volumes["Master"] = _sanitize_linear_volume(SettingsService.get_value("volume_master", 0.95), 0.95)
		_volumes["BGM"] = _sanitize_linear_volume(SettingsService.get_value("volume_bgm", 0.62), 0.62)
		_volumes["SFX"] = _sanitize_linear_volume(SettingsService.get_value("volume_sfx", 0.78), 0.78)
		_volumes["UI"] = _sanitize_linear_volume(SettingsService.get_value("volume_ui", 0.58), 0.58)
		_muted["Master"] = SettingsService.get_value("mute_master", false)
		_muted["BGM"] = SettingsService.get_value("mute_bgm", false)
		_muted["SFX"] = SettingsService.get_value("mute_sfx", false)
		_muted["UI"] = SettingsService.get_value("mute_ui", false)

	_apply_all_volumes()
	_preload_packaged_sounds()
	if SettingsService and not SettingsService.setting_changed.is_connected(_on_setting_changed):
		SettingsService.setting_changed.connect(_on_setting_changed)

	_initialized = true

func _ensure_buses() -> void:
	# Create custom buses via AudioServer if not exist
	var needed := ["BGM", "SFX", "UI"]
	for n in needed:
		var idx := AudioServer.get_bus_index(n)
		if idx == -1:
			AudioServer.add_bus()
			var new_idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(new_idx, n)
			AudioServer.set_bus_send(new_idx, "Master")

func play_ui(sound_id: String, volume_linear: float = 1.0) -> void:
	play_sound(sound_id, Bus.UI, volume_linear)

func play_sfx(sound_id: String, volume_linear: float = 1.0) -> void:
	play_sound(sound_id, Bus.SFX, volume_linear)

func play_bgm(sound_id: String, loop: bool = true, _fade_duration: float = 0.5) -> void:
	play_sound(sound_id, Bus.BGM, 1.0, loop)

var _active_bgm_track: String = ""
var _duck_target_db: float = 0.0
var _duck_tween: Tween = null

func play_bgm_track(track_key: String, fade_seconds: float = 0.45) -> void:
	if not BGM_TRACKS.has(track_key):
		return
	var sound_id: String = BGM_TRACKS[track_key]
	if _active_bgm_track == sound_id and _bgm_player and _bgm_player.playing:
		return
	_active_bgm_track = sound_id
	if not _initialized or _muted.get("BGM", false) or _muted.get("Master", false):
		return
	var stream: AudioStream = _get_stream_for_id(sound_id)
	if stream == null:
		return
	_fade_bgm(stream, fade_seconds)

func _fade_bgm(stream: AudioStream, fade_seconds: float) -> void:
	if not _bgm_player:
		return
	_prepare_stream_for_loop(stream, true)
	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.volume_db = _safe_linear_db(0.0)
	_bgm_player.play()
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var target_linear: float = _sanitize_linear_volume(_volumes.get("BGM", 0.62), 0.62) * BGM_PLAYBACK_GAIN
	tween.tween_property(_bgm_player, "volume_db", _sanitize_db(linear_to_db(target_linear), MIN_VOLUME_DB), _sanitize_duration(fade_seconds)).set_ease(Tween.EASE_OUT)

func duck_bgm(amount_db: float = -8.0, fade_seconds: float = 0.15) -> void:
	if not _bgm_player or not _bgm_player.playing:
		return
	if _duck_tween and _duck_tween.is_valid():
		_duck_tween.kill()
	_duck_target_db = _sanitize_db(amount_db, -8.0)
	_duck_tween = create_tween()
	_duck_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var current_db: float = _sanitize_db(_bgm_player.volume_db, linear_to_db(_sanitize_linear_volume(_volumes.get("BGM", 0.62), 0.62) * BGM_PLAYBACK_GAIN))
	var ducked_db: float = _sanitize_db(current_db + _duck_target_db, -40.0)
	_duck_tween.tween_property(_bgm_player, "volume_db", maxf(ducked_db, -40.0), _sanitize_duration(fade_seconds)).set_ease(Tween.EASE_OUT)

func unduck_bgm(fade_seconds: float = 0.25) -> void:
	if not _bgm_player or not _bgm_player.playing:
		return
	if _duck_tween and _duck_tween.is_valid():
		_duck_tween.kill()
	var target_linear: float = _sanitize_linear_volume(_volumes.get("BGM", 0.62), 0.62) * BGM_PLAYBACK_GAIN
	_duck_tween = create_tween()
	_duck_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_duck_tween.tween_property(_bgm_player, "volume_db", _sanitize_db(linear_to_db(target_linear), MIN_VOLUME_DB), _sanitize_duration(fade_seconds)).set_ease(Tween.EASE_OUT)

func stop_bgm_track(fade_seconds: float = 0.4) -> void:
	if not _bgm_player or not _bgm_player.playing:
		_active_bgm_track = ""
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_bgm_player, "volume_db", _safe_linear_db(0.0), _sanitize_duration(fade_seconds)).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		if _bgm_player:
			_bgm_player.stop()
		_active_bgm_track = ""
	)

func play_sound(
	sound_id: String,
	bus: int = Bus.SFX,
	volume_linear: float = 1.0,
	_loop: bool = false
) -> void:
	if not _initialized:
		return
	var bus_name: String = BUS_NAMES[bus]
	if _muted.get(bus_name, false) or _muted.get("Master", false):
		return

	var stream: AudioStream = _get_stream_for_id(sound_id)
	if stream == null:
		return

	var input_volume: float = _sanitize_linear_volume(volume_linear, 1.0)
	var sound_gain: float = _sanitize_linear_volume(SOUND_GAINS.get(sound_id, 1.0), 1.0)
	var bus_volume: float = _sanitize_linear_volume(_volumes.get(bus_name, 1.0), 1.0)
	var normalized_volume: float = clampf(input_volume * sound_gain, 0.0, 1.0)
	match bus:
		Bus.BGM:
			_prepare_stream_for_loop(stream, _loop)
			_bgm_player.stream = stream
			_bgm_player.volume_db = _sanitize_db(linear_to_db(normalized_volume * bus_volume * BGM_PLAYBACK_GAIN), MIN_VOLUME_DB)
			_bgm_player.play()
		Bus.UI:
			_prepare_stream_for_loop(stream, false)
			_ui_player.stream = stream
			_ui_player.volume_db = _sanitize_db(linear_to_db(normalized_volume * bus_volume), MIN_VOLUME_DB)
			_ui_player.play()
		_:
			# Find free player in pool
			var player: AudioStreamPlayer = _get_free_sfx_player()
			if player:
				_prepare_stream_for_loop(stream, false)
				player.stream = stream
				player.volume_db = _sanitize_db(linear_to_db(normalized_volume * bus_volume), MIN_VOLUME_DB)
				player.play()

	sound_played.emit(sound_id, bus_name)

func _get_free_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	# If all busy, return first (steal)
	return _sfx_pool[0] if _sfx_pool.size() > 0 else null

func _prepare_stream_for_loop(stream: AudioStream, should_loop: bool) -> void:
	if stream == null:
		return
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD if should_loop else AudioStreamWAV.LOOP_DISABLED
	elif stream is AudioStreamOggVorbis:
		var ogg := stream as AudioStreamOggVorbis
		ogg.loop = should_loop

func _preload_packaged_sounds() -> void:
	_stream_cache.clear()
	for sound_id: String in PACKAGED_SOUND_IDS:
		var stream := _load_stream(sound_id)
		if stream != null:
			_stream_cache[sound_id] = stream

func _get_stream_for_id(sound_id: String) -> AudioStream:
	if _stream_cache.has(sound_id):
		return _stream_cache[sound_id] as AudioStream
	var stream := _load_stream(sound_id)
	if stream != null:
		_stream_cache[sound_id] = stream
	return stream

func _load_stream(sound_id: String) -> AudioStream:
	for path: String in [
		"res://assets/audio/%s.wav" % sound_id,
		"res://assets/audio/%s.ogg" % sound_id
	]:
		if ResourceLoader.exists(path):
			return load(path) as AudioStream
	return null

func set_volume(bus: int, linear: Variant) -> void:
	var bus_name: String = BUS_NAMES[bus]
	var safe_linear: float = _sanitize_linear_volume(linear, _sanitize_linear_volume(_volumes.get(bus_name, 1.0), 1.0))
	_volumes[bus_name] = safe_linear
	var safe_db: float = linear_to_db(safe_linear)
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, safe_db)
	volume_changed.emit(bus_name, safe_db, safe_linear)
	if SettingsService:
		SettingsService.set_value("volume_%s" % bus_name.to_lower(), safe_linear)

func get_volume(bus: int) -> float:
	return _sanitize_linear_volume(_volumes.get(BUS_NAMES[bus], 1.0), 1.0)

func set_muted(bus: int, muted: bool) -> void:
	var bus_name: String = BUS_NAMES[bus]
	_muted[bus_name] = muted
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		AudioServer.set_bus_mute(bus_idx, muted)
	bus_muted.emit(bus_name, muted)
	if SettingsService:
		SettingsService.set_value("mute_%s" % bus_name.to_lower(), muted)

func is_muted(bus: int) -> bool:
	return _muted.get(BUS_NAMES[bus], false)

func _apply_all_volumes() -> void:
	for b in BUS_NAMES.values():
		var bus_name: String = str(b)
		var idx: int = AudioServer.get_bus_index(bus_name)
		if idx != -1:
			var safe_linear: float = _sanitize_linear_volume(_volumes.get(bus_name, 1.0), 1.0)
			_volumes[bus_name] = safe_linear
			AudioServer.set_bus_volume_db(idx, linear_to_db(safe_linear))
			AudioServer.set_bus_mute(idx, _muted.get(bus_name, false))

func _on_setting_changed(key: String, value: Variant) -> void:
	match key:
		"volume_master": set_volume(Bus.MASTER, value)
		"volume_bgm": set_volume(Bus.BGM, value)
		"volume_sfx": set_volume(Bus.SFX, value)
		"volume_ui": set_volume(Bus.UI, value)
		"mute_master": set_muted(Bus.MASTER, bool(value))
		"mute_bgm": set_muted(Bus.BGM, bool(value))
		"mute_sfx": set_muted(Bus.SFX, bool(value))
		"mute_ui": set_muted(Bus.UI, bool(value))

func stop_bgm(_fade_duration: float = 0.3) -> void:
	if _bgm_player and _bgm_player.playing:
		_bgm_player.stop()

func stop_all() -> void:
	if is_instance_valid(_bgm_player):
		_bgm_player.stop()
		_bgm_player.stream = null
	if is_instance_valid(_ui_player):
		_ui_player.stop()
		_ui_player.stream = null
	for player: AudioStreamPlayer in _sfx_pool:
		if is_instance_valid(player):
			player.stop()
			player.stream = null

func _exit_tree() -> void:
	stop_all()
	_stream_cache.clear()

func _on_audio_requested(bus: String, sound_id: String, params: Dictionary) -> void:
	var b: int = Bus.SFX
	match bus.to_lower():
		"bgm": b = Bus.BGM
		"ui": b = Bus.UI
		"sfx": b = Bus.SFX
		"master": b = Bus.MASTER
	play_sound(sound_id, b, params.get("volume", 1.0))
