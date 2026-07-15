extends RefCounted
class_name IrisInputIntent

# Hardware is translated into this small interaction vocabulary before the
# application decides what the intent means on the current screen.
enum Type {
    FOCUS,
    ENTER,
    RETURN,
    EXPLORE_LEFT,
    EXPLORE_RIGHT,
    EXPLORE_UP,
    EXPLORE_DOWN
}

const FOCUS: int = Type.FOCUS
const ENTER: int = Type.ENTER
const RETURN: int = Type.RETURN
const EXPLORE_LEFT: int = Type.EXPLORE_LEFT
const EXPLORE_RIGHT: int = Type.EXPLORE_RIGHT
const EXPLORE_UP: int = Type.EXPLORE_UP
const EXPLORE_DOWN: int = Type.EXPLORE_DOWN
