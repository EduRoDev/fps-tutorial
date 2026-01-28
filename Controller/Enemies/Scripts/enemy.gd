extends CharacterBody3D


@export var speed = 7.0
@export var life_points = 100

@onready var navAgent = $NavigationAgent3D

func _process(delta: float) -> void:
	global.debug.add_property("Enemy life points",life_points,6)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var currentLocalition = global_transform.origin
	var nextLocation = navAgent.get_next_path_position()
	var nextVelocity = (nextLocation - currentLocalition).normalized() * speed
	
	velocity = velocity.move_toward(nextVelocity,0.4)
	_target_position(global.player)
	
	move_and_slide()

func _target_position(target):
	navAgent.target_position = target.global_transform.origin
	
func take_damage(damage_amount: int) -> void:
	life_points -= damage_amount
	if life_points <= 0:
		die()
		
func die() -> void:
	velocity = Vector3.ZERO
	await get_tree().create_timer(0.5).timeout
	queue_free()