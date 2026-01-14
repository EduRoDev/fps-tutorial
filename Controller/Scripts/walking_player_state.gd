
class_name WalkingPlayerState
extends PlayerMovementState

@export var TOP_ANIM_SPEED: float = 2.2
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 5.0


func enter() -> void:
	ANIMATION.play("walking", -1.0,1.0)
	global.player._speed = global.player.SPEED

func update(_delta: float) -> void:
	PLAYER.update_gravity(_delta)
	PLAYER.update_input(SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	set_animation_speed(global.player.velocity.length())
	if global.player.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")

func set_animation_speed(spd):
	var alpha = remap(spd,0.0,SPEED,0.0,1.0)
	ANIMATION.speed_scale = lerp(0.0,TOP_ANIM_SPEED,alpha)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint") and global.player.is_on_floor():
		transition.emit("SprintingPlayerState")