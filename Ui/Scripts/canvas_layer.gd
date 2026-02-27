extends CanvasLayer


@onready var round_label: Label = %Round
@onready var enemies_label: Label = %Enemys

func _ready() -> void:
	var spawner: Node = get_tree().get_first_node_in_group("Spawner")
	if spawner: 
		spawner.round_changed.connect(_on_round_changed)
		spawner.enemy_counter_changed.connect(_on_enemy_count_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_round_changed(new_round: int) -> void:
	round_label.text = "Ronda: " + str(new_round)

func _on_enemy_count_changed(count: int) -> void:
	enemies_label.text = "Enemigos: " + str(count)