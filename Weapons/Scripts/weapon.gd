class_name Weapon extends Resource

@export_group("Settings")
@export var weapon_name: String
@export var damage: float 
@export var max_ammo: int
@export var weapon_model: PackedScene
@export var weapon_position: Vector3
@export var category: Category

@export_group("Fire Settings")
@export var fire_rate: float = 2.0  # Tiempo entre disparos
@export var is_automatic: bool = false  # Si es automática o semi-auto
@export var reload_time: float = 1.5  # Tiempo de recarga
@export_range(0.0,100.0) var accuracy: float = 90.0  # Precisión del arma (0-100)
@export var rango: float = 25.0  # Alcance del arma
@export var bullet_speed: float = 25.0  # Velocidad de la bala
@export var bullet_scene: PackedScene  # Escena de la bala

@export_group("Shotgun settings")
@export var pellets: int = 8  # Número de perdigones
@export var spread: float = 5.0  # Dispersión de los perdigones

enum Category {
	PISTOL,
	RIFLE,
	SHOTGUN,
	SNIPER,
	SMG
}