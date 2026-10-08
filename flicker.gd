extends AreaLight3D

@export var low: float = 2.5
@export var high: float = 5.0
var elapsed: float

# doesn't work well. was trying to get a flickering effect with the light to
# give a bit more character to the environment, but it looks bad.
func _process(delta: float) -> void:
	elapsed += delta
	area_range = lerpf(low, high, sin(elapsed*10))
