class_name EnemySpawner
extends Node3D

@export var round_enemy:int = 5
@onready var timer: Timer = %SpawnTimer
var enemy: PackedScene = preload("res://Controller/Enemies/enemy.tscn")


signal round_changed(new_round)
signal enemy_counter_changed(count)


var round_number: int = 1
var enemies_per_round: int = 5
var enemies_spawned: int = 0
var round_active: bool = false

func _ready() -> void:
	add_to_group("Spawner")
	await get_tree().process_frame
	start_round()

func start_round() -> void:
	enemies_spawned = 0
	round_active = true
	round_enemy = enemies_per_round * round_number 
	timer.start()
		
	round_changed.emit(round_number)
	update_ui_enemies()

func _on_spawn_timer_timeout() -> void:
	if not round_active:
		timer.stop()
		return

	if enemies_spawned >= round_enemy:
		timer.stop()
		round_active = false
		round_number += 1
		print("Ronda terminada. Próxima: ", round_number)
		return

	var n_enemy: Node = enemy.instantiate()
	n_enemy.add_to_group("Enemy")
	get_tree().current_scene.add_child(n_enemy)
	n_enemy.global_position = global_position
	enemies_spawned += 1
	
	update_ui_enemies()
				
func check_round_end() -> void:
	update_ui_enemies()
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("Enemy").size() == 0 and !round_active:
		start_round()

func update_ui_enemies() -> void: 
	var count: int = get_tree().get_nodes_in_group("Enemy").size()
	enemy_counter_changed.emit(count)