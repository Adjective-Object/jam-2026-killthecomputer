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
var toast_prefab = preload("res://toast.tscn")
var palette: ColorPalette = preload("res://ui/colors.tres")

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
@onready var separator: PanelContainer = $VBoxContainer/Separator
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
				conv.needs_attention = true
				existing_conversation = true
				toast("new message from ENTITY", palette.colors[13], 2.0)

				break
		if not existing_conversation:
			var new_conversation = Conversations.Conversation.with(conversation_data.entity, chat.dialogs)
			add_conversation(new_conversation, chat.tag)
	)
	
	instance.toast.connect(func(msg: String, color: Color, duration: float):
		toast(msg, color, duration)
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
	var tab_panel: PanelContainer = tab_instance.find_child("PanelContainer")
	var tab_style_box = tab_panel.get_theme_stylebox("panel").duplicate()
	tab_style_box.bg_color = conversation.them.color
	tab_panel.add_theme_stylebox_override("panel", tab_style_box)
	tab_panel.self_modulate.a = 0.0
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
		
		if active_conversation and active_conversation.tab != conversations[index].tab:
			tab_instance.find_child("PanelContainer").self_modulate.a = 0.7
	)

	tab_instance.mouse_exited.connect(func():
		print("mouse exited")
		name_bubble.visible = false
		
		if active_conversation and active_conversation.tab != conversations[index].tab:
			tab_instance.find_child("PanelContainer").self_modulate.a = 0.0
	)
	
	# don't show this toast for the very first convo in the game
	if index != 0:
		toast("new message from " + conversation.them.name, palette.colors[13], 2.0)
		Sounds.instance.play_new_match()
	
	conversations.append(available_conv)

func toast(msg: String, color: Color, duration: float):
	var toast_instance: Toast = toast_prefab.instantiate()
	toast_instance.duration = duration
	var toast_style_box = toast_instance.get_theme_stylebox("normal").duplicate()
	toast_style_box.bg_color = color
	toast_instance.add_theme_stylebox_override("normal", toast_style_box)
	toast_instance.add_theme_stylebox_override("pressed", toast_style_box)
	toast_instance.add_theme_stylebox_override("hover", toast_style_box)
	toast_instance.text = msg
	
	add_child(toast_instance)
	
func focus_conversation(index: int):
	if index >= len(conversations):
		print("Warning: Tried to click out-of-range conversation: " + str(index))
	
	visible = true

	var conv = conversations[index]
	
	# Hide defocused conversation.
	if active_conversation:
		active_conversation.conversation_manager.visible = false
		active_conversation.conversation_manager.pause()
		active_conversation.tab.find_child("PanelContainer").self_modulate.a = 0.0
		#var old_tab_style_box: StyleBoxFlat = old_tab_panel.get_theme_stylebox("panel").duplicate()
		#old_tab_style_box.bg_color.a = 0.0
		#old_tab_panel.add_theme_stylebox_override("panel", old_tab_style_box)
	
	active_conversation = conv
	active_conversation.tab.find_child("Notification").visible = false
	active_conversation.tab.find_child("PanelContainer").self_modulate.a = 1.0
	#var new_tab_style_box: StyleBoxFlat = new_tab_panel.get_theme_stylebox("panel").duplicate()
	#new_tab_style_box.bg_color.a = 1.0
	#new_tab_panel.add_theme_stylebox_override("panel", new_tab_style_box)
	separator.modulate = conv.person.color
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
