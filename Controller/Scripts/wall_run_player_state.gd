class_name WallRunPlayerState
extends PlayerMovementState

@export var WALL_RUN_SPEED: float = 6.0
@export var GRAVITY_SCALE: float = 0.3
@export var WALL_RAY_LEFT: RayCast3D
@export var WALL_RAY_RIGHT: RayCast3D
@export var WALL_JUMP_FORCE: float = 1.5
@export var CAMERA_TILT_AMOUNT: float = 5.0
@export var TILT_AMOUNT: float = 0.09
@export_range(1, 6, 0.1) var WALLRUN_ANIM_SPEED: float = 2.0
@export var CAMERA_Z_TILT_DEGREES: float = 15.0
@export var SPEED_DECAY: float = 2.0  # Velocidad que pierde por segundo
@export var MIN_WALL_RUN_SPEED: float = 2.0  # Velocidad mínima antes de caer

var wall_normal: Vector3 = Vector3.ZERO
var wall_side: int = 0  
var active_ray: RayCast3D = null
var run_direction: Vector3 = Vector3.ZERO
var last_wall_normal: Vector3 = Vector3.ZERO  # Para evitar re-engancharse a la misma pared
var current_wall_speed: float = 0.0  # Velocidad actual del wall run

func get_active_wall_ray() -> RayCast3D:
	if WALL_RAY_LEFT and WALL_RAY_LEFT.is_colliding():
		return WALL_RAY_LEFT
	elif WALL_RAY_RIGHT and WALL_RAY_RIGHT.is_colliding():
		return WALL_RAY_RIGHT
	return null

func is_wall_detected() -> bool:
	return get_active_wall_ray() != null

# Verificar si es una pared diferente a la anterior
func is_different_wall() -> bool:
	var ray = get_active_wall_ray()
	if ray and ray.is_colliding():
		var new_normal = ray.get_collision_normal()
		# Considerar diferente si el ángulo entre normales es mayor a 45 grados
		return new_normal.dot(last_wall_normal) < 0.7
	return false

func enter(_previous_state) -> void:
	active_ray = get_active_wall_ray()
	current_wall_speed = WALL_RUN_SPEED  
	
	if active_ray and active_ray.is_colliding():
		wall_normal = active_ray.get_collision_normal()
		last_wall_normal = wall_normal  
		wall_side = -1 if active_ray == WALL_RAY_LEFT else 1
		
		var tilt_direction = wall_side * PLAYER._current_rotation
		set_tilt(tilt_direction)
		
		var camera_z_tilt = -CAMERA_Z_TILT_DEGREES if active_ray == WALL_RAY_LEFT else CAMERA_Z_TILT_DEGREES
		PLAYER.set_camera_tilt(camera_z_tilt)
		
		ANIMATION.speed_scale = 1.0
		ANIMATION.play("WallRun", -1.0, WALLRUN_ANIM_SPEED)
		
		WEAPON.play_animation("Pistol_RUN",0.2)
		
		var horizontal_velocity = Vector3(PLAYER.velocity.x, 0, PLAYER.velocity.z)
		#print(horizontal_velocity)
		if horizontal_velocity.length() > 0.1:
			run_direction = horizontal_velocity.normalized()
			#print(run_direction)
		else:
			run_direction = -PLAYER.global_transform.basis.z
		
		run_direction = (run_direction - wall_normal * run_direction.dot(wall_normal)).normalized()
		#print("corriendo: ", run_direction)
		
		

func exit() -> void:
	var reset_tilt = Vector3.ZERO
	ANIMATION.get_animation("WallRun").track_set_key_value(1, 1, reset_tilt)
	ANIMATION.get_animation("WallRun").track_set_key_value(1, 2, reset_tilt)
	ANIMATION.stop()
	PLAYER.reset_camera_tilt()
	
	

func update(delta: float) -> void:
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")

	if not active_ray or not active_ray.is_colliding():
		wall_jump()  
		if PLAYER.velocity.y < -3.0:
			transition.emit("FallingPlayerState")
		else:
			transition.emit("JumpPlayerState")
		return
	
	
	if Input.is_action_just_released("jump"):
		wall_jump()
		transition.emit("JumpPlayerState")
		return 
		
	wall_normal = active_ray.get_collision_normal()
	
	current_wall_speed -= SPEED_DECAY * delta
	
	
	if current_wall_speed <= MIN_WALL_RUN_SPEED:
		wall_jump()
		transition.emit("FallingPlayerState")
		
	
	PLAYER.velocity.y -= PLAYER.gravity * GRAVITY_SCALE * delta
	
	PLAYER.velocity.x = run_direction.x * current_wall_speed
	PLAYER.velocity.z = run_direction.z * current_wall_speed
	
	PLAYER.velocity += -wall_normal * 1.0
	
	PLAYER.update_velocity()

func wall_jump() -> void:
	PLAYER.velocity.y = WALL_JUMP_FORCE
	PLAYER.velocity += wall_normal * WALL_JUMP_FORCE * 2.0

func set_tilt(player_rotation: float) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -1.0, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	
	ANIMATION.get_animation("WallRun").track_set_key_value(1, 1, tilt)
	ANIMATION.get_animation("WallRun").track_set_key_value(1, 2, tilt)
	

func finish():
	transition.emit("FallingPlayerState")
