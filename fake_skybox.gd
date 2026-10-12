extends MeshInstance3D

@export var life: LifeProgress

var shake_tween: Tween

func _ready() -> void:
	pass
	shake_tween = create_tween()
	shake_tween.set_loops()
	shake_tween.tween_property(self, "position", Vector3(position.x, position.y + 0.2, position.z), 1)
	shake_tween.tween_property(self, "position", Vector3(position.x, position.y - 0.2, position.z), 1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var red_ratio
	if life.began and life.ratio <= 0.75:
		red_ratio = 0.75 - life.ratio
	else:
		red_ratio = 0.0
	(material_override as ShaderMaterial).set_shader_parameter("red_ratio", red_ratio)

	if life.began and life.ratio < 0.1:
		shake_tween.set_speed_scale(min(0.1 / life.ratio / 2, 10))
	else:
		shake_tween.set_speed_scale(0)
		
