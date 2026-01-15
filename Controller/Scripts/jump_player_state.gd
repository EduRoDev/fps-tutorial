class_name JumpPlayerState
extends PlayerMovementState

@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 7.0
@export var JUMP_VELOCITY: float = 3
@export_range(0.5,1.0,0.01) var INPUT_MULTIPLIER: float = 1.01

func enter(_previous_state) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.pause()

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")