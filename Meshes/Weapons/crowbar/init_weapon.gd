@tool
class_name WeaponController
extends Node3D

@export var WEAPON_TYPE: Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapons()

@export var sway_noise: NoiseTexture2D
@export var sway_speed: float = 1.2
@export var reset: bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapons()

@onready var weapon_mesh: MeshInstance3D = $WeaponMesh
@onready var weapon_shadow: MeshInstance3D = $ShadowMesh
@onready var scene_container: Node3D = $WeaponsContainer

var mouse_movement: Vector2
var random_sway_x
var random_sway_y
var random_sway_amount: float
var time: float = 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength
var bob_weapon_amount: Vector2 = Vector2(0, 0)

var raycast_test = preload("res://Meshes/Weapons/DesertEagle/bullet_test.tscn")
var is_shooting: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon1"):
		WEAPON_TYPE = load("res://Meshes/Weapons/DesertEagle/Desert.tres")
		load_weapons()
	if event.is_action_pressed("weapon2"):
		WEAPON_TYPE = load("res://Meshes/Weapons/pistol_with_arms/pistol.tres")
		load_weapons()
	if event.is_action_pressed("weapon3"):
		WEAPON_TYPE = load("res://Meshes/Weapons/crowbar/crowbar.tres")
		load_weapons()
		
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func _ready() -> void:
	if not Engine.is_editor_hint() and owner:
		await owner.ready
	load_weapons()

func load_weapons():
	if not WEAPON_TYPE:
		return
	
	for child in scene_container.get_children():
		child.queue_free()

	if WEAPON_TYPE.weapon_scene != null:
		var instance = WEAPON_TYPE.weapon_scene.instantiate()
		scene_container.add_child(instance)
		weapon_mesh.visible = false
		weapon_shadow.visible = false
		
		if Engine.is_editor_hint():
			instance.owner = get_tree().edited_scene_root
	
	else:
		weapon_mesh.visible = true
		weapon_mesh.mesh = WEAPON_TYPE.mesh

	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	scale = WEAPON_TYPE.scale

	if weapon_shadow:
		weapon_shadow.visible = WEAPON_TYPE.shadow
		
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	random_sway_amount = WEAPON_TYPE.random_sway_amount
		
func sway_weapon(delta, isIdel: bool) -> void:
	if Engine.is_editor_hint():
		return
	
	
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	if isIdel:
		var sway_random: float = get_sway_noise()
		var sway_random_adjusted: float = sway_random * idle_sway_adjustment
	
		time += delta * (sway_speed + sway_random)
		random_sway_x = sin(time * 1.5 + sway_random_adjusted) / random_sway_amount
		random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
		
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + random_sway_x) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + random_sway_y) * delta, WEAPON_TYPE.sway_speed_position)
	
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation + (random_sway_y * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_position)
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation + (random_sway_x * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_position)
	
	else:
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + bob_weapon_amount.x) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + bob_weapon_amount.y) * delta, WEAPON_TYPE.sway_speed_position)
	
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_position)
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_position)
	
	
func weapon_bob(delta, bob_speed: float, hbob_amount: float, vbob_amount: float) -> void:
	time += delta
	bob_weapon_amount.x = sin(time * bob_speed) * hbob_amount
	bob_weapon_amount.y = abs(cos(time * bob_speed) * vbob_amount)

func get_sway_noise() -> float:
	var player_position: Vector3 = Vector3(0, 0, 0)
	if !Engine.is_editor_hint():
		player_position = global.player.global_position
		
	var noise_location: float = sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
	return noise_location

func play_animation(anim_name: String, blend: float = -1.0, speed: float = 1.0) -> void:
	if scene_container.get_child_count() > 0:
		var anim = scene_container.get_child(0).get_node_or_null("AnimationPlayer")
		if anim and anim.has_animation(anim_name):
			anim.play(anim_name, blend, speed)

func get_animation_player() -> AnimationPlayer:
	if scene_container.get_child_count() > 0:
		return scene_container.get_child(0).get_node_or_null("AnimationPlayer")
	return null


func attack() -> void:
	var camera = global.player.CAMERA_CONTROLLER
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = camera.get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	if result and (WEAPON_TYPE.category == "Pistol" or WEAPON_TYPE.category == "Rifle"):
		if scene_container.get_child_count() > 0 and WEAPON_TYPE.name == "pistol":
			var anim = scene_container.get_child(0).get_node_or_null("AnimationPlayer")
			if anim:
				anim.play("Pistol_FIRE")
				_fire_raycast(result.get("position"), result.get("normal"))
		if WEAPON_TYPE.name == "Desert":
			_fire_raycast(result.get("position"), result.get("normal"))

func _fire_raycast(positionray: Vector3, normalray: Vector3) -> void:
	var instances = raycast_test.instantiate()
	get_tree().root.add_child(instances)
	instances.global_position = positionray + (normalray * 0.01)

	if normalray.is_equal_approx(Vector3.UP):
		instances.look_at(instances.global_position + normalray, Vector3.RIGHT)
	else:
		instances.look_at(instances.global_position + normalray, Vector3.UP)

	await get_tree().create_timer(2).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(instances, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	instances.queue_free()
