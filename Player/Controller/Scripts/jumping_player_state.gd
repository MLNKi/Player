class_name JumpingPlayerState extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var JUMP_VELOCITY: float = 6.5
@export var DOUBLE_JUMP_VELOCITY: float = 8
@export_range(0.5, 1.0, 0.01) var INPUT_MULTIPLIER: float = 0.85
@export var WEAPON_BOB_SPD : float = 5.0
@export var WEAPON_BOB_H : float = 3.0
@export var WEAPON_BOB_V : float = 1.0

var DOUBLE_JUMP: bool = false

func enter(previous_state) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.play("JumpStart")

func exit() -> void:
	DOUBLE_JUMP = false

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON._weapon_bob(delta, WEAPON_BOB_SPD, WEAPON_BOB_H, WEAPON_BOB_V)
	
	# Double jump check - use a short delay after initial jump
	if Input.is_action_just_pressed("Jump") and DOUBLE_JUMP == false and PLAYER.velocity.y < 0:
		DOUBLE_JUMP = true
		PLAYER.velocity.y = DOUBLE_JUMP_VELOCITY
	
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
	
	if Input.is_action_just_released("Jump"):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y / 15.0
	
	if PLAYER.is_on_floor():
		ANIMATION.play("JumpEnd")
		transition.emit("IdlePlayerState")
	
	if Input.is_action_just_pressed("Attack"):
		WEAPON._attack()
