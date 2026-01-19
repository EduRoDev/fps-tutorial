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

func is_wall_detected() -> bool:
	return (WALL_RAY_LEFT and WALL_RAY_LEFT.is_colliding()) or (WALL_RAY_RIGHT and WALL_RAY_RIGHT.is_colliding())

func get_horizontal_speed() -> float:
	return Vector2(PLAYER.velocity.x, PLAYER.velocity.z).length()

func enter(_previous_state) -> void:
	if _previous_state is WallRunPlayerState:
		pass
	else:
		PLAYER.velocity.y += JUMP_VELOCITY
		ANIMATION.pause()

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
	
	# Verificar wall run: sprint + jump presionado + pared detectada + velocidad mínima
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("jump") and is_wall_detected() and get_horizontal_speed() > MIN_SPEED_FOR_WALLRUN:
		transition.emit("WallRunPlayerState")

	if PLAYER.velocity.y < -1.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
