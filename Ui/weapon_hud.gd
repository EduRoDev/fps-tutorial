class_name WeaponHUD
extends Control

@onready var weapon_name_label: Label = $MarginContainer/VBoxContainer/WeaponName
@onready var current_ammo_label: Label = $MarginContainer/VBoxContainer/AmmoCounter/CurrentAmmo
@onready var max_ammo_label: Label = $MarginContainer/VBoxContainer/AmmoCounter/MaxAmmo
@onready var separator_label: Label = $MarginContainer/VBoxContainer/AmmoCounter/Separator
@onready var margin_container: MarginContainer = $MarginContainer
@onready var ammo_container: HBoxContainer = $MarginContainer/VBoxContainer/AmmoCounter

@onready var slot_panels: Array[PanelContainer] = [
	$MarginContainer/VBoxContainer/WeaponSlots/Slot1,
	$MarginContainer/VBoxContainer/WeaponSlots/Slot2,
	$MarginContainer/VBoxContainer/WeaponSlots/Slot3,
	$MarginContainer/VBoxContainer/WeaponSlots/Slot4
]

# Colores del tema
var primary_color: Color = Color("#00D9FF")  # Cyan brillante
var secondary_color: Color = Color("#FF6B00")  # Naranja
var danger_color: Color = Color("#FF3333")  # Rojo
var warning_color: Color = Color("#FFD700")  # Dorado
var background_color: Color = Color(0, 0, 0, 0.7)

var ammo_flash_time: float = 0.0
var is_flashing: bool = false

func _ready() -> void:
	setup_styles()
	update_hud()

func _process(delta: float) -> void:
	update_hud()
	
	# Efecto de parpadeo cuando no hay munición
	if is_flashing:
		ammo_flash_time += delta * 5.0
		var flash_alpha: float = (sin(ammo_flash_time) + 1.0) / 2.0
		current_ammo_label.modulate.a = 0.5 + (flash_alpha * 0.5)

func setup_styles() -> void:
	# Estilo para el nombre del arma
	weapon_name_label.add_theme_font_size_override("font_size", 28)
	weapon_name_label.add_theme_color_override("font_color", primary_color)
	weapon_name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	weapon_name_label.add_theme_constant_override("outline_size", 2)
	
	# Estilo para munición actual (grande y llamativo)
	current_ammo_label.add_theme_font_size_override("font_size", 48)
	current_ammo_label.add_theme_color_override("font_outline_color", Color.BLACK)
	current_ammo_label.add_theme_constant_override("outline_size", 4)
	
	# Estilo para separador
	separator_label.add_theme_font_size_override("font_size", 48)
	separator_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	
	# Estilo para munición máxima
	max_ammo_label.add_theme_font_size_override("font_size", 36)
	max_ammo_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	max_ammo_label.add_theme_color_override("font_outline_color", Color.BLACK)
	max_ammo_label.add_theme_constant_override("outline_size", 2)

func update_hud() -> void:
	if not Managers.weapon_manager:
		return
	
	var weapon_manager = Managers.weapon_manager
	var current_slot = weapon_manager.current_weapon_slot
	var weapon_data = weapon_manager.weapons.get(current_slot)
	
	if weapon_data and weapon_data.weapon:
		weapon_name_label.text = weapon_data.weapon.weapon_name.to_upper()
		current_ammo_label.text = str(weapon_data.ammo)
		max_ammo_label.text = str(weapon_data.weapon.max_ammo)
		
		# Sistema de colores dinámico
		var ammo_percentage: float = float(weapon_data.ammo) / float(weapon_data.weapon.max_ammo)
		
		if weapon_data.ammo == 0:
			current_ammo_label.add_theme_color_override("font_color", danger_color)
			is_flashing = true
		elif ammo_percentage <= 0.25:
			current_ammo_label.add_theme_color_override("font_color", warning_color)
			is_flashing = false
			current_ammo_label.modulate.a = 1.0
		else:
			current_ammo_label.add_theme_color_override("font_color", Color.WHITE)
			is_flashing = false
			current_ammo_label.modulate.a = 1.0
	
	update_weapon_slots(current_slot)

func update_weapon_slots(current_slot: int) -> void:
	for i in range(slot_panels.size()):
		var slot_index = i + 1
		var panel: PanelContainer = slot_panels[i]
		
		if not panel:
			continue
		
		# Añadir label de número si no existe
		if panel.get_child_count() == 0:
			var slot_label: Label = Label.new()
			slot_label.text = str(slot_index)
			slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			slot_label.add_theme_font_size_override("font_size", 20)
			slot_label.add_theme_color_override("font_outline_color", Color.BLACK)
			slot_label.add_theme_constant_override("outline_size", 2)
			panel.add_child(slot_label)
			panel.custom_minimum_size = Vector2(50, 50)
		
		var weapon_data = Managers.weapon_manager.weapons.get(slot_index)
		
		if slot_index == current_slot:
			panel.add_theme_stylebox_override("panel", get_active_slot_style())
			if panel.get_child_count() > 0:
				panel.get_child(0).add_theme_color_override("font_color", primary_color)
		else:
			panel.add_theme_stylebox_override("panel", get_inactive_slot_style())
			if panel.get_child_count() > 0:
				panel.get_child(0).add_theme_color_override("font_color", Color.WHITE)
		
		if weapon_data and weapon_data.unlocked:
			panel.modulate = Color.WHITE
		else:
			panel.modulate = Color(0.3, 0.3, 0.3, 0.5)

func get_active_slot_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(primary_color.r, primary_color.g, primary_color.b, 0.3)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = primary_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	# Efecto de brillo
	style.shadow_color = Color(primary_color.r, primary_color.g, primary_color.b, 0.5)
	style.shadow_size = 5
	return style

func get_inactive_slot_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5, 0.8)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style