class_name SprintingPlayerState
extends PlayerMovementState


@export var TOP_ANIM_SPEED: float = 1.5
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 10.0
@export var WALL_RAY_LEFT: RayCast3D
@export var WALL_RAY_RIGHT: RayCast3D
@export var MIN_SPEED_FOR_WALLRUN: float = 3.0

func is_wall_detected() -> bool:
	return (WALL_RAY_LEFT and WALL_RAY_LEFT.is_colliding()) or (WALL_RAY_RIGHT and WALL_RAY_RIGHT.is_colliding())

func get_horizontal_speed() -> float:
	return Vector2(PLAYER.velocity.x, PLAYER.velocity.z).length()

func enter(_previous_state) -> void:
	ANIMATION.play("Sprint",0.5,1.0)
	
func update(_delta: float) -> void:
	PLAYER.update_gravity(_delta)
	PLAYER.update_input(SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(PLAYER.velocity.length())

	if Input.is_action_just_released("sprint") or PLAYER.velocity.length() == 0:
		transition.emit("WalkingPlayerState")

	if Input.is_action_pressed("crouch") and PLAYER.velocity.length() > 6:
		transition.emit("SlidingPlayerState")

	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpPlayerState")
	
	# Verificar wall run: en el aire + sprint + jump presionado + pared detectada + velocidad mínima
	if not PLAYER.is_on_floor() and Input.is_action_pressed("jump") and is_wall_detected() and get_horizontal_speed() > MIN_SPEED_FOR_WALLRUN:
		transition.emit("WallRunPlayerState")

	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

func set_animation_speed(spd) -> void:
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0,TOP_ANIM_SPEED,alpha)
