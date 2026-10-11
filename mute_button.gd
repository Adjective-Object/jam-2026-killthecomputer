extends MarginContainer

@onready var off_icon: Control = $OffIcon
var muted = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		muted = !muted
		off_icon.visible = muted
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
