extends MarginContainer
## ScreenContainer - shared premium screen spacing foundation.
##
## Phase 0 introduces this small reusable container so future Witness surfaces
## inherit consistent margins without creating a parallel shell or routing
## system. It delegates breakpoints and safe-area interpretation to the existing
## ResponsiveLayout helper.

@export var base_gutter: float = 16.0
@export var max_content_width: float = 560.0

func _ready() -> void:
	_apply_layout()
	if not resized.is_connected(_apply_layout):
		resized.connect(_apply_layout)

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_apply_layout()

func _apply_layout() -> void:
	if has_node("."):
		ResponsiveLayout.apply_centered_margin(self, base_gutter, max_content_width)
