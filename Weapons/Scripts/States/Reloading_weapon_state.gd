class_name ReloadingWeaponState
extends WeaponState

var reload_timer: float = 0.0

func enter(previous_state: WeaponState) -> void:
	#print("Entrando a estado Reloading")
	reload_timer = 0.0
	# Aquí puedes iniciar la animación de recarga

func exit() -> void:
	#print("Saliendo de estado Reloading")
	pass

func update(delta: float) -> void:
	if !weapon_controller:
		return
	
	reload_timer += delta
	
	# Obtener tiempo de recarga del arma actual
	var reload_time: float = weapon_controller.current_weapon.reload_time if weapon_controller.current_weapon else 1.5
	
	if reload_timer >= reload_time:
		# Completar la recarga
		complete_reload()
		transition.emit("Idle")

func complete_reload() -> void:
	if weapon_controller and weapon_controller.current_weapon and Managers.weapon_manager:
		var current_slot = Managers.weapon_manager.current_weapon_slot	
		var weapon_data = Managers.weapon_manager.weapons.get(current_slot)
		
		if weapon_data: 
			weapon_data.ammo = weapon_data.weapon.max_ammo
			weapon_controller.current_ammo = weapon_data.ammo
			print("Recarga completa! Munición: ", weapon_data.ammo)

func physics_update(delta: float) -> void:
	pass
