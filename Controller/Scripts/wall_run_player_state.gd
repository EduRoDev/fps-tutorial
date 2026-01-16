class_name WallRunPlayerState
extends PlayerMovementState


@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 7.0
@export var WALL_RUN_SPEED: float = 6.0
@export var GRAVITY_SCALE: float = 0.3
@export var WALL_RAY_LEFT: RayCast3D
@export var WALL_RAY_RIGHT: RayCast3D
@export var WALL_JUMP_FORCE: float = 1.5
@export var CAMERA_TILT_AMOUNT: float = 5.0
@export var TILT_AMOUNT: float = 0.09
@export_range(1, 6, 0.1) var WALLRUN_ANIM_SPEED: float = 2.0

var wall_normal: Vector3 = Vector3.ZERO
var wall_side: int = 0  
var active_ray: RayCast3D = null
var run_direction: Vector3 = Vector3.ZERO  

func get_active_wall_ray() -> RayCast3D:
	if WALL_RAY_LEFT and WALL_RAY_LEFT.is_colliding():
		return WALL_RAY_LEFT
	elif WALL_RAY_RIGHT and WALL_RAY_RIGHT.is_colliding():
		return WALL_RAY_RIGHT
	return null

func is_wall_detected() -> bool:
	return get_active_wall_ray() != null

func enter(_previous_state) -> void:
	# Determinar qué raycast está colisionando
	active_ray = get_active_wall_ray()
	
	if active_ray and active_ray.is_colliding():
		wall_normal = active_ray.get_collision_normal()
		wall_side = -1 if active_ray == WALL_RAY_LEFT else 1
		
		# Aplicar tilt de cámara basado en la rotación del jugador y el lado de la pared
		var tilt_direction = wall_side * PLAYER._current_rotation
		set_tilt(tilt_direction)
		
		# Reproducir animación de WallRun
		ANIMATION.speed_scale = 1.0
		ANIMATION.play("WallRun", -1.0, WALLRUN_ANIM_SPEED)
		
		# Calcular la dirección de movimiento basada en la velocidad actual del jugador
		# Proyectamos la velocidad horizontal sobre el plano de la pared
		var horizontal_velocity = Vector3(PLAYER.velocity.x, 0, PLAYER.velocity.z)
		if horizontal_velocity.length() > 0.1:
			# Usar la dirección en la que ya nos movíamos
			run_direction = horizontal_velocity.normalized()
		else:
			# Si no hay velocidad, usar la dirección hacia adelante del jugador
			run_direction = -PLAYER.global_transform.basis.z
		
		# Proyectar la dirección sobre el plano de la pared (para que sea paralela)
		run_direction = (run_direction - wall_normal * run_direction.dot(wall_normal)).normalized()
		
		

func exit() -> void:
	# Resetear el tilt de la cámara a su posición original
	var reset_tilt = Vector3.ZERO
	ANIMATION.get_animation("WallRun").track_set_key_value(1, 1, reset_tilt)
	ANIMATION.get_animation("WallRun").track_set_key_value(1, 2, reset_tilt)
	

func update(delta: float) -> void:
	# Si tocamos el suelo, volvemos a idle
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
	
	# Verificar si aún estamos tocando la pared
	if not active_ray or not active_ray.is_colliding():
		# Si estamos cayendo, ir a FallingPlayerState
		if PLAYER.velocity.y < -3.0:
			transition.emit("FallingPlayerState")
		else:
			transition.emit("JumpPlayerState")
		
	
	# Si soltamos jump, salir del wall run
	if not Input.is_action_pressed("jump"):
		# Si estamos cayendo, ir a FallingPlayerState
		if PLAYER.velocity.y <= -1.0:
			transition.emit("FallingPlayerState")
		else:
			transition.emit("JumpPlayerState")
	
	# Actualizar la normal de la pared
	wall_normal = active_ray.get_collision_normal()
	
	# Aplicar gravedad reducida
	PLAYER.velocity.y -= PLAYER.gravity * GRAVITY_SCALE * delta
	
	# Aplicar velocidad en la dirección del wall run (la dirección calculada al entrar)
	PLAYER.velocity.x = run_direction.x * WALL_RUN_SPEED
	PLAYER.velocity.z = run_direction.z * WALL_RUN_SPEED
	
	# Pequeña fuerza hacia la pared para mantenerse pegado
	PLAYER.velocity += -wall_normal * 2.0
	
	PLAYER.update_velocity()
	
	

func wall_jump() -> void:
	# Impulso hacia arriba y lejos de la pared
	PLAYER.velocity.y = WALL_JUMP_FORCE
	PLAYER.velocity += wall_normal * WALL_JUMP_FORCE * 0.1

func set_tilt(player_rotation: float) -> void:
	var tilt = Vector3.ZERO
	# Inclinar basado en la rotación del jugador, similar a sliding
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -1.0, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	
	# Modificar la animación de WallRun con el tilt
	ANIMATION.get_animation("WallRun").track_set_key_value(1, 1, tilt)
	ANIMATION.get_animation("WallRun").track_set_key_value(1, 2, tilt)
	

func finish():
	transition.emit("FallingPlayerState")




