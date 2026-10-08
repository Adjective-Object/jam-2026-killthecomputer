extends AreaLight3D

@export var low: float = 2.5
@export var high: float = 5.0
var elapsed: float

func _process(delta: float) -> void:
	elapsed += delta
	area_range = lerpf(low, high, sin(elapsed*10))
