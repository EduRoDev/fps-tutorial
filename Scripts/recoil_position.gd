extends Node3D

@export var recoil_amount: Vector3
@export var snap_amount: float
@export var speed: float

#@export var weapon: WeaponController

 
var current_position: Vector3
var tartet_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#weapon.weapon_fired.connect(_on_weapon_fired)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tartet_position = lerp(tartet_position,Vector3.ZERO,speed * delta)
	current_position =  lerp(current_position,tartet_position, snap_amount * delta)
	rotation_degrees = current_position

func _on_weapon_fired(weapon_name: String) -> void:
	if weapon_name != "pistol":
		add_recoil()

func add_recoil() -> void:
	var range_x = randf_range(recoil_amount.x,recoil_amount.x * 2)
	var range_y = randf_range(recoil_amount.y,recoil_amount.y * 2)
	var range_z = randf_range(-recoil_amount.z,recoil_amount.z)
	
	tartet_position += Vector3(range_x,range_y,range_z)
