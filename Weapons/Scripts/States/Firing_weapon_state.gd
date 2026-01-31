class_name FiringWeaponState
extends WeaponState

var fire_timer: float = 0.0

func enter(previous_state: WeaponState) -> void:
	#print("Entrando a estado Firing")
	fire_timer = 0.0
	
	# Ejecutar el disparo
	if weapon_controller:
		weapon_controller.fire_weapon()

func exit() -> void:
	#print("Saliendo de estado Firing")
	pass

func update(delta: float) -> void:
	if !weapon_controller:
		return
	
	# Esperar el tiempo entre disparos (fire rate)
	fire_timer += delta
	
	var fire_rate: float = weapon_controller.current_weapon.fire_rate if weapon_controller.current_weapon else 0.2
	
	if fire_timer >= fire_rate:
		# Si sigue presionando y es automático, seguir disparando
		if Input.is_action_pressed("Attack") and weapon_controller.can_fire():
			# Para armas automáticas, reiniciar el timer y disparar de nuevo
			if weapon_controller.current_weapon and weapon_controller.current_weapon.is_automatic:
				fire_timer = 0.0
				weapon_controller.fire_weapon()
			else:
				# Para armas semi-automáticas, volver a idle
				transition.emit("Idle")	
		elif !weapon_controller.can_fire():
			# Sin munición, ir a estado vacío
			transition.emit("Empty")
		else:
			# Volver a idle
			transition.emit("Idle")

func physics_update(delta: float) -> void:
	pass
