extends Panel

@export var call_manager: MyCallManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	call_manager.start_call(call_manager.entity_intro_call)
	visible = false
