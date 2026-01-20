class_name GrapplingPlayerState
extends PlayerMovementState


@export var Ray: RayCast3D
@export var Rest_length: float = 2.0
@export var Stiffness: float = 5.0
@export var Damping: float = 2.0
@export var MAX_GRAPPLE_SPEED: float = 12.0
@export var GRAVITY_SCALE: float = 0.3


@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 7.0


var launched: bool = false
var target: Vector3

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	
	if Input.is_action_pressed("hook"):
		launch()

	if Input.is_action_just_released("hook"):
		retract()

	if launched:
		handle_grappling(delta)
		
	if PLAYER.is_on_floor() and !launched:
		transition.emit("IdlePlayerState")

func launch() -> void:
	if Ray.is_colliding():
		target = Ray.get_collision_point()
		launched = true

func retract() -> void:
	launched = false
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
	elif not Input.is_action_pressed("hook"):
		transition.emit("FallingPlayerState")

func handle_grappling(delta: float) -> void:
	# Reducir el efecto de la gravedad mientras estamos enganchados
	PLAYER.velocity.y += PLAYER.gravity * (1.0 - GRAVITY_SCALE) * delta
	
	var target_dir = PLAYER.global_position.direction_to(target)
	var target_dist = PLAYER.global_position.distance_to(target)

	var displacement = target_dist - Rest_length
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = Stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = PLAYER.velocity.dot(target_dir)
		var damping_force = -Damping * vel_dot * target_dir

		force = spring_force + damping_force

	PLAYER.velocity += force * delta
	
	# Limitar la velocidad máxima
	if PLAYER.velocity.length() > MAX_GRAPPLE_SPEED:
		PLAYER.velocity = PLAYER.velocity.normalized() * MAX_GRAPPLE_SPEED
