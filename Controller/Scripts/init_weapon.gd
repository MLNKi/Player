@tool

class_name WeaponController extends Node3D

signal weapon_fired

@export var WEAPON_TYPE : Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapon()
@export var sway_noise : NoiseTexture2D
@export var sway_speed : float = 1.2
@export var reset : bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapon()

@onready var weapon_mesh : MeshInstance3D = %Weapon
@onready var weapon_shadow : MeshInstance3D = %WeaponShadow

var mouse_movement : Vector2
var random_sway_x : float
var random_sway_y : float
var random_sway_amount : float
var time : float = 0.0
var idle_sway_adjustment : float
var idle_sway_rotation_strength : float
var weapon_bob_ammount : Vector2 = Vector2(0,0)

var raycast_test =  preload("res://Player/Controller/Meshes/Bullets/raycast_test.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	load_weapon()

func _input(event):
	if event.is_action_pressed("Weapon1"):
		WEAPON_TYPE = load("res://Player/Controller/Meshes/Weapons/Crowbar/CrowbarInventory.tres")
		load_weapon()
	if event.is_action_pressed("Weapon2"):
		WEAPON_TYPE = load("res://Player/Controller/Meshes/Weapons/Flashlight/Flashlight.tres")
		load_weapon()
	if event.is_action_pressed("Weapon3"):
		WEAPON_TYPE = load("res://Player/Controller/Meshes/Weapons/Shotgun/Shotgun.tres")
		load_weapon()
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh # Set weapon mesh
	position = WEAPON_TYPE.position # Set weapon position
	rotation_degrees = WEAPON_TYPE.rotation # Set weapon rotation
	scale = WEAPON_TYPE.scale  # Set weapon scale
	weapon_shadow.visible = WEAPON_TYPE.shadow # Turn shadow on/off
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	random_sway_amount = WEAPON_TYPE.random_sway_amount

func sway_weapon(delta, isIdle: bool) -> void:
	# Clamp mouse movement
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)

	if isIdle:
		# Set random sway value from 2D noise
		var sway_random : float = get_sway_noise()
		var sway_random_adjusted : float = sway_random * idle_sway_adjustment # Adjust sway strength

		# Create time with delta and set two sine values for x and y sway movement
		time += delta * (sway_speed + sway_random)
		random_sway_x = sin(time + 1.5 - sway_random_adjusted) / random_sway_amount
		random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
		
		# Lerp weapon position based on mouse movement
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + random_sway_x) * 
		delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + random_sway_y) * 
		delta, WEAPON_TYPE.sway_speed_position)

		# Lerp weapon rotation based on mouse movement
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + 
		(mouse_movement.x * WEAPON_TYPE.sway_amount_rotation + (random_sway_y * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - 
		(mouse_movement.y * WEAPON_TYPE.sway_amount_rotation + (random_sway_x * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
		
	else:
		# Lerp weapon position based on mouse movement
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + weapon_bob_ammount.x) * 
		delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + weapon_bob_ammount.y) * 
		delta, WEAPON_TYPE.sway_speed_position)

		# Lerp weapon rotation based on mouse movement
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + 
		(mouse_movement.x * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - 
		(mouse_movement.y * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
		

func _weapon_bob(delta, bob_speed: float, hbob_amount: float, vbob_amount: float) -> void:
	time += delta
	#Bob_amount ta no WalkingPlayerState
	weapon_bob_ammount.x = sin(time * bob_speed) * hbob_amount
	weapon_bob_ammount.y = abs(cos(time * bob_speed) * vbob_amount)
	
func get_sway_noise() -> float:
	var player_position : Vector3 = Vector3(0, 0, 0)

	# Only access global variable when in-game to avoid constant errors
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position

	var noise_location : float = sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
	return noise_location

func _attack() -> void:
	weapon_fired.emit()
	var camera = Global.player.CAMERA_CONTROLLER
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	if result:
		_bullet_hole(result.get("position"), result.get("normal"))

func _bullet_hole(hit_position: Vector3, normal: Vector3) -> void:
	var instance = raycast_test.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = hit_position
	instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
	#if normal != Vector3.UP and  normal != Vector3.DOWN:
	instance.rotate_object_local(Vector3(1,0,0), 90)
	var fade = get_tree().create_tween()
	#10 é o tempo de fade do bullet decal
	fade.tween_property(instance, "modulate:a", 0, 15)
	await get_tree().create_timer(15.0).timeout
	instance.queue_free()
