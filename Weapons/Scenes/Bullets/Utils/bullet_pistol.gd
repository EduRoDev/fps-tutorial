class_name BulletPistol extends Area3D

var velocity: Vector3
var damage: float

func  _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(3.0).timeout.connect(queue_free)
	
func _physics_process(delta: float) -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var start_pos: Vector3 = global_position
	var end_pos: Vector3 = global_position + velocity * delta
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	query.collision_mask = 1
	
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result:
		global_position = result.position
		_on_body_entered(result.collider)
		return
		
	global_position = end_pos	
	
func setup(vel: Vector3, dmg: float) -> void:
	velocity = vel
	damage = dmg

func _on_body_entered(body: Node) -> void:
	print("Bullet hit: ", body.name)
	_spawn_impact_marker(global_position)
	
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()
	
func _spawn_impact_marker(position_v: Vector3) -> void:
	var marker: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	
	box.size = Vector3(0.1, 0.1, 0.1)
	marker.mesh = box
	
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	marker.set_surface_override_material(0, material)
	get_tree().current_scene.add_child(marker)
	marker.global_position = position_v
	
	get_tree().create_timer(2.0).timeout.connect(marker.queue_free)
	
	#func _apply_damage(target: Node) -> void:
		#if target.is_in_group("Enemy") and target.has_method("take_damage"):
			#target.take_damage(damage)
