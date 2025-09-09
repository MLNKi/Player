class_name Player extends CharacterBody3D

#Poderia ter sido @export
#const SPEED_DEFAULT : float = 5.0 #Caminhar
const SPEED_CROUCH : float = 3.0
const JUMP_VELOCITY = 6.5

#@exports de qualidade de vida
@export var MOUSE_SENSITIVITY : float = 0.3
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : Node3D
@export var WEAPON_CONTROLLER : WeaponController

#variaveis de interação
@export var interact_distance : float = 2

#Essas variáveis são somente para controle e olhar do Player
#var _speed : float
var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _current_rotation : float
var interact_cast_result

# Get the gravity from the project settings
var gravity = 11


func _ready():
	#Player referenciado no script GLOBAL
	Global.player = self
	#Captura o mouse ao rodar a cena
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Velocidade, Andar/Agachar/Correr
	#_speed = SPEED_DEFAULT
	#Detecção de colisão ao agachar para o CharacterBody3D
	CROUCH_SHAPECAST.add_exception($".")
	
func _input(event):
	#Esc no InputMap sai da cena rodando
	if event.is_action_pressed("Exit"):
		get_tree().quit()
	if event.is_action_pressed("Interact"):
		interact()
		
func _unhandled_input(event):
	#Esses Inputs só são para rotação do mouse de modo geral
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input: 
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

func update_camera(delta) -> void:
	_current_rotation = _rotation_input
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)

	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0

#Essa função em conjunto com "var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")"
#permite movimentação básica, já vem com o CharacterBody3D

func _physics_process(delta):
	#Referenciado em "func add_property" em debug.gd
	Global.debug.add_property("Velocity","%.2f" % velocity.length(), 2)

	update_camera(delta)
	interact_cast()
	
func update_gravity(delta):
	velocity.y -= gravity * delta

func update_input(SPEED: float, ACCELERATION: float, DECELERATION: float):
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backwards")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * SPEED, DECELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.z = move_toward(velocity.z, 0, DECELERATION)
		
func update_velocity():
	move_and_slide()

func interact_cast() -> void:
	var camera = Global.player.CAMERA_CONTROLLER
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * interact_distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	var current_cast_result = result.get("collider")
	if current_cast_result != interact_cast_result:
		if interact_cast_result and interact_cast_result.has_user_signal("unfocused"):
			interact_cast_result.emit_signal("unfocused")
		interact_cast_result = current_cast_result
		if interact_cast_result and interact_cast_result.has_user_signal("focused"):
			interact_cast_result.emit_signal("focused")

func interact() -> void:
	if interact_cast_result and interact_cast_result.has_user_signal("interacted"):
		interact_cast_result.emit_signal("interacted")
