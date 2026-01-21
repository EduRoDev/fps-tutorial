class_name JumpPlayerState
extends PlayerMovementState

@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 7.0
@export var JUMP_VELOCITY: float = 2.5
@export_range(0.5,1.0,0.01) var INPUT_MULTIPLIER: float = 1.01
@export var WALL_RAY_LEFT: RayCast3D
@export var WALL_RAY_RIGHT: RayCast3D
@export var MIN_SPEED_FOR_WALLRUN: float = 3.0

var last_wall_normal: Vector3 = Vector3.ZERO

func is_wall_detected() -> bool:
	return (WALL_RAY_LEFT and WALL_RAY_LEFT.is_colliding()) or (WALL_RAY_RIGHT and WALL_RAY_RIGHT.is_colliding())

func get_horizontal_speed() -> float:
	return Vector2(PLAYER.velocity.x, PLAYER.velocity.z).length()

func get_active_wall_ray() -> RayCast3D:
	if WALL_RAY_LEFT and WALL_RAY_LEFT.is_colliding():
		return WALL_RAY_LEFT
	elif WALL_RAY_RIGHT and WALL_RAY_RIGHT.is_colliding():
		return WALL_RAY_RIGHT
	return null

# Verificar si es una pared diferente
func is_different_wall() -> bool:
	var ray = get_active_wall_ray()
	if ray and ray.is_colliding():
		var new_normal = ray.get_collision_normal()
		# Si no hay pared anterior registrada, cualquier pared es válida
		if last_wall_normal == Vector3.ZERO:
			return true
		# Considerar diferente si el ángulo entre normales es mayor a 45 grados
		return new_normal.dot(last_wall_normal) < 0.7
	return false

func enter(_previous_state) -> void:
	# Si venimos de un wall run, guardar la normal de esa pared
	if _previous_state is WallRunPlayerState:
		last_wall_normal = _previous_state.last_wall_normal
		# No aplicar salto adicional, ya viene con impulso del wall jump
		# La animación ya fue reproducida por wall_jump()
		ANIMATION.pause()
	else:
		last_wall_normal = Vector3.ZERO  # Resetear si no viene de wall run
		PLAYER.velocity.y += JUMP_VELOCITY
		ANIMATION.pause()
		# Reproducir animación de inicio de salto del arma
		WEAPON.play_animation("Pistol_JUMP_START")

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
	
	
	if Input.is_action_just_pressed("hook"):
		transition.emit("GrapplingPlayerState")

	# Verificar wall run: sprint + jump + pared detectada + pared diferente + velocidad mínima
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("jump") and is_wall_detected() and is_different_wall() and get_horizontal_speed() > MIN_SPEED_FOR_WALLRUN:
		transition.emit("WallRunPlayerState")

	if PLAYER.velocity.y < -1.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

