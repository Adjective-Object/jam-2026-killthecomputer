extends Panel
class_name MultiConversationManager

class AvailableConversation:
	var conversation_manager: MyConversationManager
	var tab: Control
	var person: Conversations.Person
	var needs_attention: bool
	
	# Used for side chat purposes to keep chats grouped together.
	var tag: String

var conversation_prefab = preload("res://conversation.tscn")
var tab_prefab = preload("res://chat_tab.tscn")

var conversations: Array[AvailableConversation]
var active_conversation: AvailableConversation

var midpoint_call_done: bool = false
var ending_call_done: bool = false
var allow_clicking_tabs: bool = true

@export var audio: AudioStreamPlayer3D
@export var life_progress: LifeProgress
@export var conversation_data: Conversations
@export var ending_screen: Control

@onready var jump_to_bottom: Button = $JumpToBottom
@onready var conversation_container: VBoxContainer = $VBoxContainer
@onready var tab_container: HBoxContainer = $VBoxContainer/PanelContainer/HBoxContainer
@onready var name_bubble: PanelContainer = $NameBubble
@onready var name_bubble_label: Label = $NameBubble/Label

# Emitted when the entity midpoint call should begin.
signal start_midpoint_call

# Emitted when the entity ending call should begin
signal start_ending_call

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func add_conversation(conversation: Conversations.Conversation, tag: String = ""):
	var instance: MyConversationManager = conversation_prefab.instantiate()
	instance.audio = audio
	instance.life_progress = life_progress
	
	instance.ready.connect(func():
		instance.start_conversation(conversation)
	)
	
	instance.add_conversation.connect(func(conversation: Conversations.Conversation):
		add_conversation(conversation)
	)
	
	instance.allow_midpoint_call.connect(func():
		if not midpoint_call_done:
			# TODO: delay
			start_midpoint_call.emit()
			midpoint_call_done = true
	)
	
	instance.allow_ending_call.connect(func():
		if not ending_call_done:
			start_ending_call.emit()
			ending_call_done = true
	)
	
	instance.entity_side_chat.connect(func(chat: Conversations.EntitySideChat):
		# If a side-chat on this topic already exists, add the messages to it.
		# Otherwise start a new side chat.
		
		var existing_conversation = false
		for conv in conversations:
			if conv.tag == chat.tag:
				conv.conversation_manager.conversation.dialogs.append_array(
					chat.dialogs)
				conv.conversation_manager.advance_conversation()
				conv.needs_attention = true
				existing_conversation = true
				break
		if not existing_conversation:
			var new_conversation = Conversations.Conversation.with(conversation_data.entity, chat.dialogs)
			add_conversation(new_conversation, chat.tag)
	)
	
	instance.trigger_ending.connect(func():
		# TODO: Fade in.
		ending_screen.visible = true
	)
	
	instance.visible = false
	conversation_container.add_child(instance)
	
	var available_conv = AvailableConversation.new()
	available_conv.conversation_manager = instance
	available_conv.person = conversation.them
	available_conv.needs_attention = true
	available_conv.tag = tag
	
	# Create the corresponding tab.
	var tab_instance: Control = tab_prefab.instantiate()
	(tab_instance.find_child("TextureRect") as TextureRect).texture = conversation.them.icon
	available_conv.tab = tab_instance
	tab_container.add_child(tab_instance)
	tab_container.move_child(tab_instance, 1)
	
	# When the tab is clicked, focus the conversation
	var index = len(conversations)
	tab_instance.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and allow_clicking_tabs:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				focus_conversation(index)
				accept_event()
	)
	
	# When the tab is hovered, show their name
	tab_instance.mouse_entered.connect(func():
		print("mouse entered")
		name_bubble.visible = true
		name_bubble.position.x = tab_instance.get_screen_position().x
		name_bubble_label.text = conversation.them.name
		var style_box: StyleBoxFlat = name_bubble.get_theme_stylebox("panel").duplicate()
		style_box.bg_color = conversation.them.color
		name_bubble.add_theme_stylebox_override("panel", style_box)
	)
	tab_instance.mouse_exited.connect(func():
		print("mouse exited")
		name_bubble.visible = false
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
	
	conv.conversation_manager.focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active_conversation:
		var scroll_container = active_conversation.conversation_manager.scroll_container
		var vbar: VScrollBar = scroll_container.get_v_scroll_bar()
		var at_bottom = scroll_container.scroll_vertical >= vbar.max_value - vbar.page or vbar.max_value == 0
		jump_to_bottom.visible = not at_bottom and not active_conversation.conversation_manager.is_scrolling_to_bottom
	else:
		jump_to_bottom.visible = false


func _on_jump_to_bottom_pressed() -> void:
	if active_conversation:
		var scroll_container = active_conversation.conversation_manager.scroll_container
		scroll_container.set_v_scroll(scroll_container.get_v_scroll_bar().max_value)
		active_conversation.conversation_manager.focus()
	
	jump_to_bottom.visible = false
