extends ProgressBar
class_name LifeProgress

@export var container: MarginContainer
@export var life_timer: Timer
@export var death_screen: Control

var total_time: float
var began: bool = false

func _ready():
	total_time = 60.0

func _process(delta: float):
	ratio = life_timer.time_left / total_time

func start():
	began = true

	var pos_tween: Tween = get_tree().create_tween()
	pos_tween.tween_property(container, "offset_transform_position", Vector2(0, 0), 2.0)
	pos_tween.tween_callback(func():
		life_timer.start(total_time)
	)
	
	life_timer.timeout.connect(func():
		death_screen.visible = true
		life_timer.stop()
	)

func grant_time(seconds: float):
	if began:
		life_timer.start(min(life_timer.time_left + seconds, total_time))
