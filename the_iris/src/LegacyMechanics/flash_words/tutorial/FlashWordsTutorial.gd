extends Control
## Family-owned interactive Flash Words tutorial.

signal completed(family_id: String, tutorial_version: String)
signal skipped(family_id: String, tutorial_version: String)
signal practice_requested(family_id: String, template_id: String)

const FAMILY_ID: String = "flash_words"
const TUTORIAL_VERSION: String = "1"
const PRACTICE_TEMPLATE: String = "single_word_v1"

var _step: int = 0
var _answered: bool = false
var _title: Label
var _word: Label
var _description: Label
var _answers: VBoxContainer
var _next: Button
var _comfort: CheckButton
var _margin: MarginContainer

func _ready() -> void:
	_build_ui()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	_update_step()

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin(_margin, 28.0)

func configure(_family: ChallengeFamily, _profile: TutorialProfile) -> void:
	reset_tutorial()

func reset_tutorial() -> void:
	_step = 0
	_answered = false
	if is_inside_tree():
		_update_step()

func _build_ui() -> void:
	if _title:
		return
	var background := ColorRect.new()
	background.color = ThemeService.get_color("background", Color("#0F0F12")) if ThemeService else Color("#0F0F12")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_margin = MarginContainer.new()
	_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margin.add_theme_constant_override("margin_left", 28)
	_margin.add_theme_constant_override("margin_right", 28)
	_margin.add_theme_constant_override("margin_top", 32)
	_margin.add_theme_constant_override("margin_bottom", 28)
	add_child(_margin)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_margin.add_child(scroll)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 22)
	scroll.add_child(stack)
	var brand := Label.new()
	brand.text = "TWO SECOND WITNESS"
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_theme_color_override("font_color", ThemeService.get_color("text_tertiary", Color("#8A8AA3")) if ThemeService else Color("#8A8AA3"))
	brand.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(16) if ThemeService else 16)
	stack.add_child(brand)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_color_override("font_color", ThemeService.get_color("text_primary", Color("#F5F3FA")) if ThemeService else Color("#F5F3FA"))
	_title.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(42) if ThemeService else 42)
	stack.add_child(_title)
	_word = Label.new()
	_word.custom_minimum_size = Vector2(0, 190)
	_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_word.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_word.add_theme_color_override("font_color", ThemeService.get_color("text_primary", Color("#F5F3FA")) if ThemeService else Color("#F5F3FA"))
	_word.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(112) if ThemeService else 112)
	stack.add_child(_word)
	_description = Label.new()
	_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description.add_theme_color_override("font_color", ThemeService.get_color("text_secondary", Color("#B8B8CC")) if ThemeService else Color("#B8B8CC"))
	_description.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(20) if ThemeService else 20)
	stack.add_child(_description)
	_answers = VBoxContainer.new()
	_answers.add_theme_constant_override("separation", 8)
	stack.add_child(_answers)
	_comfort = CheckButton.new()
	_comfort.text = "Reading Comfort Mode"
	_comfort.button_pressed = bool(SettingsService.get_value("reading_comfort_mode", false)) if SettingsService else false
	_comfort.toggled.connect(_on_comfort_toggled)
	stack.add_child(_comfort)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(spacer)
	_next = Button.new()
	_next.custom_minimum_size = Vector2(0, 72)
	_next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_next.pressed.connect(_on_next)
	stack.add_child(_next)
	var skip := Button.new()
	skip.text = "Skip Tutorial"
	skip.flat = true
	skip.pressed.connect(_finish.bind(true))
	stack.add_child(skip)

func _update_step() -> void:
	_clear_answers()
	_comfort.visible = false
	_next.visible = true
	match _step:
		0:
			_title.text = "FLASH WORDS"
			_word.text = "FOCUS"
			_description.text = "A word flashes, disappears, and then you choose exactly what appeared."
			_next.text = "SHOW ME  →"
		1:
			_title.text = "CATCH THE SIGNAL"
			_word.text = "GARDEN"
			_description.text = "This demonstration is untimed. Look at the whole word, not just the first letter."
			_next.text = "I'M READY  →"
			_play("flash_pulse")
		2:
			_title.text = "WHICH WORD?"
			_word.text = ""
			_description.text = "Choose the word you just saw."
			_next.visible = false
			_add_answer("GARDEN")
			_add_answer("HARDEN")
		3:
			_title.text = "SEE THE DIFFERENCE"
			_word.text = "GARDEN"
			_description.text = "You selected: %s\nCorrect: GARDEN\nDifference: %s" % ["GARDEN" if _answered else "—", "Exact match" if _answered else "Compare the letters"]
			_next.text = "SHOW A PAIR  →"
		4:
			_title.text = "ORDER MATTERS"
			_word.text = "LIGHT  →  RIVER"
			_description.text = "Some rounds show two words or a short stream. Remember both the words and their order."
			_next.text = "ONE LAST STEP  →"
			_play("flash_pulse")
		_:
			_title.text = "YOUR TURN"
			_word.text = "READY"
			_description.text = "Reading Comfort Mode adds space and time without reducing your progress."
			_comfort.visible = true
			_next.text = "START PRACTICE"

func _add_answer(text: String) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 56)
	button.pressed.connect(_on_demo_answer.bind(text))
	_answers.add_child(button)

func _clear_answers() -> void:
	for child: Node in _answers.get_children():
		child.queue_free()

func _on_demo_answer(answer: String) -> void:
	if _answered:
		return
	_answered = true
	_play("flash_reveal_click")
	_step = 3
	_update_step()
	_description.text = "You selected: %s\nCorrect: GARDEN\nDifference: %s" % [answer, "Exact match" if answer == "GARDEN" else "Position 1: H → G"]

func _on_next() -> void:
	if _step >= 5:
		_finish(false)
		return
	_step += 1
	_update_step()

func _on_comfort_toggled(enabled: bool) -> void:
	if SettingsService:
		SettingsService.set_value("reading_comfort_mode", enabled)

func _finish(was_skipped: bool) -> void:
	if was_skipped:
		skipped.emit(FAMILY_ID, TUTORIAL_VERSION)
	else:
		completed.emit(FAMILY_ID, TUTORIAL_VERSION)
	practice_requested.emit(FAMILY_ID, PRACTICE_TEMPLATE)

func _play(sound_id: String) -> void:
	if AudioService:
		AudioService.play_sfx(sound_id, 0.55)
