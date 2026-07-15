extends Control
## Production credits, privacy, version, and open-source notices.

const PRIVACY_POLICY_URL := "https://ittybittybites.github.io/two-second-witness/privacy"
const PUBLISHER_URL := "https://ittybittybites.github.io/"

@onready var title_label: Label = $Margin/Scroll/VBox/Title
@onready var brand_label: Label = $Margin/Scroll/VBox/BrandSection/BrandTitle
@onready var privacy_btn: Button = $Margin/Scroll/VBox/PrivacySection/PrivacyButton
@onready var website_btn: Button = $Margin/Scroll/VBox/BrandSection/WebsiteButton
@onready var back_btn: Button = $Margin/Scroll/VBox/BackButton
@onready var version_label: Label = $Margin/Scroll/VBox/VersionInfo
@onready var scroll: ScrollContainer = $Margin/Scroll

func _ready() -> void:
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_ensure_wired()
	_update_version_copy()
	_apply_theme()

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($Margin)

func _update_version_copy() -> void:
	if version_label:
		var version := str(ConfigService.get_value("app_version", "4.0.0")) if ConfigService else "4.0.0"
		version_label.text = "Version %s\nPackage: com.ittybittybites.the2secondwitness\n© 2026 ITTYBITTYBITES" % version

func _ensure_wired() -> void:
	if has_node("Margin/Scroll/VBox/PrivacySection/PrivacyButton"):
		var btn = $Margin/Scroll/VBox/PrivacySection/PrivacyButton
		if not btn.pressed.is_connected(_on_privacy):
			btn.pressed.connect(_on_privacy)
	if has_node("Margin/Scroll/VBox/BrandSection/WebsiteButton"):
		var wb = $Margin/Scroll/VBox/BrandSection/WebsiteButton
		if not wb.pressed.is_connected(_on_website):
			wb.pressed.connect(_on_website)
	if has_node("Margin/Scroll/VBox/BackButton"):
		var back = $Margin/Scroll/VBox/BackButton
		if not back.pressed.is_connected(_on_back):
			back.pressed.connect(_on_back)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	# Apply theme to labels
	if title_label:
		ThemeService.apply_label_style(title_label, "headline", "primary")
	if brand_label:
		ThemeService.apply_label_style(brand_label, "title", "primary")
	for path: String in [
		"Margin/Scroll/VBox/BrandSection/BrandDesc",
		"Margin/Scroll/VBox/AboutDesc",
		"Margin/Scroll/VBox/PrivacySection/PrivacyDesc",
		"Margin/Scroll/VBox/CreditsSection/CreditsDesc",
		"Margin/Scroll/VBox/CreditsSection/LicenseDesc",
		"Margin/Scroll/VBox/VersionInfo"
	]:
		ThemeService.apply_label_style(get_node(path) as Label, "body_small", "text_secondary")
	ThemeService.apply_label_style(
		$Margin/Scroll/VBox/PrivacySection/PrivacyTitle,
		"title",
		"primary"
	)
	for title_path: String in [
		"Margin/Scroll/VBox/AboutTitle",
		"Margin/Scroll/VBox/CreditsSection/CreditsTitle",
		"Margin/Scroll/VBox/CreditsSection/LicenseTitle"
	]:
		if has_node(title_path):
			ThemeService.apply_label_style(get_node(title_path) as Label, "title", "primary")
	# Style buttons
	for btn in [privacy_btn, website_btn, back_btn]:
		if btn:
			ThemeService.apply_typography(btn, "button")
			btn.custom_minimum_size.y = max(btn.custom_minimum_size.y, tokens.get("touch_target_min", 48))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _on_privacy() -> void:
	_play_feedback()
	if OS.shell_open(PRIVACY_POLICY_URL) != OK and ErrorHandler:
		ErrorHandler.handle("PRIVACY_LINK_FAILED", "The privacy policy link could not be opened.", {}, ErrorHandler.Severity.ERROR)

func _on_website() -> void:
	_play_feedback()
	if OS.shell_open(PUBLISHER_URL) != OK and ErrorHandler:
		ErrorHandler.handle("WEBSITE_LINK_FAILED", "The publisher website could not be opened.", {}, ErrorHandler.Severity.ERROR)

func _on_back() -> void:
	_play_feedback()
	if NavigationService:
		if NavigationService.can_go_back():
			NavigationService.go_back()
		else:
			NavigationService.navigate_to("settings")

func _play_feedback() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if AccessibilityService:
		AccessibilityService.vibrate(20)

func on_navigated_to(params: Dictionary) -> void:
	_apply_responsive_layout()
	var section: String = str(params.get("section", "about"))
	await get_tree().process_frame
	var target: Control = $Margin/Scroll/VBox/AboutTitle
	if section == "privacy":
		target = $Margin/Scroll/VBox/PrivacySection
	elif section == "credits":
		target = $Margin/Scroll/VBox/CreditsSection
	scroll.ensure_control_visible(target)
	# Screen-view analytics are centralized in NavigationService.navigate_to.
