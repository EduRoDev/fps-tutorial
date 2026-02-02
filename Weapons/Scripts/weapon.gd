class_name Weapon extends Resource

@export_group("Settings")
@export var weapon_name: String
@export var damage: float 
@export var max_ammo: int
@export var weapon_model: PackedScene
@export var weapon_position: Vector3
@export var category: Category

@export_group("Fire Settings")
@export var fire_rate: float = 2.0
@export var is_automatic: bool = false
@export var reload_time: float = 1.5
@export_range(0.0, 100.0) var base_accuracy: float = 100.0  
@export var accuracy_penalty_per_shot: float = 5.0  
@export var accuracy_recovery_rate: float = 20.0  
@export var min_accuracy: float = 30.0  
@export var rango: float = 25.0
@export var bullet_speed: float = 25.0
@export var bullet_scene: PackedScene

@export_group("Shotgun settings")
@export var pellets: int = 8
@export var spread: float = 5.0

enum Category {
	PISTOL,
	RIFLE,
	SHOTGUN,
	SNIPER,
	SMG
}