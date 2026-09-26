extends Control

@export var label: Label
@export var label_text: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
@export var ms_per_letter: float = 8.0

var display_start_time: int = 0

var breaklines_label_text: String = ""
var final_measured_size: Vector2

# Start by laying out the text.
# break to lines at the max-width by word to know the final line-break and 
func break_to_lines(text: String):
	var active_font: Font = get_theme_font("font")
	var active_font_size: int = get_theme_font_size("font_size")
	var label_max_width: float = label.custom_maximum_size.x
	
	var words = text.split(" ")
	var lines = []
	var current_line = ""
	var current_height = 0
	for word in words:
		var next_line = current_line + word + " "
		var measured_size = active_font.get_string_size(next_line, HORIZONTAL_ALIGNMENT_LEFT, -1, active_font_size)
		if measured_size.y > current_height || measured_size.x > label_max_width:
			print("newline: ", next_line)
			lines.append(current_line)
			current_line = word + " "
			current_height = measured_size.y
		else:
			current_line = next_line
	if current_line != "":
		lines.append(current_line)

	breaklines_label_text = "\n".join(lines)
	final_measured_size = active_font.get_string_size(breaklines_label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, active_font_size)
	print("Final measured size: ", final_measured_size)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not label:
		var parent = get_parent()
		if parent is Label:
			label = parent as Label
		else:
			push_error("Parent is not a Label and no label is assigned.")

	display_start_time = Time.get_ticks_msec()

	# measure the natural size of the text
	break_to_lines(label_text)
	label.text = breaklines_label_text

	# set the label size to the final measured size
	label.size = final_measured_size

func _input(event):
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_R:
		display_start_time = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var elapsed_time = Time.get_ticks_msec() - display_start_time
	var letters_to_show = int(elapsed_time / ms_per_letter)
	var next_text = breaklines_label_text.substr(0, letters_to_show)
	label.text = next_text

# func truncate_by_word(text: String, max_length: int) -> String:
# 	if text.length() <= max_length:
# 		return text

# 	for i in range(max_length, -1, -1):
# 		if text[i] == " ":
# 			return text.substr(0, i)
	
# 	return ""
