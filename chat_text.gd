@tool
extends Control
class_name ChatText

@export var label: Label
@export var max_wrap_width: float = 300.0

func _ready():
	if not label:
		var parent = get_parent()
		if parent is Label:
			label = parent as Label
		else:
			push_error("Parent is not a Label and no label is assigned.")

	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if label.custom_maximum_size.x != max_wrap_width:
		push_warning("Label's custom maximum size x does not match max_wrap_width: " + str(max_wrap_width) + "It will be updated")
		label.custom_maximum_size.x = max_wrap_width

func update_text(new_text: String) -> void:
	label.text = new_text
	_update_text_dimensions()

func _update_text_dimensions() -> void:
	# Disable autowrap to measure the natural width of the text
	# label.autowrap_mode = TextServer.AUTOWRAP_OFF
	# custom_minimum_size.x = 0
	# var natural_width = label.get_minimum_size().x
	# # Constrain to either maxwrap_width or natural width
	# if natural_width > max_wrap_width:
	# 	custom_minimum_size.x = max_wrap_width
	# else:
	# 	custom_minimum_size.x = natural_width
	# # Re-enable
	# label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pass
