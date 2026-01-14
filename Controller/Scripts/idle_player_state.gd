extends PlayerMovementState
class_name IdlePlayerState

@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 5.0

func enter() -> void:
	ANIMATION.pause()


func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input( SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	if global.player.velocity.length() > 0.0 and global.player.is_on_floor():
		transition.emit("WalkingPlayerState")
