extends Control
class_name TutorialAwakeningScreen

# Mini Witness Moment (Scene 3 of The Awakening Tutorial)
# A tiny 10-second memory where the player answers one simple question without
# pop-up arrows or arcade jingles, discovering: "The smallest detail can change the whole story."

signal request_return_to_iris

@onready var background: TextureRect = $Background
@onready var reflection_highlight: ColorRect = $Background/ReflectionHighlight
@onready var question_container: Control = $QuestionContainer
@onready var question_title: Label = $QuestionContainer/QuestionTitle
@onready var option_1: Button = $QuestionContainer/VBox/Option1
@onready var option_2: Button = $QuestionContainer/VBox/Option2
@onready var option_3: Button = $QuestionContainer/VBox/Option3
@onready var lesson_label: Label = $LessonLabel

var elapsed := 0.0
var active := false
var question_presented := false
var lesson_completed := false
var sound_service: ProceduralIrisSound = null
var voice_guide_ref: VoiceGuide = null

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    if is_instance_valid(question_container):
        question_container.modulate.a = 0.0
        question_container.visible = false
    if is_instance_valid(reflection_highlight):
        reflection_highlight.modulate.a = 0.0
    if is_instance_valid(lesson_label):
        lesson_label.modulate.a = 0.0
    if is_instance_valid(option_1): option_1.pressed.connect(_on_option_selected.bind(1))
    if is_instance_valid(option_2): option_2.pressed.connect(_on_option_selected.bind(2))
    if is_instance_valid(option_3): option_3.pressed.connect(_on_option_selected.bind(3))

func set_sensory_services(s: ProceduralIrisSound, v: VoiceGuide) -> void:
    sound_service = s
    voice_guide_ref = v

func enter() -> void:
    active = true
    elapsed = 0.0
    question_presented = false
    lesson_completed = false
    if is_instance_valid(question_container):
        question_container.modulate.a = 0.0
        question_container.visible = false
    if is_instance_valid(reflection_highlight):
        reflection_highlight.modulate.a = 0.0
    if is_instance_valid(lesson_label):
        lesson_label.modulate.a = 0.0
    
    # 2-second initial observation flash
    if is_instance_valid(sound_service):
        sound_service.focus_notice_tone()

func _process(delta: float) -> void:
    if not active:
        return
    elapsed += delta
    if not question_presented and elapsed >= 2.4:
        _present_question()
    
    if question_presented and not lesson_completed and is_instance_valid(question_container):
        question_container.modulate.a = lerpf(question_container.modulate.a, 1.0, minf(1.0, delta * 4.0))

func _present_question() -> void:
    question_presented = true
    if is_instance_valid(question_container):
        question_container.visible = true
        question_container.modulate.a = 0.0

func _on_option_selected(option_idx: int) -> void:
    if lesson_completed:
        return
    if option_idx == 3:
        # Correct answer: The reflection shifted
        lesson_completed = true
        if is_instance_valid(sound_service):
            sound_service.reflection_tone()
        if is_instance_valid(voice_guide_ref):
            voice_guide_ref.trigger_iris_expression("NEW_PLAYER", "tutorial_lesson")
        
        # Reveal the hidden optical reflection and lesson text
        var tween := create_tween()
        if is_instance_valid(question_container):
            tween.tween_property(question_container, "modulate:a", 0.0, 0.4)
            tween.tween_callback(func(): question_container.visible = false)
        if is_instance_valid(reflection_highlight):
            tween.tween_property(reflection_highlight, "modulate:a", 0.75, 0.6)
        if is_instance_valid(lesson_label):
            lesson_label.text = "THE SMALLEST DETAIL CAN CHANGE THE WHOLE STORY"
            tween.tween_property(lesson_label, "modulate:a", 1.0, 0.8)
        
        # After 3.6 seconds, return to the Living Iris (Scene 4)
        get_tree().create_timer(3.8).timeout.connect(_complete_and_return)
    else:
        # Gentle guidance without penalty
        if is_instance_valid(sound_service):
            sound_service.focus_notice_tone()
        if option_idx == 1 and is_instance_valid(option_1):
            option_1.modulate.a = 0.35
        elif option_idx == 2 and is_instance_valid(option_2):
            option_2.modulate.a = 0.35

func _complete_and_return() -> void:
    active = false
    request_return_to_iris.emit()
