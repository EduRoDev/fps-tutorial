extends SubViewport

var screen_Size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_Size = get_window().size
	size = screen_Size

