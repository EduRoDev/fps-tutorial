class_name WeaponState
extends Node

signal transition(new_state_name: StringName)

var weapon_controller: WeaponController

# Llamado cuando se entra a este estado
func enter(previous_state: WeaponState) -> void:
	pass

# Llamado cuando se sale de este estado
func exit() -> void:
	pass

# Llamado cada frame (conectar a _process)
func update(delta: float) -> void:
	pass

# Llamado cada frame de física (conectar a _physics_process)
func physics_update(delta: float) -> void:
	pass
