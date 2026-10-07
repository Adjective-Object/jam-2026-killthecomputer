@tool
extends RichTextEffect
class_name MatchingType

# Define the custom BBCode tag (used as [ghost]text[/ghost])
var bbcode = "prefix_match"

class _CharState:
	var scale: float = 1.0
	var color: Color = Color(0,0,0, 1)

# Used to animate the scale of the characters
class CharStates:
	var states: Dictionary[int, _CharState] = {}

	func _to_string() -> String:
		var result = ""
		for i in states.keys():
			result += str(i) + ": " + str(states[i].scale) + ", " + str(states[i].color) + "\n"
		return result

var UNRENDERED_SCALE: float = 0.5
var INCORRECT_SCALE: float = 0.8
var LERP_SPEED: float = 0.5
var COLOR_CORRECT = Color(0, 0, 1, 1)
var COLOR_INCORRECT = Color(1, 0, 0, 1)
var COLOR_NONMATCHED = Color(0, 0, 0, 0.8)

var cursor_rect_position: Vector2 = Vector2()

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Length of the typed user prefix
	var prefix_len: int = char_fx.env.get("prefix_len", 5)
	# Length of the succesful match within the prefix
	var prefix_match_len: int = char_fx.env.get("prefix_match_len", 3)
	# Length of the user text (e.g. we over-wrote the real prompt)
	var prompt_len: int = char_fx.env.get("prompt_len", 5)
	# column the cursor is in
	var cursor_col: int = char_fx.env.get("cursor_col", 4)
	# column the cursor is in
	var font_size: int = char_fx.env.get("font_size", 32)

	var char_states_id: int = char_fx.env.get("char_states_id", 0)

	var i = char_fx.relative_index
	var intended_scale: float = 1.0
	var intended_color = COLOR_NONMATCHED

	if i < prefix_match_len:
		intended_scale = 1.0
		intended_color = COLOR_CORRECT
	elif i < min(prefix_len, prompt_len):
		intended_scale = INCORRECT_SCALE
		intended_color = COLOR_INCORRECT
	elif i < prefix_len:
		intended_scale = INCORRECT_SCALE
		intended_color = COLOR_INCORRECT
	else:
		intended_scale = UNRENDERED_SCALE
		intended_color = COLOR_NONMATCHED
	
	var char_states = instance_from_id(char_states_id)

	if char_states == null:
		var offset = char_fx.transform.origin;
		var scale = Transform2D.IDENTITY.scaled(Vector2(intended_scale, intended_scale)).translated(offset)
		char_fx.transform = scale
		char_fx.color = intended_color	
		return true

	if i not in char_states.states:
		char_states.states[i] = _CharState.new()

	char_states.states[i].scale = lerp(
		char_states.states[i].scale, intended_scale, LERP_SPEED)
	char_states.states[i].color = lerp(
		char_states.states[i].color, intended_color, LERP_SPEED)

	if cursor_col < prompt_len:
		if i == cursor_col + 1:
			# to be read by the controller script later
			#print("cursor_rect_position", cursor_rect_position)
			cursor_rect_position = Vector2(char_fx.transform.origin)
	elif i == cursor_col:
		var ts = TextServerManager.get_primary_interface()
		var advance = ts.font_get_glyph_advance(char_fx.font, font_size, char_fx.glyph_index)
		var glyph_width = advance.x

		cursor_rect_position = Vector2(char_fx.transform.origin) + Vector2(glyph_width, 0)

	# set scale,color, etc based on state
	var offset = char_fx.transform.origin;
	var scale = Transform2D.IDENTITY.scaled(
		Vector2(char_states.states[i].scale, char_states.states[i].scale)).translated(offset)
	char_fx.transform = scale
	char_fx.color = char_states.states[i].color

	return true
