class_name PlayerMovementState

extends State

var PLAYER: Player
var ANIMATION: AnimationPlayer
var WEAPON: WeaponController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATIONPLAYER
	WEAPON =  PLAYER.WEAPON_CONTROLLER
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
