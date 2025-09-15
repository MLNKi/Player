extends RayCast3D

var interact_cast_result
var current_cast_result

func _process(delta):
	interact_cast()

func _input(event):
	if event.is_action_pressed("Interact"):
		interact()

func interact_cast():
	current_cast_result = get_collider()
	
	if current_cast_result != interact_cast_result:
		# Handle previous object losing focus
		if interact_cast_result and interact_cast_result.has_signal("unfocused"):
			interact_cast_result.emit_signal("unfocused")
		
		interact_cast_result = current_cast_result
		
		# Handle new object gaining focus
		if interact_cast_result and interact_cast_result.has_signal("focused"):
			interact_cast_result.emit_signal("focused")
		elif not interact_cast_result:
			# No object in focus, reset UI
			MessageBus.interaction_unfocused.emit()

func interact() -> void:
	if interact_cast_result and interact_cast_result.has_signal("interacted"):
		interact_cast_result.emit_signal("interacted")
