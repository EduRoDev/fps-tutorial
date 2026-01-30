class_name WeaponController extends Node

@export_group("Settings")
@export var current_weapon: Weapon
@export var weapon_model_parent: Node3D
@export var weapon_state: WeaponState
@export var camera: Camera3D

var current_weapon_model: Node3D
var current_ammo: int


enum Category {
	PISTOL,
	RIFLE,
	SHOTGUN,
	SNIPER,
	SMG
}

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
	if !can_fire():
		return
		
	current_ammo -= 1
	
	match current_weapon.category:
		Category.SHOTGUN:
			_shotgun_fire()
		_:
			_perform_hitscan_fire()



func _shotgun_fire() -> void:
	for i in current_weapon.pellets:
		_perform_hitscan_fire(true)
	
	
	
func _perform_hitscan_fire(use_spread := false) -> void:
	if !camera:
		push_warning("no camera assigned to WeaponController")
		return
	
	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var forward: Vector3 = -camera.global_transform.basis.z
	
	if use_spread:
		forward = forward.rotated(
			camera.global_transform.basis.x,
			deg_to_rad(randf_range(-current_weapon.spread, current_weapon.spread))
		)
		
		forward = forward.rotated(
			camera.global_transform.basis.y,
			deg_to_rad(randf_range(-current_weapon.spread, current_weapon.spread))
		)
	
	var to: Vector3 = from + forward * current_weapon.range
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result:
		#print("Hit: ", result.collider.name, " at position: ", result.position)
		_spawn_impact_marker(result.position)
		
		var collider = result.collider
		_weapon_hit_damage(collider, current_weapon.category)
		

func _spawn_impact_marker(position: Vector3) -> void:
	var marker: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	
	box.size = Vector3(0.1, 0.1, 0.1)
	marker.mesh = box
	
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	marker.set_surface_override_material(0, material)
	get_tree().current_scene.add_child(marker)
	marker.global_position = position
	
	get_tree().create_timer(2.0).timeout.connect(marker.queue_free)
	
func _weapon_hit_damage(target, category) -> void:
	var cat_int: int = int(category)
	if cat_int == Category.SHOTGUN:
		if target.is_in_group("Enemy") and target.has_method("take_damage"):
			target.take_damage(current_weapon.damage / current_weapon.pellets)
	else:
		if target.is_in_group("Enemy") and target.has_method("take_damage"):
			target.take_damage(current_weapon.damage)