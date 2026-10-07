extends Panel
class_name MyConversationManager

class Dialog:
	var they_said: String
	var typing_indicator_duration_s: float
	var wait_duration_s: float
	var responses: Array[String]

	static func typing_indicator(duration_seconds: float) -> Dialog:
		var n = Dialog.new()
		n.typing_indicator_duration_s = duration_seconds
		return n
	
	static func they_say(msg: String) -> Dialog:
		var n = Dialog.new()
		n.they_said = msg
		return n

	static func you_say(options: Array[String]) -> Dialog:
		var n = Dialog.new()
		n.responses = options
		return n
	
	static func sleep(duration: float) -> Dialog:
		var n = Dialog.new()
		n.wait_duration_s = duration
		return n

var conversation: Array[Dialog] = [
	Dialog.you_say(["hi", "hewwo"]),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1.25),
	Dialog.they_say("Hi, how are you?"),
	Dialog.you_say(["I'm good, hahahaa", "I'm sad, waah"]),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1.2),
	Dialog.you_say(["xD", "xP"]),
]
var GREEN_BUBBLE = preload("res://ui/green_bubble.tscn")
var GRAY_BUBBLE = preload("res://ui/gray_bubble.tscn")
var typing_indicator = preload("res://ui/typing_indicator.tscn")
var active_typing_indicator: Control = null

@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var insertion_point: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/chat_scroll
@onready var responses_area: ResponsesArea = $VBoxContainer/ResponsesArea
@onready var typingindicator_timer = $typing_indicator_timer
@onready var wait_timer = $wait_timer

var conversation_head = 0

var is_scrolling_to_bottom = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	advance_conversation() # HACK

func advance_conversation():
	# Advance faux conversation
	if conversation_head < len(conversation):
		var entry = conversation[conversation_head]
		if entry.they_said:
			_spawn_conversation_bubble(false, entry.they_said)
			conversation_head += 1
			advance_conversation()
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
			wait_timer.start()
			conversation_head += 1
		else:
			push_warning("got weird Dialog entry", entry)
			conversation_head += 1
	

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
	var label = instance.get_node("Label")
	label.set_measured_text(text)
	insertion_point.add_child(instance)

func _spawn_typing_indicator(
	duration_s: float
):
	if active_typing_indicator != null:
		return
	
	active_typing_indicator = typing_indicator.instantiate()
	insertion_point.add_child(active_typing_indicator)
	typingindicator_timer.connect("timeout", _clear_typing_indicator_and_advance_conversation)
	typingindicator_timer.wait_time = duration_s
	typingindicator_timer.start()

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
	advance_conversation()

func on_failed_submit(submitted_text: String) -> void:
	push_warning("Failed submission: " + submitted_text)
