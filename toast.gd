extends Button
class_name Toast

@export var duration: float = 2.0

func _ready() -> void:
	var x = position.x

	print("TOAST: " + text)
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(x, 900), 0.2)
	tween.tween_interval(duration)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0), 0.3)
	tween.tween_callback(queue_free)
