class_name GrapplingPlayerState
extends PlayerMovementState

@export_group("Settings")
@export var Ray: RayCast3D
@export var Rest_length: float = 2.0
@export var Stiffness: float = 5.0
@export var Damping: float = 2.0
@export var MAX_GRAPPLE_SPEED: float = 12.0
@export var GRAVITY_SCALE: float = 0.3

@export_group("Movement")
@export var rope: Node3D
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 5.0
@export var cooldown_time: float = 5.0

@export_group("Wallrun")
@export var WALL_RAY_LEFT: RayCast3D
@export var WALL_RAY_RIGHT: RayCast3D


@onready var cooldown = %HookTimerController

var current_rope_length: float = 0.0
var launched: bool = false
var target: Vector3
var can_use_hook: bool = true

func is_wall_detected() -> bool:
	return (WALL_RAY_LEFT and WALL_RAY_LEFT.is_colliding()) or (WALL_RAY_RIGHT and WALL_RAY_RIGHT.is_colliding())


func _process(_delta: float) -> void:
	global.debug.add_property("hook cooldown",cooldown.time_left,4)
	
func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()

	if Input.is_action_pressed("hook") and can_use_hook:
		launch()
	if Input.is_action_just_released("hook"):
		retract()
	
	if !PLAYER.is_on_floor():
		if Input.is_action_pressed("sprint") and Input.is_action_pressed("jump"):
			if is_wall_detected():
				transition.emit("WallRunPlayerState")
	
	if launched:
		handle_grappling(delta)
	
	update_rope(delta)
	
	if PLAYER.is_on_floor() and !launched:
		transition.emit("IdlePlayerState")
	
	if !PLAYER.is_on_floor() and PLAYER.velocity.y < -3.0:
		transition.emit("FallingPlayerState")
	

func launch() -> void:
	if Ray.is_colliding() and can_use_hook:
		target = Ray.get_collision_point()
		launched = true
		can_use_hook = false
		if rope.has_method("wiggle_rope"):
			rope.wiggle_rope()
			
		if cooldown:
			cooldown.start(cooldown_time)
	
func retract() -> void:
	launched = false
	

func handle_grappling(delta: float) -> void:
	# Reducir el efecto de la gravedad mientras estamos enganchados
	PLAYER.velocity.y += PLAYER.gravity * (1.0 - GRAVITY_SCALE) * delta
	
	var target_dir = PLAYER.global_position.direction_to(target)
	var target_dist = PLAYER.global_position.distance_to(target)
	
	if target_dist < 1.5:
		retract()
		return
		
		
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
		
func update_rope(delta: float): # Añadimos delta para suavizado
	if !launched:
		rope.visible = false
		current_rope_length = 0.0 # Reset de longitud
		return
	
	rope.visible = true
	var dist = PLAYER.global_position.distance_to(target)
	
	# Suaviza el crecimiento del cable para que parezca que se dispara
	current_rope_length = lerp(current_rope_length, dist, delta * 20.0)
	
	rope.look_at(target)
	rope.scale = Vector3(1, 1, current_rope_length)
	
	
func _on_hook_timer_controller_timeout() -> void:
	can_use_hook = true
