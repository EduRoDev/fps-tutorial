extends CharacterBody3D


const SPEED = 7.0
@onready var navAgent = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var currentLocalition = global_transform.origin
	var nextLocation = navAgent.get_next_path_position()
	var nextVelocity = (nextLocation - currentLocalition).normalized() * SPEED
	
	velocity = velocity.move_toward(nextVelocity,0.4)
	_target_position(global.player)
	
	move_and_slide()

func _target_position(target):
	navAgent.target_position = target.global_transform.origin
	
