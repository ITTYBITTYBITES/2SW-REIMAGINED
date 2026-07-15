extends Control
class_name MobileFrameOverlay

var screen_rect := Rect2()
var phone_rect := Rect2()
var frame_visible := true
var notch_visible := true
var orientation := 0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_geometry(screen: Rect2, phone: Rect2, orientation_value: int, show_frame: bool, show_notch: bool) -> void:
    screen_rect = screen
    phone_rect = phone
    orientation = orientation_value
    frame_visible = show_frame
    notch_visible = show_notch
    queue_redraw()

func _draw() -> void:
    if not frame_visible:
        return
    var radius := minf(34.0, minf(phone_rect.size.x, phone_rect.size.y) * 0.07)
    # The shell body is drawn behind the SubViewportContainer by the
    # simulator root. This foreground only draws its outline and optical
    # details, so it never covers the game display.
    draw_rect(phone_rect.grow(5.0), Color(0.03, 0.05, 0.07, 0.92), false, 8.0)
    draw_rect(phone_rect, Color(0.44, 0.77, 0.70, 0.24), false, 2.0)
    _draw_screen_corner_masks(radius)
    _draw_safe_areas()
    _draw_notch()

func _rounded_box(color: Color, radius: float) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = color
    box.corner_radius_top_left = int(radius)
    box.corner_radius_top_right = int(radius)
    box.corner_radius_bottom_left = int(radius)
    box.corner_radius_bottom_right = int(radius)
    return box

func _draw_screen_corner_masks(radius: float) -> void:
    var c := Color("#111a22")
    draw_circle(screen_rect.position + Vector2(radius, radius), radius, c)
    draw_circle(Vector2(screen_rect.end.x - radius, screen_rect.position.y + radius), radius, c)
    draw_circle(Vector2(screen_rect.position.x + radius, screen_rect.end.y - radius), radius, c)
    draw_circle(screen_rect.end - Vector2(radius, radius), radius, c)

func _draw_safe_areas() -> void:
    var safe_color := Color(0.10, 0.20, 0.22, 0.10)
    if orientation == 0:
        draw_rect(Rect2(screen_rect.position, Vector2(screen_rect.size.x, minf(28.0, screen_rect.size.y * 0.04))), safe_color)
        draw_rect(Rect2(Vector2(screen_rect.position.x, screen_rect.end.y - 32.0), Vector2(screen_rect.size.x, 32.0)), safe_color)
    else:
        draw_rect(Rect2(screen_rect.position, Vector2(minf(28.0, screen_rect.size.x * 0.04), screen_rect.size.y)), safe_color)
        draw_rect(Rect2(Vector2(screen_rect.end.x - 28.0, screen_rect.position.y), Vector2(28.0, screen_rect.size.y)), safe_color)

func _draw_notch() -> void:
    if not notch_visible:
        return
    if orientation == 0:
        var notch := Rect2(screen_rect.position.x + screen_rect.size.x * 0.5 - 58.0, screen_rect.position.y + 4.0, 116.0, 22.0)
        draw_style_box(_rounded_box(Color("#111a22"), 12.0), notch)
        draw_circle(Vector2(notch.end.x - 20.0, notch.position.y + 11.0), 3.0, Color("#263b43"))
    else:
        var notch_landscape := Rect2(screen_rect.position.x + 4.0, screen_rect.position.y + screen_rect.size.y * 0.5 - 58.0, 22.0, 116.0)
        draw_style_box(_rounded_box(Color("#111a22"), 12.0), notch_landscape)

