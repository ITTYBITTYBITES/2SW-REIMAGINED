extends Control
class_name MissingSecondExperience

## The Missing Second is one bespoke player experience. It deliberately owns
## only this waiting room, this discrepancy, and this resolution.
enum State { FORMING, OBSERVING, RECONSTRUCTING, INVESTIGATING, RESOLVING, COMPLETE }

signal completion_requested
signal return_requested

@onready var background: TextureRect = $Environment/Background
@onready var traveler: TextureRect = $MemoryActors/Traveler
@onready var clock: MissingSecondClock = $MemoryActors/Clock
@onready var props: MissingSecondProps = $PropsLayer
@onready var tea_choice: Button = $InvestigationLayer/TeaInteraction
@onready var photo_choice: Button = $InvestigationLayer/PhotographInteraction
@onready var suitcase_choice: Button = $InvestigationLayer/SuitcaseInteraction
@onready var entry_line: Label = $PresentationLayer/EntryLine
@onready var prompt: Label = $PresentationLayer/InvestigationPrompt
@onready var object_response: Label = $PresentationLayer/ObjectResponse
@onready var resolution_text: Label = $PresentationLayer/ResolutionText
@onready var return_action: Button = $PresentationLayer/ReturnAction

var state: State = State.FORMING
var state_elapsed := 0.0
var room_time := 0.0
var frozen_clock_angle := -PI * 0.5
var last_tick := -1
var discovery_confirmed := false
var completion_emitted := false
var station_player: AudioStreamPlayer
var tick_player: AudioStreamPlayer
var resolution_player: AudioStreamPlayer

const FORM_SECONDS := 1.25
const OBSERVATION_SECONDS := 2.0
const RESOLUTION_SECONDS := 3.0
const TRAVELER_START := Vector2(275, 326)
const TRAVELER_PAUSE := Vector2(257, 326)
const TRAVELER_EXIT := Vector2(110, 326)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	station_player = _audio_player("res://assets/missing_second/audio/station_room_tone.wav", true)
	tick_player = _audio_player("res://assets/missing_second/audio/clock_tick.wav")
	resolution_player = _audio_player("res://assets/missing_second/audio/resolution_chord.wav")
	tea_choice.pressed.connect(_examine.bind("tea"))
	photo_choice.pressed.connect(_examine.bind("photograph"))
	suitcase_choice.pressed.connect(_examine.bind("suitcase"))
	clock.pressed.connect(_discover_clock)
	return_action.pressed.connect(return_requested.emit)
	_apply_text_style()
	_set_interaction_enabled(false)

func begin() -> void:
	visible = true
	state = State.FORMING
	state_elapsed = 0.0
	room_time = 0.0
	last_tick = -1
	discovery_confirmed = false
	completion_emitted = false
	background.modulate.a = 0.0
	traveler.position = TRAVELER_START
	traveler.modulate.a = 0.0
	clock.frozen = false
	clock.set_highlight(0.0)
	props.set_frozen(false)
	props.set_resolved(false)
	props.set_examined("")
	props.set_photo_revealed(false)
	entry_line.text = "WATCH CAREFULLY. ONE SECOND IS MISSING."
	entry_line.visible = true
	prompt.text = ""
	object_response.text = ""
	resolution_text.text = ""
	return_action.visible = false
	_set_interaction_enabled(false)
	if station_player != null:
		station_player.play()

func close() -> void:
	visible = false
	_set_interaction_enabled(false)
	if station_player != null:
		station_player.stop()

func _process(delta: float) -> void:
	if not visible:
		return
	state_elapsed += delta
	match state:
		State.FORMING:
			var form_amount := clampf(state_elapsed / FORM_SECONDS, 0.0, 1.0)
			background.modulate.a = form_amount
			traveler.modulate.a = form_amount
			props.set_room_time(room_time)
			if form_amount >= 1.0:
				state = State.OBSERVING
				state_elapsed = 0.0
				entry_line.text = "WATCH THE ROOM. DO NOT TOUCH YET."
		State.OBSERVING:
			room_time += delta
			_update_living_room(room_time)
			if state_elapsed >= OBSERVATION_SECONDS:
				_freeze_room()
		State.RECONSTRUCTING:
			if state_elapsed >= 0.55:
				state = State.INVESTIGATING
				state_elapsed = 0.0
				prompt.text = "WHAT MOVED AHEAD OF THE ROOM?"
				_set_interaction_enabled(true)
		State.RESOLVING:
			_update_resolution(state_elapsed)
			if state_elapsed >= RESOLUTION_SECONDS:
				state = State.COMPLETE
				state_elapsed = 0.0
				return_action.visible = true
				return_action.text = "RETURN TO IRIS"
				if not completion_emitted:
					completion_emitted = true
					completion_requested.emit()
	queue_redraw()

func _update_living_room(time_value: float) -> void:
	var traveler_amount := clampf(time_value / OBSERVATION_SECONDS, 0.0, 1.0)
	traveler.position = TRAVELER_START.lerp(TRAVELER_PAUSE, traveler_amount)
	props.set_room_time(time_value)
	var clock_seconds := time_value * 1.35
	if time_value >= 0.95:
		clock_seconds += 1.0
	clock.set_observation_time(clock_seconds)
	var tick_index := floori(clock_seconds)
	if tick_index != last_tick:
		last_tick = tick_index
		if tick_player != null:
			tick_player.play()

func _freeze_room() -> void:
	state = State.RECONSTRUCTING
	state_elapsed = 0.0
	_set_interaction_enabled(false)
	props.set_frozen(true)
	frozen_clock_angle = clock.second_angle
	clock.set_frozen_angle(frozen_clock_angle)
	entry_line.visible = false
	prompt.text = "THE ROOM REMEMBERS DIFFERENTLY."
	object_response.text = ""

func _examine(object_name: String) -> void:
	if state != State.INVESTIGATING:
		return
	props.set_examined(object_name)
	match object_name:
		"tea":
			object_response.text = "THE TEA IS STILL COOLING WHERE THE ROOM LEFT IT."
		"photograph":
			object_response.text = "SOMEONE WILL ARRIVE AFTER THE PLATFORM IS EMPTY."
		"suitcase":
			object_response.text = "THE TRAVELER HAS NOT YET DECIDED TO LEAVE."
	IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Missing Second Examination")

func _discover_clock() -> void:
	if state != State.INVESTIGATING or discovery_confirmed:
		return
	discovery_confirmed = true
	_set_interaction_enabled(false)
	clock.set_highlight(1.0)
	prompt.text = "THE CLOCK ARRIVED BEFORE THE MOMENT DID."
	object_response.text = ""
	state = State.RESOLVING
	state_elapsed = 0.0
	if tick_player != null:
		tick_player.play()
	IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.SUCCESS, "Missing Second Discovery")

func _update_resolution(time_value: float) -> void:
	var amount := clampf(time_value / RESOLUTION_SECONDS, 0.0, 1.0)
	clock.second_angle = lerpf(frozen_clock_angle, -PI * 0.5 + OBSERVATION_SECONDS * 1.35 * TAU / 60.0, amount)
	clock.queue_redraw()
	props.set_frozen(false)
	props.set_resolved(true)
	props.set_room_time(room_time + time_value)
	if amount >= 0.28:
		props.set_photo_revealed(true)
		traveler.position = TRAVELER_PAUSE.lerp(TRAVELER_EXIT, clampf((amount - 0.28) / 0.72, 0.0, 1.0))
	if amount >= 0.58 and resolution_text.text.is_empty():
		resolution_text.text = "THE MISSING SECOND WAS A CHOICE TO BE REMEMBERED.\n\nTHE TRAVELER STAYED LONG ENOUGH TO LEAVE A PHOTOGRAPH FOR SOMEONE ARRIVING AFTER THEM."
		if resolution_player != null:
			resolution_player.play()

func _set_interaction_enabled(enabled: bool) -> void:
	for target in [tea_choice, photo_choice, suitcase_choice, clock]:
		target.visible = enabled
		target.disabled = not enabled
		target.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

func _audio_player(path: String, loop := false) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream = load(path)
	if stream is AudioStreamWAV and loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	player.stream = stream
	player.bus = "Master"
	add_child(player)
	return player

func _apply_text_style() -> void:
	for label in [entry_line, prompt, object_response, resolution_text]:
		label.add_theme_font_size_override("font_size", 14 if label != resolution_text else 17)
		label.add_theme_color_override("font_color", Color("#ecf8f2"))
	return_action.add_theme_font_size_override("font_size", 14)
	return_action.add_theme_color_override("font_color", Color("#f3fff9"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#286e61")
	normal.corner_radius_top_left = 9
	normal.corner_radius_top_right = 9
	normal.corner_radius_bottom_left = 9
	normal.corner_radius_bottom_right = 9
	return_action.add_theme_stylebox_override("normal", normal)
