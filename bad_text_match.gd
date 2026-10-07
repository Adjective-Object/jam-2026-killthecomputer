class_name BadTextMatch
extends Label

var lifetime: float = 2.0
@onready var speed: Vector2 = Vector2(
	randf_range(2.0, 5.0),
	randf_range(3.0, 5.0)
)
@onready var start_time_s: float = Time.get_ticks_msec() / 1000.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.offset_transform_enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	var interp: float = min((now - start_time_s), 1.0)
	if interp >= 1.0:
		self.queue_free()
		return

	self.modulate.a = 1.0 - ease(now, 1.0)
	self.speed = lerp(self.speed, Vector2.ZERO, 0.1)
	self.offset_transform_position.x += self.speed.x * delta
	self.offset_transform_position.y += self.speed.y * delta
