extends Panel
class_name MyCallManager

class Person:
	var icon: Texture2D
	var name: String
	
	static func called(name: String, icon: Texture2D):
		var result = Person.new()
		result.icon = icon
		result.name = name
		return result

class Call:
	var person: Person
	var conversation: MyConversationManager.Conversation
	
	static func from(person: Person, conversation: MyConversationManager.Conversation):
		var result = Call.new()
		result.person = person
		result.conversation = conversation
		return result

@export var conversation_manager: MyConversationManager

var entity_icon = preload("res://ui/anon.png")
var entity = Person.called("ENTITY", entity_icon)

var entity_intro_call: Call 
var active_call: Call

@onready var answer_container = $PanelContainer/MarginContainer/VBoxContainer/AnswerContainer
@onready var decline_container = $PanelContainer/MarginContainer/VBoxContainer/DeclineContainer
@onready var wait_timer = $wait_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity_intro_call = Call.from(entity, conversation_manager.entity_intro_conv)
	active_call = entity_intro_call

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
