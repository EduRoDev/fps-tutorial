class_name FallingPlayerState
extends PlayerMovementState


@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 7.0

func enter(_previous_state) -> void:
	ANIMATION.pause()
	# Reproducir animación de caída del arma con blend suave
	WEAPON.play_animation("Pistol_JUMP_FALL", 0.2)

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()
	
	
	
	if Input.is_action_just_pressed("hook"):
		transition.emit("GrapplingPlayerState")

	if PLAYER.is_on_floor():
		WEAPON.play_animation("Pistol_JUMP_END")
		transition.emit("IdlePlayerState")
