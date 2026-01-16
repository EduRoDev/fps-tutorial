
class_name WalkingPlayerState
extends PlayerMovementState

@export var TOP_ANIM_SPEED: float = 2.2
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 5.0


func enter(_previous_state) -> void:
	ANIMATION.play("walking", -1.0,1.0)
	

func update(_delta: float) -> void:
	PLAYER.update_gravity(_delta)
	PLAYER.update_input(SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	set_animation_speed(PLAYER.velocity.length())
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")

	if Input.is_action_pressed("crouch"):
		transition.emit("CrouchingPlayerState")

	if Input.is_action_pressed("sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")

	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpPlayerState")

	if PLAYER.velocity.y < -1.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

func set_animation_speed(spd):
	var alpha = remap(spd,0.0,SPEED,0.0,1.0)
	ANIMATION.speed_scale = lerp(0.0,TOP_ANIM_SPEED,alpha)

	
