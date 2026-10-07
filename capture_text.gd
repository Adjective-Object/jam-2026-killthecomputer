extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.grab_focus()
	modulate.a = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("text:", self.text)
	print(" col:", self.caret_column)
