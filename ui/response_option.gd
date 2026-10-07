class_name ResponseOption
extends PanelContainer

@onready var response_label: RichTextLabel = $Label
@onready var cursor_rect: ColorRect = $cursor_rect
@export var response_text: String
var BAD_TEXT_TEMPL = preload("res://ui/bad_text_match.tscn")

var CURSOR_LERP_SPEED = 0.5

var prefix_fx = preload("res://ui/matching_type.tres")
var char_states = MatchingType.CharStates.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	response_label.text = response_text
	print("ResponseOption ready")
	self.update_input("", 0)

func initialize(text: String) -> void:
	print("ResponseOption.initialize()")
	response_text=text
	if response_label != null:
		response_label.text = text
		self.update_input("", 0)

func spawn_bad_text(bad_text: String) -> void:
	var bad_text_inst: BadTextMatch = BAD_TEXT_TEMPL.instantiate()
	var fx_instance = prefix_fx
	bad_text_inst.text = bad_text
	if fx_instance != null:
		bad_text_inst.position = fx_instance.cursor_rect_position
		
	print("spawning bad text: ", bad_text, 'at', bad_text_inst.position)

	self.add_child(bad_text_inst)

func update_input(text: String, caret_column: int):
	# print("update_input", text, caret_column)
	# find the substring of this label that matches update_input,
	# and update the text effect on the label
	var match_prefix_len = 0;
	for i in range(0, min(len(text), len(response_text))):
		if text[i] == response_text[i]:
			match_prefix_len = i + 1
		else:
			break
	
	# print("match_prefix_len", match_prefix_len)
	# Apply matching text
	response_label.clear()
	var combined_response_text = response_text
	if len(text) > len(response_text):
		combined_response_text += text.substr(len(response_text))

	# response_label.add_text("hello")
	# print(char_states)
	response_label.push_customfx(prefix_fx, {
		"prefix_len": len(text),
		"prefix_match_len": match_prefix_len,
		"cursor_col": caret_column,
		"prompt_len": len(response_text),
		# Per-character state has to be smuggled in
		# because character rendering is stateless!
		"char_states_id": char_states.get_instance_id(),
	})
	response_label.add_text(combined_response_text)
	response_label.pop()

func _process(_delta: float) -> void:
	var fx_instance = prefix_fx
	if fx_instance != null:
		#print("fx_instance.cursor_rect_position", fx_instance.cursor_rect_position)
		cursor_rect.position = lerp(cursor_rect.position, fx_instance.cursor_rect_position, CURSOR_LERP_SPEED)
