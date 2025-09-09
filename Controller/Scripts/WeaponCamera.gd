extends Camera3D

@export var MAIN_CAMERA : Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_transform = MAIN_CAMERA.global_transform
