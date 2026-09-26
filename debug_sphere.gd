@tool
extends Node3D

@export var color: Color = Color(1, 0, 1)
@export var radius: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		DebugDraw3D.draw_sphere(global_transform.origin, radius, color)
