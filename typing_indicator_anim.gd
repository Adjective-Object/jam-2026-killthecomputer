extends Control

@onready var dots: Array[TextureRect] = [
	$dot3,
	$dot2,
	$dot1	
]
@export var duration_s = 1.2
@export var jump_offset = -4.0
@export var fade_time_s = 0.12

var start_time_s: float
var intro_tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time_s = Time.get_ticks_msec() / 1000.0
	for i in range(dots.size()):
		dots[i].offset_transform_enabled = true

	self.modulate.a = 0.0
	self.offset_transform_position.y = -jump_offset
	self.offset_transform_enabled = true
	intro_tween = create_tween()
	intro_tween.tween_property(self, "modulate:a", 1.0, fade_time_s)
	intro_tween.tween_property(self, "offset_transform_position:y", 0.0, fade_time_s)
	intro_tween.set_ease(Tween.EASE_IN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time_s
	var ratio = fmod(elapsed, duration_s) / duration_s
	anim_state(ratio)

# Ratio 0-1, drive animation state
func anim_state(ratio: float) -> void:
	for i in range(dots.size()):
		var dot_ratio = fmod(ratio + i * 0.2, 1.0)
		dots[i].modulate.a = ease_curve(dot_ratio)
		dots[i].offset_transform_position.y = ease_curve(dot_ratio) * jump_offset

func dismiss() -> void:
	# await intro_tween.finished
	var t = create_tween()
	t.tween_property(self, "modulate:a", 0.0, fade_time_s)
	t.tween_property(self, "offset_transform_position:y", -jump_offset, fade_time_s)
	t.set_ease(Tween.EASE_IN)
	await t.finished
	self.queue_free()

# Dot visible from 0.25 -> 0.75
func ease_curve(t: float) -> float:
	const LOW_END: float = 0.1
	const HIGH_END: float = 0.9

	if t < LOW_END:
		return 0
	elif t > HIGH_END:
		return 0
	elif t < 0.5:
		var segment_len = 0.5 - LOW_END
		var segment_position = (t - LOW_END)
		var segment_progress = segment_position/segment_len

		return ease(segment_progress, 2.0)
	else: 
		var segment_len = HIGH_END-0.5
		var segment_position = (t - 0.5)
		var segment_progress = segment_position/segment_len

		return 1.0 - ease(segment_progress, 2.0)
