class_name SprintingPlayerState
extends PlayerMovementState


@export var TOP_ANIM_SPEED: float = 1.5
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 10.0

func enter() -> void:
	ANIMATION.play("Sprint",0.5,1.0)
	global.player._speed = global.player.SPEED_SPRINT
	pass

func update(_delta: float) -> void:
	PLAYER.update_gravity(_delta)
	PLAYER.update_input(SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(global.player.velocity.length())
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")

func set_animation_speed(spd) -> void:
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0,TOP_ANIM_SPEED,alpha)
