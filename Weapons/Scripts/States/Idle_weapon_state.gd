class_name IdleWeaponState
extends WeaponState

func enter(previous_state: WeaponState) -> void:
	#print("Entrando a estado Idle")
	pass

func exit() -> void:
	#print("Saliendo de estado Idle")
	pass
	
func update(delta: float) -> void:
	if !weapon_controller:
		return

	# Detectar input de disparo
	if Input.is_action_just_pressed("Attack"):
		if weapon_controller.can_fire():
			transition.emit("Firing")  # Transición al estado de disparo
		else:
			transition.emit("Empty")  # Transición al estado vacío/recarga

func physics_update(delta: float) -> void:
	pass
