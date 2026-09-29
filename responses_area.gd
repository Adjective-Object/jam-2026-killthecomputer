extends PanelContainer

var RESPONSE_OPTION = preload("res://ui/response_option.tscn")

@onready var responses_container: VBoxContainer = $/responses_container;
var responses: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_responses(response_options_text: Array[String]) -> void:
	# unqueue all children
	for child in get_children():
		child.queue_free()
	
	# spawn new text options
	responses = []
	for t in response_options_text:
		var instance = RESPONSE_OPTION.instantiate()
		instance.initialize(t)
		responses.push_back(instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
