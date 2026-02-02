extends CharacterBody3D

@export_group("Settings")
@export var speed: float = 7.0
@export var life_points: float = 100.0

@export_group("States")
@export var patrol_radius: float = 10.0
@export var idle_time: float = 2.0
@export var chase_speed: float = 10.0
@export var lose_sight_time: float = 1.5

@onready var player_area: Area3D = %ViewPlayer
@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_ray: RayCast3D = %VisionRay

enum EnemyStates {
	IDLE,
	CHASING,
	PATROL,
	ATTACKING
} 


var player: Node
var state: EnemyStates = EnemyStates.IDLE
var idle_timer: float = 0.0
var patrol_point: Vector3
var last_time_seen: float = 0.0
var has_line_of_sight: bool = false

func _ready() -> void:
	player_area.connect("body_entered", Callable(self,"_on_player_detected"))
	#player_area.connect("body_exited", Callable(self,"_on_player_lost"))
	
	navAgent.max_speed = speed
	navAgent.path_desired_distance = 0.6
	navAgent.target_desired_distance = 0.8


func _process(_delta: float) -> void:
	global.debug.add_property("Enemy life points",life_points,6)
	global.debug.add_property("Enemy state",state,7)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match state:
		EnemyStates.IDLE:
			idle_state(delta)
		EnemyStates.PATROL:
			patrol_state(delta)
		EnemyStates.CHASING:
			if player:
				follow_player(delta)
			else:
				change_state(EnemyStates.IDLE)

		EnemyStates.ATTACKING:
			pass
		
		
	move_and_slide()
	
		
func _on_player_detected(body: Node) -> void:
	if body.is_in_group("player") and state != EnemyStates.CHASING:
		print("Player detected!")
		player = body
		change_state(EnemyStates.CHASING)
		
		
		
func follow_player(delta: float) -> void:
	if can_see_player():
		last_time_seen = 0.0
		navAgent.target_position = player.global_transform.origin
	else:
		last_time_seen += delta
		if last_time_seen >= lose_sight_time:
			player = null
			change_state(EnemyStates.IDLE)
			return
			
	var next_pos: Vector3 = navAgent.get_next_path_position()
	var dir: Vector3 = (next_pos - global_transform.origin).normalized()
	var desired_velocity: Vector3 = dir * chase_speed

	velocity = velocity.move_toward(desired_velocity, 10 * delta)


func take_damage(damage_amount: int) -> void:
	life_points -= damage_amount
	if life_points <= 0:
		die()
		
func die() -> void:
	velocity = Vector3.ZERO
	await get_tree().create_timer(0.5).timeout
	queue_free()

func idle_state(delta: float) -> void:
	velocity = velocity.move_toward(Vector3.ZERO,4.0 * delta)
	idle_timer += delta
	if idle_timer >= idle_time:
		set_random_patrol_point()
		change_state(EnemyStates.PATROL)

func patrol_state(delta: float) -> void:
	navAgent.target_position = patrol_point
	var next_pos: Vector3 = navAgent.get_next_path_position()
	var dir: Vector3 = (next_pos - global_transform.origin).normalized()
	var desired_velocity: Vector3 = dir * speed
	
	velocity = velocity.move_toward(desired_velocity,3.0 * delta)
	
	if navAgent.is_navigation_finished():
		change_state(EnemyStates.IDLE)
		
func set_random_patrol_point() -> void:
	var random_dir: Vector3 = Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1)
	).normalized()

	patrol_point = global_transform.origin + random_dir * patrol_radius
	navAgent.target_position = patrol_point

func change_state(new_state: EnemyStates) -> void:
	state = new_state
	idle_timer = 0.0
	
	
	
func can_see_player() -> bool:
	if not player:
		return false

	var local_target: Vector3 = vision_ray.to_local(player.global_transform.origin)
	vision_ray.target_position = local_target
	vision_ray.force_raycast_update()

	if vision_ray.is_colliding():
		var collider: Object = vision_ray.get_collider()
		return collider.is_in_group("player")

	return false
