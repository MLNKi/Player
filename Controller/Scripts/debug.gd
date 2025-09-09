extends PanelContainer

@onready var property_container = %VBoxContainer

#var property
var frames_per_second : String


# Called when the node enters the scene tree for the first time.
func _ready():
	#Esconde o DebugPanel ao carregar
	visible = false
	#Referencia os script "GLOBAL"
	Global.debug = self
	
	#add_debug_property("FPS", frames_per_second)

func _input(event):
	#Ativa o DebugPanel quando pressionado "'"
	if event.is_action_pressed("Debug"):
		visible = !visible

func _process(delta):
	if visible:
		frames_per_second = "%.2f" % (1.0/delta)
		#property.text = property.name + ": " + frames_per_second

func add_property(title : String, value, order):
	var target
	target = property_container.find_child(title,true,false) #Tenta achar Label com mesmo nome
	if !target: #Se não há Label node com property (Initial Load)
		target = Label.new() #Cria um novo Label Node
		property_container.add_child(target) #Cria um novo novo como child of VBox Container
		target.name = title #Coloca o nome no title
		target.text = target.name + ": " + str(value) #Coloca um valor como texto
	elif visible:
		target.text = title + ": " + str(value) #Atualiza o valor
		property_container.move_child(target, order) #Organiza as Property conforme ordem dada
		








#Função para criar uma nova propriedade dentro do DebugPanel
#func add_debug_property(title : String, value):
	#property = Label.new() #Cria um novo Label node
	#property_container.add_child(property) #Adiciona novo Label as child do VBox container
	#property.name = title #Adiciona o nome
	#property.text = property.name + value
