extends Control
class_name WitnessMomentPhase

## Base class for all Witness Moment phases.
## Provides common theming, transitions, and Iris voice integration.

signal phase_completed(phase_name: String, data: Dictionary)
signal phase_failed(reason: String)

@onready var background: ColorRect = $Background

var moment_definition: WitnessMoment = null
var phase_name: String = ""
var _should_animate: bool = true

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _setup_background()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _on_viewport_resized(get_viewport_rect().size)

func _on_viewport_resized(_size: Vector2) -> void:
    ## Override in subclasses to handle resize
    pass

func _setup_background() -> void:
    if background:
        background.color = Color("#07131A")
    else:
        var bg: ColorRect = ColorRect.new()
        bg.name = "Background"
        bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        bg.color = Color("#07131A")
        bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(bg)
        background = bg
        move_child(bg, 0)

func configure(definition: WitnessMoment) -> void:
    moment_definition = definition
    _apply_theme()
    _on_configure()

func _apply_theme() -> void:
    if ThemeService:
        var tokens: Dictionary = ThemeService.tokens
        if background and not tokens.is_empty():
            background.color = tokens.get("background", Color("#07131A"))

func _on_configure() -> void:
    ## Override in subclasses
    pass

func begin() -> void:
    _on_begin()
    _animate_in()

func _on_begin() -> void:
    ## Override in subclasses
    pass

func _animate_in(duration: float = 0.4) -> void:
    if not _should_animate or not AccessibilityService.should_animate():
        modulate.a = 1.0
        return
    modulate.a = 0.0
    var tween: Tween = create_tween()
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.tween_property(self, "modulate:a", 1.0, duration).set_ease(Tween.EASE_OUT)

func _animate_out(duration: float = 0.3, callback: Callable = Callable()) -> void:
    if not _should_animate or not AccessibilityService.should_animate():
        if callback and callback.is_valid():
            callback.call()
        return
    var tween: Tween = create_tween()
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.tween_property(self, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
    if callback and callback.is_valid():
        tween.finished.connect(callback)

func complete(data: Dictionary = {}) -> void:
    _animate_out(0.25, Callable(self, "_emit_completed").bind(data))

func _emit_completed(data: Dictionary) -> void:
    phase_completed.emit(phase_name, data)
    queue_free()

func fail(reason: String) -> void:
    phase_failed.emit(reason)
    queue_free()

func _play_sfx(sfx_name: String, volume: float = 0.7) -> void:
    if AudioService:
        AudioService.play_sfx(sfx_name, volume)

func _vibrate(duration_ms: int) -> void:
    if AccessibilityService and AccessibilityService.is_haptics_enabled():
        AccessibilityService.vibrate(duration_ms)

func _speak(text: String, language: String = "en") -> void:
    var tree: SceneTree = get_tree()
    if tree and tree.root:
        var guide_node: Node = tree.root.get_node_or_null("Main/Interface/VoiceGuide")
        if guide_node and guide_node.has_method("speak_text"):
            guide_node.call("speak_text", text, language)
            return
    if VoiceGuide:
        VoiceGuide.speak(text, language)