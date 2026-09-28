extends Label

@export var label_text: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
@export var ms_per_letter: float = 8.0

var display_start_time: int = 0

var breaklines_label_text: String = ""
var final_measured_size: Vector2

# Start by laying out the text.
# break to lines at the max-width by word to know the final line-break and 
func break_to_lines(text_to_break: String):
	var active_font: Font = get_theme_font("font")
	var active_font_size: int
	if self.label_settings != null:
		active_font_size = self.label_settings.font_size
	else:
		active_font_size = get_theme_font_size("font_size")

	var label_max_width: float = self.custom_maximum_size.x
	
	var words = text_to_break.split(" ")
	var lines = []
	var current_line = ""
	for word in words:
		var next_line = current_line + word + " "
		var measured_size = active_font.get_string_size(next_line, HORIZONTAL_ALIGNMENT_LEFT, -1, active_font_size)
		if measured_size.x > label_max_width:
			# print("newline: ", next_line)
			lines.append(current_line)
			current_line = word + " "
		else:
			current_line = next_line
	if current_line != "":
		lines.append(current_line)

	breaklines_label_text = "\n".join(lines)
	var lines_size = active_font.get_multiline_string_size(
		breaklines_label_text,
		self.horizontal_alignment,
		-1, # natural width
		active_font_size,
		self.autowrap_trim_flags,# brk
		self.justification_flags,
	)
	# HACK: for some reason the text measuring doesn't match
	# real line wrapping, and we can't avoid wrapping for
	# some other reason, so we override here.
	lines_size.x += 1.0
	var spacing = self.get_theme_constant("line_spacing")
	var total_lines = len(lines)
	final_measured_size = lines_size + Vector2(0, (total_lines ) * spacing)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_start_time = Time.get_ticks_msec()
	self.set_measured_text(label_text)

func set_measured_text(new_text: String) -> void:
	print("set_text", new_text)
	self.label_text = new_text;
	break_to_lines(new_text)

	# set from globals
	self.text = breaklines_label_text
	print("setting size:", final_measured_size)
	self.size = final_measured_size
	self.custom_minimum_size = final_measured_size
	# self.custom_maximum_size = final_measured_size
	

func _input(event):
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_R:
		display_start_time = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var elapsed_time = Time.get_ticks_msec() - display_start_time
	var letters_to_show = int(elapsed_time / ms_per_letter)
	var next_text = breaklines_label_text.substr(0, letters_to_show)
	self.text = next_text

# func truncate_by_word(text: String, max_length: int) -> String:
# 	if text.length() <= max_length:
# 		return text

# 	for i in range(max_length, -1, -1):
# 		if text[i] == " ":
# 			return text.substr(0, i)
	
# 	return ""
