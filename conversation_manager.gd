extends ScrollContainer
class_name MyConversationManager

var conversation: Conversations.Conversation

var GREEN_BUBBLE = preload("res://ui/green_bubble.tscn")
var GRAY_BUBBLE = preload("res://ui/gray_bubble.tscn")
var typing_indicator = preload("res://ui/typing_indicator.tscn")
var active_typing_indicator: Control = null
var paused: bool = false
var deferred_wait_timer: bool = false # A wait timer didn't start because the conv is paused.
var deferred_typing_timer: bool = false # A typing timer didn't start because the conv is paused.

# Emitted to indicate that a new conversation should be added to the list of
# conversations.
signal add_conversation(conversation: Conversations.Conversation)

# Emitted to indicate that the life_timer should begin now.
signal start_life_timer

# Emitted to indicate that the midpoint call should begin if
# it hasn't happened already.
signal allow_midpoint_call

@onready var scroll_container: ScrollContainer = self # todo: cleanup
@onready var insertion_point: VBoxContainer = $MarginContainer/chat_scroll
@onready var responses_area: ResponsesArea = $MarginContainer/chat_scroll/ResponsesArea
@onready var typingindicator_timer = $typing_indicator_timer
@onready var wait_timer = $wait_timer

@export var audio: AudioStreamPlayer3D
@export var life_progress: LifeProgress

var conversation_head = 0
var conversation_score = 0

var is_scrolling_to_bottom = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# advance_conversation() # HACK

func start_conversation(conversation: Conversations.Conversation):
	conversation_head = 0
	self.conversation = conversation
	is_scrolling_to_bottom = false
	if conversation.them.theme:
		audio.stream = conversation.them.theme
		audio.play()

func advance_conversation():
	if conversation_head < len(conversation.dialogs):
		var entry = conversation.dialogs[conversation_head]
		if entry.they_said:
			_spawn_conversation_bubble(false, entry.they_said)
			if life_progress:
				life_progress.grant_time(4.0)
			conversation_head += 1
			return
		elif len(entry.responses):
			responses_area.set_responses(entry.responses, self)
			conversation_head += 1
		elif entry.typing_indicator_duration_s != 0:
			_spawn_typing_indicator(entry.typing_indicator_duration_s)
			conversation_head += 1
		elif entry.wait_duration_s != 0:
			wait_timer.connect("timeout", _clear_wait_timer_and_advance_conversation)
			wait_timer.wait_time = entry.wait_duration_s
			if not paused:
				wait_timer.start()
			else:
				# Start when unpaused
				deferred_wait_timer = true
			conversation_head += 1
		elif entry.cutoff != null:
			if conversation_score <= 0:
				conversation.dialogs.append_array(entry.cutoff.fail_dialogs)
			else:
				conversation.dialogs.append_array(entry.cutoff.pass_dialogs)
			conversation_head += 1
			advance_conversation()
		elif entry.new_conversation != null:
			add_conversation.emit(entry.new_conversation)
			conversation_head += 1
			advance_conversation()
		elif entry.start_life_timer:
			life_progress.start()
			conversation_head += 1
			advance_conversation()
		elif entry.speedup_life_timer:
			# TODO

			conversation_head += 1
			advance_conversation()
		elif entry.allow_midpoint_call:
			allow_midpoint_call.emit()

			conversation_head += 1
			advance_conversation()
		else:
			push_warning("got weird Dialog entry", entry)
			conversation_head += 1

func pause():
	paused = true
	wait_timer.paused = true
	typingindicator_timer.paused = true

func unpause():
	paused = false

	wait_timer.paused = false
	if deferred_wait_timer:
		deferred_wait_timer = false
		wait_timer.start()

	typingindicator_timer.paused = false
	if deferred_typing_timer:
		deferred_typing_timer = false
		typingindicator_timer.start()

func _input(event):
	# if we get a scroll event, cancel is_scrolling_to_bottom
	if event is InputEventMouseButton or event is InputEventPanGesture:
		is_scrolling_to_bottom = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_scrolling_to_bottom:
		var scroll_max = scroll_container.get_v_scroll_bar().max_value;

		scroll_container.scroll_vertical = lerp(scroll_container.scroll_vertical * 1.0, scroll_max * 1.0, delta)

		if abs((scroll_container.scroll_vertical - scroll_max)) < 0.001:
			print("cancel is_scroll_to_bottom")
			is_scrolling_to_bottom = false

func _spawn_conversation_bubble(
	is_you: bool,
	text: String
) -> void:
	var prefab
	if is_you:
		prefab = GREEN_BUBBLE
	else:
		prefab = GRAY_BUBBLE

	# If scroll container is already at bottom, set flag to
	# slerp to bottom until we are at bottom
	var vbar: VScrollBar = scroll_container.get_v_scroll_bar()
	if (scroll_container.scroll_vertical >= vbar.max_value - vbar.page or
		vbar.max_value == 0):
		is_scrolling_to_bottom = true
		print("set is_scroll_to_bottom")
	else:
		print("not at bottom!",
		"scroll_vertical: " + str(scroll_container.scroll_vertical) + " page: " + str(vbar.page) + " max_value: " + str(vbar.max_value))

	var instance = prefab.instantiate()
	# Change color and icon to match chatter.
	if not is_you:
		var panel = instance.find_child("ChatBubble")
		var style_box: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
		style_box.bg_color = conversation.them.color
		panel.add_theme_stylebox_override("panel", style_box)
		
		var icon: TextureRect = instance.find_child("Icon")
		icon.texture = conversation.them.icon
	var label: TextPlayback = instance.find_child("Label")
	if not is_you: label.ms_per_letter = 8.0 / conversation.them.msg_speed
	label.set_measured_text(text)
	label.playback_complete.connect(advance_conversation)
	insertion_point.add_child(instance)
	# Move it before the ResponseArea so the ResponseArea stays at the bottom.
	insertion_point.move_child(instance, -2)

func _spawn_typing_indicator(
	duration_s: float
):
	if active_typing_indicator != null:
		return
	
	active_typing_indicator = typing_indicator.instantiate()
	insertion_point.add_child(active_typing_indicator)
	# Move it before the ResponseArea so the ResponseArea stays at the bottom.
	insertion_point.move_child(active_typing_indicator, -2)
	typingindicator_timer.connect("timeout", _clear_typing_indicator_and_advance_conversation)
	typingindicator_timer.wait_time = duration_s
	if not paused:
		typingindicator_timer.start()
	else:
		# Start when unpaused
		deferred_typing_timer = true

func _clear_typing_indicator_and_advance_conversation():
	typingindicator_timer.stop()
	if active_typing_indicator != null:
		await active_typing_indicator.dismiss()
		active_typing_indicator = null
		# wait another frame for the layout
		await get_tree().process_frame

	advance_conversation()
	
func _clear_wait_timer_and_advance_conversation():
	wait_timer.stop()
	advance_conversation()

func on_succesful_submit(submitted_text: String) -> void:
	responses_area.clear_responses()
	_spawn_conversation_bubble(true, submitted_text)
	
	# Add the dialog tree from the chosen branch into the conversation.
	var chosen_branch : Conversations.Branch
	for branch in conversation.dialogs[conversation_head-1].responses:
		if branch.you_said == submitted_text:
			chosen_branch = branch
	
	conversation.dialogs = (conversation.dialogs.slice(0, conversation_head, 1, true) +
		chosen_branch.dialogs + conversation.dialogs.slice(conversation_head, len(conversation.dialogs), 1, true))
	
	conversation_score += chosen_branch.increment

func on_failed_submit(submitted_text: String) -> void:
	push_warning("Failed submission: " + submitted_text)
