extends WorldEnvironment

#var noise_texture: Texture2D = preload("res://sky_noise.png")

@export var speed = 6.0
@export var life: LifeProgress
@export var start_life_color: Color
@export var end_life_color: Color

func _ready():
	pass
	var sky_material: ShaderMaterial = environment.sky.sky_material
	#sky_material.set_shader_parameter("texture_to_scroll", noise_texture)
	#sky_material.set_shader_parameter("scroll_speed", 0.08)
	#sky_material.set_shader_parameter("angle_degrees", 0)
	#sky_material.set_shader_parameter("repeat_x", 0.5)
	#sky_material.set_shader_parameter("repeat_y", 0.5)

func _process(delta: float) -> void:
	pass
	#if life.began:
		#noise_texture.color_ramp.set_color(1, end_life_color.lerp(start_life_color, life.ratio))
