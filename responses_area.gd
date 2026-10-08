class_name ResponsesArea
extends PanelContainer

var RESPONSE_OPTION = preload("res://ui/response_option.tscn")
var buffered_text: String = ""

var SLIDE_OFFSET = 100

@onready var responses_container: VBoxContainer = $responses_container;
@onready var capture_text: LineEdit = $LineEdit
var response_instances: Array[ResponseOption] = []
var conversation_manager: MyConversationManager = null

var out_of_view_pos: Vector2
var in_view_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("responses_container", responses_container)
	capture_text.grab_focus()
	capture_text.modulate.a = 0.0
	out_of_view_pos = Vector2(self.position.x, self.position.y + SLIDE_OFFSET)
	in_view_pos = Vector2(self.position.x, self.position.y)
	self.visible = false
	
	capture_text.text_submitted.connect(_on_text_submitted)

func clear_responses() -> void:
	for child in responses_container.get_children():
		child.queue_free()
	response_instances = []

func set_responses(response_options: Array[MyConversationManager.Branch], conversation_manager: MyConversationManager) -> void:
	self.conversation_manager = conversation_manager
	self.capture_text.text = ""
	# unqueue all responses
	for child in responses_container.get_children():
		child.queue_free()
	
	# spawn new text options
	response_instances = []
	# print("spawning responses:", [branch.you_said for branch in response_options])
	for branch in response_options:
		var instance: ResponseOption = RESPONSE_OPTION.instantiate()
		instance.initialize(branch.you_said)
		response_instances.push_back(instance)
		responses_container.add_child(instance)

	# Slide into view. TODO: Animate.
	visible = true
	capture_text.grab_focus()

	responses_container.queue_sort()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Truncate typed text to longest substring of any prefix-matched
	# response
	var text: String = capture_text.text
	var longest_match: int = 0
	for r_i in response_instances:
		var my_longest_match = 0
		for i in range(0, min(len(text), len(r_i.response_text))):
			if r_i.response_text[i] != text[i]:
				break
			else:
				my_longest_match = i + 1
		if my_longest_match > longest_match:
			longest_match = my_longest_match

	if longest_match < len(text):
		var truncated = capture_text.text.substr(0, longest_match)
		print("truncating input txt: ", capture_text.text, "->", truncated)
		var caret_col = capture_text.caret_column
		var truncated_suffix = capture_text.text.substr(len(truncated))
		capture_text.text = truncated
		capture_text.caret_column = min(caret_col, len(truncated))
		
		for response_instance in self.response_instances:
			response_instance.spawn_bad_text(truncated_suffix)
	
	for response_instance in self.response_instances:
		response_instance.update_input(capture_text.text, capture_text.caret_column)

func _on_text_submitted(submitted_text: String) -> void:
	# Attempt submission -- check against all tracked respones.
	# If so, signal the conversation manager to advance
	for response_instance in self.response_instances:
		if response_instance.response_text.to_lower() == submitted_text.to_lower():
			conversation_manager.on_succesful_submit(submitted_text)
			# Slide out of view. TODO: Animate.
			visible = false
			# set_position(out_of_view_pos)
			return

	conversation_manager.on_failed_submit(submitted_text)
