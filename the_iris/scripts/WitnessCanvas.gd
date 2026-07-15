extends Control
class_name WitnessCanvas

var time := 0.0
var reveal := 0.0
var focus_point := Vector2(0.69, 0.40)

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func set_reveal(value: float) -> void:
    reveal = value
    queue_redraw()

func _draw() -> void:
    var size := get_viewport_rect().size
    var landscape := size.x > size.y
    var s := minf(size.x / (1120.0 if landscape else 720.0), size.y / (720.0 if landscape else 1280.0))
    var center := Vector2(size.x * 0.5, size.y * 0.50)
    # A quiet, depth-layered scene inside the lens: window, shelf, plant, and a
    # detail that only becomes legible after the focus interval.
    var horizon := size.y * 0.60
    draw_rect(Rect2(0, horizon, size.x, size.y - horizon), Color("#0e2025"))
    draw_rect(Rect2(size.x * 0.13, size.y * 0.19, size.x * 0.74, size.y * 0.34), Color("#10282c"), false, 2.0)
    draw_line(Vector2(size.x * 0.50, size.y * 0.19), Vector2(size.x * 0.50, size.y * 0.53), Color("#285252"), 1.0)
    draw_line(Vector2(size.x * 0.13, size.y * 0.36), Vector2(size.x * 0.87, size.y * 0.36), Color("#285252"), 1.0)
    # Slow parallax drift.
    var drift := sin(time * 0.24) * s * 2.0
    draw_rect(Rect2(size.x * 0.16 + drift, horizon - 4.0 * s, size.x * 0.70, 5.0 * s), Color("#1b3a3c"))
    draw_rect(Rect2(size.x * 0.19 + drift, horizon + 8.0 * s, size.x * 0.62, 3.0 * s), Color("#285452"))
    # Plant-like organic silhouette.
    var stem := Vector2(size.x * 0.30 + drift, horizon + 6.0 * s)
    draw_line(stem, stem + Vector2(-8, -85) * s, Color("#4a8071"), 3.0 * s)
    draw_line(stem + Vector2(-4, -40) * s, stem + Vector2(-37, -68) * s, Color("#4a8071"), 2.0 * s)
    draw_line(stem + Vector2(-4, -55) * s, stem + Vector2(29, -94) * s, Color("#4a8071"), 2.0 * s)
    draw_circle(stem + Vector2(-42, -73) * s, 13.0 * s, Color("#214f4b"))
    draw_circle(stem + Vector2(32, -99) * s, 16.0 * s, Color("#285b50"))
    draw_circle(stem + Vector2(-10, -112) * s, 18.0 * s, Color("#1d4946"))
    # The ordinary detail: a tiny second reflection in the window.
    var detail := Vector2(size.x * focus_point.x, size.y * focus_point.y)
    var reveal_alpha := clampf(reveal, 0.0, 1.0)
    draw_circle(detail, (5.0 + sin(time * 2.0) * 1.2) * s, Color(0.82, 0.67, 0.36, 0.18 + reveal_alpha * 0.7))
    draw_circle(detail, 2.0 * s, Color(0.96, 0.84, 0.55, 0.25 + reveal_alpha * 0.75))
    if reveal_alpha > 0.02:
        draw_arc(detail, 13.0 * s, 0.0 + reveal_alpha * 18.0, 18.0 + reveal_alpha * 80.0, 28, Color(0.88, 0.69, 0.34, reveal_alpha * 0.55), 1.0 * s)
    # A subtle focus reticle.
    var reticle := center + Vector2(0, size.y * 0.01)
    var reticle_col := Color(0.44, 0.83, 0.73, 0.22 + reveal_alpha * 0.28)
    draw_arc(reticle, 132.0 * s, -0.5, 0.9, 32, reticle_col, 1.0 * s)
    draw_arc(reticle, 132.0 * s, 2.25, 3.65, 32, reticle_col, 1.0 * s)
    draw_line(reticle + Vector2(-154, 0) * s, reticle + Vector2(-132, 0) * s, reticle_col, 1.0 * s)
    draw_line(reticle + Vector2(132, 0) * s, reticle + Vector2(154, 0) * s, reticle_col, 1.0 * s)
