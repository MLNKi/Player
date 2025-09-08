class_name WalkingPlayerState extends PlayerMovementState

@export var SPEED: float = 4.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.3
@export var TOP_ANIM_SPEED : float = 1.4
@export var WEAPON_BOB_SPD : float = 5.0
@export var WEAPON_BOB_H : float = 3.0
@export var WEAPON_BOB_V : float = 1.0

func enter(previous_state):
	ANIMATION.play("Walking", -1.0, 1.0)

func exit():
	ANIMATION.speed_scale = 1.0

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false)
	WEAPON._weapon_bob(delta, WEAPON_BOB_SPD, WEAPON_BOB_H, WEAPON_BOB_V)
	
	set_animation_speed(PLAYER.velocity.length())
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
	
func set_animation_speed(spd):
	var alpha  = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)

func _input(event):
	if event.is_action_pressed("Sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")
		
	if Input.is_action_just_pressed("Crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
		
	if Input.is_action_just_pressed("Jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
	
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
	
	if Input.is_action_just_pressed("Attack"):
		WEAPON._attack()
