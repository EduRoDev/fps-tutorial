class_name WeaponManager extends Node

@export_group("References")
@export var weapons: Dictionary[int, WeaponData] = {}
@export var player: Player 

var current_weapon_slot: int = 1

func _ready() -> void:
	add_to_group("weapons_manager")
	
	for i in range(1,5):
		var action_name: String = "weapon_" + str(i)
		if !InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var event: InputEventKey = InputEventKey.new()
			event.keycode = KEY_1 + (i - 1) 
			InputMap.action_add_event(action_name,event)

func _unhandled_input(event: InputEvent) -> void:
	for i in range(1,5):
		if event.is_action("weapon_" + str(i)):
			switch_to_slot(i)

func switch_to_slot(slot:int) -> void:
	var weapon_data = weapons.get(slot)
	if weapon_data and weapon_data.unlocked:
		current_weapon_slot = slot
		player.WEAPON_CONTROLLER.switch_weapon(weapon_data)
	
func use_ammo(slot: int, amount: int = 1) -> void:
	if slot in weapons:
		weapons[slot].ammo = max(0,weapons[slot].ammo - amount)
		
func get_current_ammo() -> int:
	return weapons[current_weapon_slot].ammo
	
