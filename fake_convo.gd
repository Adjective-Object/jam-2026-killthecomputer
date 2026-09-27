extends Panel

var conversation = [
	[false, "Hi how are you"],
	[true, "I'm good, hahaha"],
	[true, "x3"],
]
var GREEN_BUBBLE = preload("res://ui/green_bubble.tscn")
var GRAY_BUBBLE = preload("res://ui/gray_bubble.tscn")

@onready var insertion_point: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/chat_scroll

var conversation_head = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ENTER:
		# Advance faux conversation
		if conversation_head < len(conversation):
			var entry = conversation[conversation_head]
			var is_you = entry[0]
			var text = entry[1]
			conversation_head += 1
			_spawn_conversation_bubble(is_you, text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _spawn_conversation_bubble(
	is_you: bool,
	text: String
) -> void:
	var prefab
	if is_you:
		prefab = GREEN_BUBBLE
	else:
		prefab = GRAY_BUBBLE

	var instance = prefab.instantiate()
	var label = instance.get_node("Label/textplayback")
	label.set_text(text)
	insertion_point.add_child(instance)
