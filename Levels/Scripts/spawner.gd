extends Node

@export var enemies: Array[PackedScene]
@export var spawn_time: float
@export var spawn_amount: int
@export var spawn_position: Array[Marker3D]


func _ready() -> void:
	start_spawning()
	
func start_spawning() -> void:
	for x in spawn_amount:
		await get_tree().create_timer(spawn_time).timeout
		instancie_enemies()
		
func instancie_enemies() -> void:
	var enemy = enemies.pick_random().instantiate()
	enemy.position = spawn_position.pick_random().global_position
	get_parent().add_child(enemy)
