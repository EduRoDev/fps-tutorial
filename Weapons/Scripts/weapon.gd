class_name Weapon extends Resource

@export_group("Settings")
@export var weapon_name: String
@export var damage: float 
@export var max_ammo: int
@export var weapon_model: PackedScene
@export var weapon_position: Vector3

@export_group("Fire Settings")
@export var fire_rate: float = 0.2  # Tiempo entre disparos
@export var is_automatic: bool = false  # Si es automática o semi-auto
@export var reload_time: float = 1.5  # Tiempo de recarga
@export var range: float = 25.0  # Alcance del arma
@export var bullet_scene: PackedScene  # Escena de la bala