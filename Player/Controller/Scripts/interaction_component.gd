class_name InteractionComponent extends Node

signal player_interacted(object)

@export var mesh : MeshInstance3D
@export var context : String
@export var override_icon : bool
@export var new_icon : Texture2D

var parent
var highlight_material = preload("res://Player/Controller/Meshes/TestInteraction/interactable_highlight.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	connect_parent()
	set_default_mesh()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func in_range() -> void:
	mesh.material_overlay = highlight_material
	MessageBus.interaction_focused.emit(context, new_icon, override_icon)
	#Global.ui_context.update_content(context)
	#Global.ui_context.update_icon(new_icon, override_icon)

func out_of_range() -> void:
	mesh.material_overlay = null
	MessageBus.interaction_unfocused.emit()
	#Global.ui_context.reset()

func on_interact() -> void:
	player_interacted.emit(parent)

func connect_parent() -> void:
	parent.add_user_signal("focused")
	parent.add_user_signal("unfocused")
	parent.add_user_signal("interacted")
	parent.connect("focused", Callable(self, "in_range"))
	parent.connect("unfocused", Callable(self, "out_of_range"))
	parent.connect("interacted", Callable(self, "on_interact"))

func set_default_mesh() -> void:
	if mesh:
		pass
	else:
		for i in parent.get_children():
			if i is MeshInstance3D:
				mesh = i
