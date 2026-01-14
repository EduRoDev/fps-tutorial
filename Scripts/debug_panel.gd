extends PanelContainer

@onready var property_container = $MarginContainer/VBoxContainer
# var property
var fps: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.debug = self
	visible = false
	# add_debug_text("FPS",fps)
	# add_property("FPS",fps,2)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		visible = !visible

func _process(delta: float) -> void:
	if visible:
		fps = "%.2f" % (1.0/delta)
		add_property("FPS",fps,2)

func add_property(title: String, value, order):
	var target 
	target = property_container.find_child(title,true,false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = title + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target,order)
