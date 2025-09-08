class_name StateMachine

extends Node

@export var CURRENT_STATE : State
var states : Dictionary = {}
var previous_state

#Essa função identifica, nomeia e categoriza novos state child for the player
#Se não um warning aparece
func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("STATE MACHINE CONTAINS INCOMPATIBLE CHILD NODE")
		
	await owner.ready
	CURRENT_STATE.enter(previous_state)

func _process(delta):
	CURRENT_STATE.update(delta)
	Global.debug.add_property("CurrentState", CURRENT_STATE.name, 1)

func _physics_process(delta):
	CURRENT_STATE._physics_update(delta)

#Double check de transição de states e correção dos nomes
func on_child_transition(new_state_name: StringName):
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter(CURRENT_STATE)
			CURRENT_STATE = new_state
	else:
		push_warning("STATE DOES NOT EXIST")
