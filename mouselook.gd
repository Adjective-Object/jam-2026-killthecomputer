extends Camera3D

@onready var initial_camera_look_angle: Vector3 = transform.basis * Vector3.FORWARD
@export var cam_look_range: Vector2 = Vector2(0.011, 0.011) # in rads; camera look angle range

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# get the mouse position relative to the middle of the screen as a 
	var vp = get_viewport()
	var mouse_position: Vector2 = vp.get_mouse_position()
	var mouse_from_center: Vector2 = (mouse_position * 1.0) / (vp.get_size() * 1.0) - Vector2(0.5, 0.5)

	# rotate initial_camera_look angle up to (+/-cam_look_range)
	# rads in X,Y based on mouse pos
	var look_target_offset = initial_camera_look_angle
	look_target_offset = look_target_offset.rotated(Vector3.UP, mouse_from_center.x * cam_look_range.x)
	look_target_offset = look_target_offset.rotated(Vector3.RIGHT, mouse_from_center.y * cam_look_range.y)
	# print(look_target_offset)

	look_at(transform.origin + look_target_offset, Vector3.UP)
