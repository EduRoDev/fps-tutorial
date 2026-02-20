extends CharacterBody3D

@export var speed: float = 8.0
@export var life_points: float = 100.0

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D

var player: Node3D


func _ready() -> void:
	velocity = Vector3.ZERO
	
	# busca automáticamente al jugador por grupo
	player = get_tree().get_first_node_in_group("player")
	
	navAgent.path_desired_distance = 0.6
	navAgent.target_desired_distance = 0.8
	navAgent.max_speed = speed


func _physics_process(delta: float) -> void:

	# gravedad normal
	if not is_on_floor():
		velocity += get_gravity() * delta

	# si no hay player no hacer nada
	if player == null:
		move_and_slide()
		return

	# SIEMPRE seguir jugador
	navAgent.target_position = player.global_position
	
	var next_pos: Vector3 = navAgent.get_next_path_position()
	var dir: Vector3 = (next_pos - global_position).normalized()
	
	var desired_velocity: Vector3 = dir * speed
	velocity = velocity.move_toward(desired_velocity, 15 * delta)

	move_and_slide()



func take_damage(damage_amount: int) -> void:
	life_points -= damage_amount
	if life_points <= 0:
		die()

func die() -> void:
	queue_free()
	get_tree().get_first_node_in_group("Spawner").check_round_end()