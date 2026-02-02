class_name WeaponController
extends Node

@export_group("Settings")
@export var current_weapon: Weapon
@export var weapon_model_parent: Node3D
@export var weapon_state: WeaponState
@export var camera: Camera3D

var current_weapon_model: Node3D
var current_ammo: int
var current_accuracy: float = 100.0  

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
		current_accuracy = current_weapon.base_accuracy


func _process(delta: float) -> void:
	global.debug.add_property("accuracy", current_accuracy, 6)
	
	if current_weapon and current_accuracy < current_weapon.base_accuracy:
		current_accuracy += current_weapon.accuracy_recovery_rate * delta
		current_accuracy = min(current_accuracy, current_weapon.base_accuracy)

func spawn_weapon_model():
	if current_weapon_model:
		current_weapon_model.queue_free()

	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_model_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position

func can_fire() -> bool:
	var weapon_data = Managers.weapon_manager.weapons[Managers.weapon_manager.current_weapon_slot]
	return weapon_data.ammo > 0

func fire_weapon() -> void:
	if not can_fire():
		return

	Managers.weapon_manager.use_ammo(Managers.weapon_manager.current_weapon_slot)
	
	var weapon_data = Managers.weapon_manager.weapons.get(Managers.weapon_manager.current_weapon_slot)
	if weapon_data:
			current_ammo = weapon_data.ammo
			
	#print("Firing weapon: ", current_weapon.weapon_name, " | Ammo left: ", Managers.weapon_manager.get_current_ammo())
	_reduce_accuracy()

	match current_weapon.category:
		Category.SHOTGUN:
			_shotgun_fire()

		Category.SNIPER, Category.RIFLE:
			_perform_hitscan_fire()

		Category.PISTOL:
			#_fire_projectile()
			_perform_hitscan_fire()
		_:
			_perform_hitscan_fire()

func _reduce_accuracy() -> void:
	if current_weapon:
		current_accuracy -= current_weapon.accuracy_penalty_per_shot
		current_accuracy = max(current_accuracy, current_weapon.min_accuracy)

func _get_spread_from_accuracy() -> float:
	var max_spread: float = 10.0  
	if current_accuracy >= 100.0:
		return 0.0
	var accuracy_factor: float = (100.0 - current_accuracy) / 100.0
	return accuracy_factor * max_spread

func _shotgun_fire() -> void:
	for i in current_weapon.pellets:
		_perform_hitscan_fire(true)

func _perform_hitscan_fire(use_spread := false) -> void:
	if camera == null:
		push_warning("no camera assigned to WeaponController")
		return

	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var forward: Vector3 = -camera.global_transform.basis.z

	# Calcular dispersión
	var spread_amount: float = 0.0

	if use_spread:
		spread_amount = current_weapon.spread
	else:
		spread_amount = _get_spread_from_accuracy()

	if spread_amount > 0.0:
		forward = forward.rotated(
			camera.global_transform.basis.x,
			deg_to_rad(randf_range(-spread_amount, spread_amount))
		)
		forward = forward.rotated(
			camera.global_transform.basis.y,
			deg_to_rad(randf_range(-spread_amount, spread_amount))
		)

	var to: Vector3 = from + forward * current_weapon.rango

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = space_state.intersect_ray(query)

	if result:
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

func _fire_projectile() -> void:
	if current_weapon == null or not current_weapon.bullet_scene:
		push_warning("No bullet scene assigned to weapon: " + str(current_weapon.weapon_name if current_weapon != null else "<none>"))
		return

	if camera == null:
		push_warning("no camera assigned to WeaponController")
		return

	var bullet_instance: Node = current_weapon.bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_instance)

	bullet_instance.global_position = camera.global_position

	var forward: Vector3 = -camera.global_transform.basis.z

	var spread_amount: float = _get_spread_from_accuracy()

	if spread_amount > 0.0:
		forward = forward.rotated(
			camera.global_transform.basis.x,
			deg_to_rad(randf_range(-spread_amount, spread_amount))
		)
		forward = forward.rotated(
			camera.global_transform.basis.y,
			deg_to_rad(randf_range(-spread_amount, spread_amount))
		)

	var velocity: Vector3 = forward * current_weapon.bullet_speed
	bullet_instance.look_at(bullet_instance.global_position + forward, Vector3.UP)

	if bullet_instance.has_method("setup"):
		bullet_instance.setup(velocity, current_weapon.damage)

func get_current_accuracy() -> float:
	return current_accuracy
	

func switch_weapon(weapon_data: WeaponData) -> void:	
	current_weapon = weapon_data.weapon
	current_ammo = weapon_data.ammo
	if current_weapon_model:
		current_weapon_model.queue_free()
		
	spawn_weapon_model()
	#print(current_weapon.weapon_name)
