class_name EnemySpawner
extends Node3D

@export var round_enemy:int = 5
@onready var timer: Timer = %SpawnTimer
var enemy: PackedScene = preload("res://Controller/Enemies/enemy.tscn")

var round_number: int = 1
var enemies_per_round: int = 5
var enemies_spawned: int = 0
var round_active: bool = false

func _ready() -> void:
	add_to_group("Spawner")
	start_round()

func start_round() -> void:
	enemies_spawned = 0
	round_active = true
	round_enemy = enemies_per_round * round_number  # escala con la ronda
	timer.start()
	print("Ronda ", round_number, " iniciada - Enemigos: ", round_enemy)

func _on_spawn_timer_timeout() -> void:
	if not round_active:
		timer.stop()
		return

	if enemies_spawned >= round_enemy:
		# Terminó de spawnear esta ronda
		timer.stop()
		round_active = false
		round_number += 1
		print("Ronda terminada. Próxima: ", round_number)
		return

	# Instancia UNA copia nueva por cada tick del timer
	var n_enemy: Node = enemy.instantiate()
	n_enemy.add_to_group("Enemy")
	get_tree().current_scene.add_child(n_enemy)
	n_enemy.global_position = global_position
	enemies_spawned += 1
	print("Spawn #", enemies_spawned, " en: ", n_enemy.global_position)
			
func check_round_end() -> void:
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("Enemy").size() == 0 and !round_active:
		start_round()
