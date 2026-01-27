@tool
extends Node3D
class_name ChainDinamic

@export_group("Chain setup")
@export_range(2,50) var link_count: int = 10:
	set(value):
		link_count = value
		if Engine.is_editor_hint():
			_regenerate_chain()
			
@export var link_length: float = 0.3:
	set(value):
		link_length = value
		if Engine.is_editor_hint():
			_regenerate_chain()
			
@export var link_radius: float = 0.05:
	set(value):
		link_radius = value
		if Engine.is_editor_hint():
			_regenerate_chain()

@export_group("Join Settings")
@export var angular_limit_degrees: float = 30.0
@export var twist_limit_degrees:float = 15.0

@export_group("Physics properties")
@export var link_mass: float = 0.5
@export var gravity_scale: float = 1.0
@export var link_damping: float = 0.5

@export_group("Collision")
@export_flags_3d_physics var link_collision_layer: int = 1
@export_flags_3d_physics var link_collision_mask: int = 1

@export var anchor: StaticBody3D
@export var link_container: Node3D


var links: Array[RigidBody3D] = []
var joints: Array[Generic6DOFJoint3D] = []


func _clear_chain():
	for link in links:
		if is_instance_valid(link):
			link.queue_free()
	links.clear()
	joints.clear()
			
	for child in link_container.get_children():
		child.queue_free()

func _regenerate_chain():
	if Engine.is_editor_hint():
		_clear_chain()
		await get_tree().process_frame
		_create_rope()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_rope()


func _create_rope() -> void:
	_clear_chain()
	
	for i in range(link_count):
		var link = _create_link(i)
		link_container.add_child(link)
		links.append(link)
		link.position = Vector3(0, -(i+1) * link_length, 0)
	

	await get_tree().process_frame
	
	for i in range(link_count):
		var body_a = anchor if i == 0 else links[i - 1]
		var body_b = links[i]
		
		var joint = _create_join(body_a,body_b)
		body_b.add_child(joint)
		joints.append(joint)
		

func _create_link(index:int) -> RigidBody3D:
	var link = RigidBody3D.new()
	link.name = "link " + str(index)
	
	# Fisicas 
	link.mass = link_mass
	link.gravity_scale = gravity_scale
	link.linear_damp = link_damping
	link.angular_damp = link_damping
	link.collision_layer = link_collision_layer
	link.collision_mask = link_collision_mask
	
	# Textura 
	var mesh_instances = MeshInstance3D.new()
	var Cylinder = CylinderMesh.new()
	
	Cylinder.height = link_length
	Cylinder.top_radius = link_radius
	Cylinder.bottom_radius = link_radius
	mesh_instances.mesh = Cylinder
	link.add_child(mesh_instances)
	
	# Colision
	var colision_shape = CollisionShape3D.new()
	var Shape = CylinderShape3D.new()
	
	Shape.height = link_length
	Shape.radius = link_radius
	colision_shape.shape = Shape
	link.add_child(colision_shape)
	
	return link

@warning_ignore("unused_parameter")
func _create_join(body_a: Node3D, body_b:RigidBody3D) -> Generic6DOFJoint3D:
	var joint = Generic6DOFJoint3D.new()
	joint.name = "Joint_to_"+ body_a.name
	joint.position = Vector3(0,link_length * 0.5, 0)
	
	var angular_limit_rad = deg_to_rad(angular_limit_degrees)
	var twist_limit_rad = deg_to_rad(twist_limit_degrees)
	
	joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT,true)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT,0)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT,0)
	
	joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT,true)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT,0)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT,0)
	
	joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT,true)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT,0)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT,0)
	
	joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT,true)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT,-angular_limit_rad)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT,angular_limit_rad)
	
	joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT,true)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT,-twist_limit_rad)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT,twist_limit_rad)
	
	joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT,true)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT,-angular_limit_rad)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT,angular_limit_rad)
	
	joint.ready.connect(func():
		joint.node_a = joint.get_path_to(body_a)
		joint.node_b = NodePath("..")
	)
	
	return joint
	
