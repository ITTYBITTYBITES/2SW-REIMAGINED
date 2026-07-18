extends Control
class_name IrisHomeScreen
## IrisHomeScreen — pure home-screen UI overlay.
##
## The Living Iris is rendered separately and persistently by IrisScreen
## (IrisController) and is ALWAYS visible. This screen draws ONLY the home UI:
## title, welcome copy, navigation cards (presentational hints), and a utility
## bar.
##
## This screen deliberately does NOT:
##   - extend IrisController
##   - render its own iris / shaders / particles
##   - hold iris state (iris_core, awakening_level, particles, elapsed, ...)
##   - compete with iris-driven navigation
##
## Per MainController, navigation is encoded in the Iris rim itself; the cards
## shown here are presentational hints. The entire overlay is mouse-transparent
## so it never swallows the pointer events the Iris needs for gaze/focus.

@onready var title_label: Label = $Header/TitleLabel
@onready var subtitle_label: Label = $Header/SubtitleLabel
@onready var welcome_title: Label = $WelcomePanel/WelcomeTitle
@onready var welcome_subtitle: Label = $WelcomePanel/WelcomeSubtitle
@onready var welcome_text: Label = $WelcomePanel/WelcomeText

# Local UI-only animation clock. Deliberately NOT named `elapsed` so it cannot
# be mistaken for IrisController.elapsed (this class no longer extends it).
var ui_time: float = 0.0

func _ready() -> void:
	# The whole screen is a non-blocking visual layer: it must never intercept
	# pointer events meant for the Living Iris behind it. (The scene also sets
	# every child to MOUSE_FILTER_IGNORE for the same reason.)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	ui_time += delta
	# Gentle breathing on the welcome copy — pure UI, fully null-guarded.
	var bob := sin(ui_time * 0.8) * 2.0
	if welcome_title:
		welcome_title.position.y = 0.0 + bob
	if welcome_subtitle:
		welcome_subtitle.position.y = 44.0 + bob
	if welcome_text:
		welcome_text.position.y = 84.0 + bob
