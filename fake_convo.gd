extends Panel

var conversation = [
	[false, "Hi how are you"],
	[true, "I'm good, hahaha"],
	[true, "x3"],
]
var GREEN_BUBBLE = preload("res://ui/green_bubble.tscn")
var GRAY_BUBBLE = preload("res://ui/gray_bubble.tscn")

@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var insertion_point: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/chat_scroll

var conversation_head = 0

var is_scrolling_to_bottom = false

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

	# if we get a scroll event, cancel is_scrolling_to_bottom
	if event is InputEventMouseButton or event is InputEventPanGesture:
		is_scrolling_to_bottom = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_scrolling_to_bottom:
		var scroll_max = scroll_container.get_v_scroll_bar().max_value;

		scroll_container.scroll_vertical = lerp(scroll_container.scroll_vertical * 1.0, scroll_max * 1.0, delta)

		if abs((scroll_container.scroll_vertical - scroll_max)) < 0.001:
			print("cancel is_scroll_to_bottom")
			is_scrolling_to_bottom = false

func _spawn_conversation_bubble(
	is_you: bool,
	text: String
) -> void:
	var prefab
	if is_you:
		prefab = GREEN_BUBBLE
	else:
		prefab = GRAY_BUBBLE

	# If scroll container is already at bottom, set flag to
	# slerp to bottom until we are at bottom
	var vbar: VScrollBar = scroll_container.get_v_scroll_bar()
	if (scroll_container.scroll_vertical >= vbar.max_value - vbar.page or
		vbar.max_value == 0):
		is_scrolling_to_bottom = true
		print("set is_scroll_to_bottom")
	else:
		print("not at bottom!",
		"scroll_vertical: " + str(scroll_container.scroll_vertical) + " page: " + str(vbar.page) + " max_value: " + str(vbar.max_value))

	var instance = prefab.instantiate()
	var label = instance.get_node("Label")
	label.set_measured_text(text)
	insertion_point.add_child(instance)
			
