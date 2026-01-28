class_name WeaponController extends Node

@export_group("Settings")
@export var current_weapon: Weapon
@export var weapon_model_parent: Node3D
@export var weapon_state: WeaponState
@export var camera: Camera3D

var current_weapon_model: Node3D
var current_ammo: int


func _ready() -> void:
	if current_weapon:
		spawn_weapon_model()
		current_ammo = current_weapon.max_ammo

func spawn_weapon_model():
	if current_weapon_model:
		current_weapon_model.queue_free()
		
	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_model_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position
		
		
		
func can_fire() -> bool:
	return current_ammo > 0
	
func fire_weapon() -> void:
	if can_fire():
		current_ammo -= 1
		#print("Fired! Ammo left: ", current_ammo)
		_perform_hitscan_fire()
		
func _perform_hitscan_fire() -> void:
	if !camera:
		push_warning("no camera assigned to WeaponController")
		return
	
	var space_state = camera.get_world_3d().direct_space_state
	var from = camera.global_position
	var forward = -camera.global_transform.basis.z
	var to = from + forward * current_weapon.range
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		#print("Hit: ", result.collider.name, " at position: ", result.position)
		_spawn_impact_marker(result.position)
		
		var collider = result.collider
		if collider.is_in_group("Enemy"):
			if collider.has_method("take_damage"):
				collider.take_damage(current_weapon.damage)
		

func _spawn_impact_marker(position: Vector3) -> void:
	var marker = MeshInstance3D.new()
	var box = BoxMesh.new()
	
	box.size = Vector3(0.1, 0.1, 0.1)
	marker.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	marker.set_surface_override_material(0, material)
	get_tree().current_scene.add_child(marker)
	marker.global_position = position
	
	get_tree().create_timer(2.0).timeout.connect(marker.queue_free)