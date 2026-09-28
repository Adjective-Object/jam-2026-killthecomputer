extends PanelContainer

@export var fade_in_ms = 360.0
@export var fade_in_displacement: Vector2 = Vector2(0.0, -80.0)
var wakeup_time: int;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wakeup_time = Time.get_ticks_msec()
	self.offset_transform_enabled = true

func _update(ratio: float) -> void:
	self.modulate.a = ratio
	self.offset_transform_position = fade_in_displacement * ease(1.0-ratio, 3)

func _process(_delta: float) -> void:
	var elapsed_time = Time.get_ticks_msec() - wakeup_time
	if elapsed_time < fade_in_ms:
		var ratio = float(elapsed_time) / fade_in_ms
		
		_update(ratio)
	else:
		_update(1.0)
