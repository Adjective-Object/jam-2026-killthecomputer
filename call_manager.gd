extends Panel
class_name MyCallManager

class Caller:
	var icon: Texture2D
	var name: String
	var ringtone: AudioStream
	
	static func named(name: String, icon: Texture2D, ringtone: AudioStream):
		var result = Caller.new()
		result.icon = icon
		result.name = name
		result.ringtone = ringtone
		return result

class Call:
	var caller: Caller
	var conversation: Conversations.Conversation
	
	static func from(caller: Caller, conversation: Conversations.Conversation):
		var result = Call.new()
		result.caller = caller
		result.conversation = conversation
		return result

@export var conversation_manager: MultiConversationManager
@export var conversations: Conversations
@export var audio: AudioStreamPlayer3D

var entity_icon = preload("res://ui/pfps/pfp_entity.tres")
var entity_ringtone = preload("res://sounds/ringtone_loop.mp3")
var entity = Caller.named("ENTITY", entity_icon, entity_ringtone)

var entity_intro_call: Call 
var active_call: Call

@onready var answer_button: Button = $PanelContainer/MarginContainer/VBoxContainer/AnswerButton
@onready var decline_button: Button = $PanelContainer/MarginContainer/VBoxContainer/DeclineButton
@onready var icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/Icon
@onready var wait_timer = $wait_timer
@onready var wait_time = wait_timer.wait_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity_intro_call = Call.from(entity, conversations.entity_intro_conv)
	start_call(entity_intro_call)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_call(call: Call) -> void:
	active_call = call
	icon.texture = active_call.caller.icon
	audio.stream = active_call.caller.ringtone
	audio.play()
	visible = true
	
func _on_answer_button_pressed() -> void:
	# End the call and proceed to the conversation.
	visible = false
	audio.stop()
	conversation_manager.add_conversation(active_call.conversation)
	conversation_manager.focus_conversation(0)

func _on_decline_button_pressed() -> void:
	# Dismiss the call for a bit, but then have them call back pretty quickly,
	# since we need the call to happen for plot reasons.
	visible = false
	audio.stop()
	wait_timer.start(wait_time)


func _on_wait_timer_timeout() -> void:
	# Call back.
	start_call(active_call)
	wait_timer.stop()
