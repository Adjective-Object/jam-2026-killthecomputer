extends Panel
class_name MultiConversationManager

class AvailableConversation:
	var conversation_manager: MyConversationManager
	var tab: Control
	var person: Conversations.Person
	var needs_attention: bool

var conversation_prefab = preload("res://conversation.tscn")
var tab_prefab = preload("res://chat_tab.tscn")

var conversations: Array[AvailableConversation]
var active_conversation: AvailableConversation

@export var audio: AudioStreamPlayer3D

@onready var conversation_container: VBoxContainer = $VBoxContainer
@onready var tab_container: HBoxContainer = $VBoxContainer/PanelContainer/HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func add_conversation(conversation: Conversations.Conversation):
	var instance: MyConversationManager = conversation_prefab.instantiate()
	instance.audio = audio
	instance.ready.connect(func():
		instance.start_conversation(conversation)
	)
	instance.add_conversation.connect(func(conversation: Conversations.Conversation):
		add_conversation(conversation)
	)
	
	instance.visible = false
	conversation_container.add_child(instance)
	
	var available_conv = AvailableConversation.new()
	available_conv.conversation_manager = instance
	available_conv.person = conversation.them
	available_conv.needs_attention = true
	
	# Create the corresponding tab.
	
	var tab_instance: Control = tab_prefab.instantiate()
	(tab_instance.find_child("TextureRect") as TextureRect).texture = conversation.them.icon
	available_conv.tab = tab_instance
	tab_container.add_child(tab_instance)
	
	# When the tab is clicked, focus the conversation
	var index = len(conversations)
	tab_instance.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				print("click")
				focus_conversation(index)
				accept_event()
	)
	
	conversations.append(available_conv)

func focus_conversation(index: int):
	if index >= len(conversations):
		print("Warning: Tried to click out-of-range conversation: " + str(index))
	
	visible = true

	var conv = conversations[index]
	
	# Hide defocused conversation.
	if active_conversation:
		active_conversation.conversation_manager.visible = false
		active_conversation.conversation_manager.pause()
	
	active_conversation = conv
	active_conversation.tab.find_child("Notification").visible = false
	active_conversation.conversation_manager.visible = true
	if active_conversation.conversation_manager.paused:
		active_conversation.conversation_manager.unpause()
	else:
		conv.conversation_manager.advance_conversation() 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
