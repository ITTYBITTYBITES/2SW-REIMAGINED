extends Node
class_name IrisOnboardingRitual

## The First 60 Seconds — the onboarding sequence for the Sentient Archivist.
##
## Timeline:
##   0.0s — Launch: app boots to darkness. Sub-harmonic hum begins.
##   2.0s — Greeting: the Iris whispers "Witness... are you there?"
##   4.0s — Wake: eyelids peel open (3D animation). Saccadic flick.
##   6.5s — Invitation: pupil dilates. "Touch the light."
##   (idle) — If user hasn't interacted in 15s: "We should start here."
##   (tap)  — Transition: blink-zoom into the pupil → memory.

signal ritual_complete
signal transition_ready  # the pupil is dilated and ready for entry

var _elapsed: float = 0.0
var _active: bool = false
var _phase: int = 0  # 0=dark, 1=greeting, 2=waking, 3=inviting, 4=complete
var _idle_timer: float = 0.0

var _iris_core: IrisCore
var _hub: Iris3DHub
var _voice: IrisVoiceManager
var _soundscape: IrisSoundscape

func configure(core: IrisCore, hub: Iris3DHub, voice: IrisVoiceManager, soundscape: IrisSoundscape) -> void:
	_iris_core = core
	_hub = hub
	_voice = voice
	_soundscape = soundscape

func begin() -> void:
	_active = true
	_elapsed = 0.0
	_phase = 0
	_idle_timer = 0.0
	# Start in darkness — Iris dormant
	if _iris_core:
		_iris_core.transition_to(IrisCore.State.DORMANT)

func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	match _phase:
		0:  # DARKNESS — hum building
			if _elapsed >= 2.0:
				_phase = 1
				_voice.play_bark("greeting")
				if _iris_core:
					_iris_core.transition_to(IrisCore.State.CALIBRATING)
		1:  # GREETING — whisper playing, iris begins to stir
			if _elapsed >= 4.0:
				_phase = 2
				if _iris_core:
					_iris_core.transition_to(IrisCore.State.AWAKENING)
		2:  # WAKING — eyelids peeling open, saccadic flick
			if _elapsed >= 6.5:
				_phase = 3
				_voice.play_bark("touch_light")
				if _iris_core:
					_iris_core.transition_to(IrisCore.State.WELCOMING)
				transition_ready.emit()
		3:  # INVITING — pupil dilated, waiting for touch
			_idle_timer += delta
			if _idle_timer > 15.0 and not _voice.is_speaking():
				_voice.play_bark("start_here")
				_idle_timer = -10.0  # don't repeat immediately
		4:  # COMPLETE
			pass

func on_user_tapped() -> void:
	if _active and _phase >= 3:
		# Begin the blink-zoom transition
		_active = false
		_phase = 4
		ritual_complete.emit()

func is_ready_for_interaction() -> bool:
	return _phase >= 3
