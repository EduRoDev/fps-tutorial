extends Node3D

@export var rope : Node3D 
@export var rope_mesh : MeshInstance3D 
@export var rope_visial_end : Marker3D 
@export var hook_end : Node3D
@export var time_to_reach_hook: int = 5

var distance_to_go: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	
func wiggle_rope():
	rope_mesh.material_override.set_shader_parameter("active",1.0)
	await get_tree().create_timer(0.5).timeout
	rope_mesh.material_override.set_shader_parameter("active",0.0)

func extend_from_to(
	source_position: Vector3, 
	target_position: Vector3,
	target_normal: Vector3,
	_delta: float
) -> void:
	hook_end.global_position = target_position
	_align_hook_end_with_surface(target_normal)
	global_position = source_position
	var visual_target_position: Vector3 = _get_visual_target(target_position)
	var distance_to_target = global_position.distance_to(visual_target_position)
	distance_to_go = lerpf(distance_to_go, distance_to_target, _delta * time_to_reach_hook)
	rope_mesh.mesh.height = distance_to_go
	rope_mesh.position.z = -distance_to_go / 2
	
	rope.look_at(visual_target_position)


func _align_hook_end_with_surface(target_normal: Vector3) -> void:
	if target_normal.dot(Vector3.UP) > 0.001 or target_normal.y < 0:
		if target_normal.y > 0:
			hook_end.rotation_degrees.x = -90
		
		elif target_normal.y < 0:
			hook_end.rotation_degrees.x = 90
	
	else:
		hook_end.look_at(hook_end.global_position - target_normal)

func _get_visual_target(default_value: Vector3) -> Vector3:
	if rope_visial_end:
		return rope_visial_end.global_position
	
	else:
		return default_value
