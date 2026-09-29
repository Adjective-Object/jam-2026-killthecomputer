extends PanelContainer

@onready var response_label: Label = $Label
@export var initial_text: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	response_label.text = initial_text

func initialize(text: String) -> void:
	initial_text=text
