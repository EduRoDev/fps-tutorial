class_name WeaponStateMachine
extends Node

@export_group("Settings")
@export var weapon_controller: WeaponController
@export var CURRENT_STATE: WeaponState

var STATES: Dictionary = {}

func _ready() -> void:
	# Registrar todos los estados hijos
	for child in get_children():
		if child is WeaponState:
			STATES[child.name] = child
			child.weapon_controller = weapon_controller
			child.transition.connect(_on_child_transition)
		else:
			push_warning("WeaponStateMachine contiene un nodo hijo incompatible: " + child.name)
	
	# Esperar a que el owner esté listo
	await owner.ready
	
	# Entrar al estado inicial
	if CURRENT_STATE:
		CURRENT_STATE.enter(null)

func _process(delta: float) -> void:
	if CURRENT_STATE:
		CURRENT_STATE.update(delta)
		global.debug.add_property("Weapon State",CURRENT_STATE.name,5)

func _physics_process(delta: float) -> void:
	if CURRENT_STATE:
		CURRENT_STATE.physics_update(delta)

func _on_child_transition(new_state_name: StringName) -> void:
	var new_state = STATES.get(new_state_name)
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter(CURRENT_STATE)
			CURRENT_STATE = new_state
	else:
		push_warning("El estado '" + new_state_name + "' no existe")

# Función para cambiar de estado manualmente desde código
func change_state(new_state_name: StringName) -> void:
	_on_child_transition(new_state_name)
