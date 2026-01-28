class_name EmptyWeaponState
extends WeaponState

func enter(previous_state: WeaponState) -> void:
	#print("Entrando a estado Empty - Sin munición!")
	# Aquí puedes reproducir sonido de arma vacía
	#if weapon_controller:
		#weapon_controller.onEmpty.emit()
	pass
	
func exit() -> void:
	#print("Saliendo de estado Empty")
	pass
	
func update(delta: float) -> void:
	if !weapon_controller:
		return
	
	# Si presiona recargar, ir al estado de recarga
	if Input.is_action_just_pressed("Reload"):
		transition.emit("Reloading")
	
	# Si de alguna manera tiene munición (pickup, etc), volver a idle
	if weapon_controller.can_fire():
		transition.emit("Idle")

func physics_update(delta: float) -> void:
	pass
