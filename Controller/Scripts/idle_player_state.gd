extends PlayerMovementState
class_name IdlePlayerState

@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED: float = 5.0

func enter(_previous_state) -> void:

	ANIMATION.pause()
	WEAPON.play_animation("Pistol_IDLE", 0.25)

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input( SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	WEAPON.sway_weapon(delta, true)
	if Input.is_action_pressed("crouch"):
		transition.emit("CrouchingPlayerState")

	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")

	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpPlayerState")

	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

	if Input.is_action_just_pressed("Attack"):
		WEAPON.attack()

	if Input.is_action_just_pressed("hook"):
		transition.emit("GrapplingPlayerState")
