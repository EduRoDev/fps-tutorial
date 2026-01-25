class_name GrapplingPlayerState
extends PlayerMovementState


@export var Ray: RayCast3D
@export var Rest_length: float = 2.0
@export var Stiffness: float = 5.0
@export var Damping: float = 2.0
@export var MAX_GRAPPLE_SPEED: float = 12.0
@export var GRAVITY_SCALE: float = 0.3

@export var rope: Node3D
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 5.0
@export var cooldown_time: float = 5.0

@onready var cooldown = %HookTimerController
var launched: bool = false
var target: Vector3
var can_use_hook: bool = true


func _process(_delta: float) -> void:
	global.debug.add_property("hook cooldown",cooldown.time_left,3)
	
func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()

	if Input.is_action_pressed("hook") and can_use_hook:
		launch()

	if Input.is_action_just_released("hook"):
		retract()

	if launched:
		handle_grappling(delta)
	
	update_rope()
	
	if PLAYER.is_on_floor() and !launched:
		transition.emit("IdlePlayerState")

func launch() -> void:
	if Ray.is_colliding() and can_use_hook:
		target = Ray.get_collision_point()
		launched = true
		can_use_hook = false
		if cooldown:
			cooldown.start(cooldown_time)
	
func retract() -> void:
	launched = false
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
	elif not Input.is_action_pressed("hook") and !PLAYER.is_on_floor():
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
		
func update_rope():
	if !launched:
		rope.visible = false
		return
	
	rope.visible = true
	var dist = PLAYER.global_position.distance_to(target)
	rope.look_at(target)
	rope.scale = Vector3(1,1,dist)
	

func _on_hook_timer_controller_timeout() -> void:
	can_use_hook = true
