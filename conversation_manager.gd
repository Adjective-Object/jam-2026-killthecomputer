extends Panel
class_name MyConversationManager

class Person:
	var icon: Texture2D
	var name: String
	var theme: AudioStream
	
	static func called(name: String, icon: Texture2D, theme: AudioStream):
		var result = Person.new()
		result.icon = icon
		result.name = name
		result.theme = theme
		return result
	
class Conversation:
	var them: Person
	var dialogs: Array[Dialog]
	
	static func with(them: Person, dialogs: Array[Dialog]) -> Conversation:
		var result = Conversation.new()
		result.them = them
		result.dialogs = dialogs
		return result

class Branch:
	var you_said: String
	var dialogs: Array[Dialog]
	
	static func choice(msg: String, dialogs: Array[Dialog]) -> Branch:
		var result = Branch.new()
		result.you_said = msg
		result.dialogs = dialogs
		return result
 
class Dialog:
	var they_said: String
	var typing_indicator_duration_s: float
	var wait_duration_s: float
	var responses: Array[Branch]

	static func typing_indicator(duration_seconds: float) -> Dialog:
		var n = Dialog.new()
		n.typing_indicator_duration_s = duration_seconds
		return n
	
	static func they_say(msg: String) -> Dialog:
		var n = Dialog.new()
		n.they_said = msg
		return n

	static func you_say(options: Array[Branch]) -> Dialog:
		var n = Dialog.new()
		n.responses = options
		return n
	
	static func sleep(duration: float) -> Dialog:
		var n = Dialog.new()
		n.wait_duration_s = duration
		return n

# A Conversation is like the script for a conversation.
# An ActiveConversation keeps track of the progress into that script.
class ActiveConversation:
	var conversation: Conversation
	var conversation_head: int
	
	static func start(conversation: Conversation):
		var n = ActiveConversation.new()
		n.conversation = conversation
		n.conversation_head = 0
		return n

# shorthand for Dialog.sleep + Dialog.typing_indicator + Dialog.they_say pattern
func they_say_after_sleep(sleep_duration: float, type_duration: float, msg: String) -> Array[Dialog]:
	return [Dialog.sleep(sleep_duration), Dialog.typing_indicator(type_duration), Dialog.they_say(msg)]
		
var entity_icon = preload("res://ui/anon.png")
var entity_theme = preload("res://sounds/03 - Call Of The Void.wav")
var entity = Person.called("ENTITY", entity_icon, entity_theme)

var entity_intro_conv = Conversation.with(entity, [
	Dialog.sleep(0.1),
	Dialog.typing_indicator(1.25),
	Dialog.they_say("YOU'RE LOOKING A LITTLE PALE LATELY"),
	Dialog.sleep(0.2),
	Dialog.typing_indicator(1.4),
	Dialog.they_say("DON'T TELL ME YOU CAN'T GET ANYONE TO DO YOUR RITUALS?"),
	Dialog.sleep(1),
	Dialog.you_say([
		Branch.choice(
			"I'm working on it!",
			they_say_after_sleep(0.4, 1, "NOT WORKING ENOUGH") +
			they_say_after_sleep(0.4, 0.8, "HA HA HA HA HA HA")),
		Branch.choice(
			"It's rough out here, dude.",
			they_say_after_sleep(0.4, 1, "MAYBE FOR YOU") +
			they_say_after_sleep(0.4, 0.8, "HA HA HA HA HA HA")),
	]),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1),
	Dialog.they_say("I SEE YOU'VE RESORTED TO DATING APPS"),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1),
	Dialog.they_say("I COULD ALWAYS SMELL DESPERATION ON YOU, SO THIS IS REALLY FITTING"),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1),
	Dialog.they_say("YOU KNOW WHAT'S GONNA HAPPEN IF YOU FAIL, RIGHT"),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1),
	Dialog.they_say("FINAL DEATH"),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1),
	Dialog.they_say("THE BIG ONE"),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1),
	Dialog.they_say("AND I GET TO SEND YOU THERE"),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1),
	Dialog.they_say("HA HA HA HA HA"),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1.25),
	Dialog.they_say("OH THIS WILL BE SO FUN FOR ME"),
	Dialog.sleep(1),
	Dialog.you_say([
		Branch.choice(
			"I still have time!",
			they_say_after_sleep(0.4, 1, "BARELY")),
		Branch.choice(
			"You're sick, you know that?",
			they_say_after_sleep(0.4, 1, "HA HA HA HA HA HA")),
	]),
	Dialog.sleep(2.5),
	Dialog.you_say([
		Branch.choice(
			"I'll figure it out. Leave me alone!",
			they_say_after_sleep(0.4, 1, "AS YOU WISH") +
			they_say_after_sleep(0.4, 1.2, "FOR THE LITTLE TIME YOU HAVE LEFT") +
			they_say_after_sleep(0.4, 1, "HA HA HA HA HA HA")),
	]),
	Dialog.sleep(0.4)
])

var conversation: ActiveConversation

var GREEN_BUBBLE = preload("res://ui/green_bubble.tscn")
var GRAY_BUBBLE = preload("res://ui/gray_bubble.tscn")
var typing_indicator = preload("res://ui/typing_indicator.tscn")
var active_typing_indicator: Control = null

@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var insertion_point: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/chat_scroll
@onready var them_label: Label = $VBoxContainer/PanelContainer/HBoxContainer/Label
@onready var responses_area: ResponsesArea = $ResponsesArea
@onready var typingindicator_timer = $typing_indicator_timer
@onready var wait_timer = $wait_timer

@export var audio: AudioStreamPlayer3D

var conversation_head = 0

var is_scrolling_to_bottom = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# advance_conversation() # HACK

func start_conversation(conversation: Conversation):
	conversation_head = 0
	self.conversation = ActiveConversation.start(conversation)
	is_scrolling_to_bottom = false
	audio.stream = conversation.them.theme
	audio.play()
	visible = true
	advance_conversation()

func advance_conversation():
	if conversation_head < len(conversation.dialogs):
		them_label.text = conversation.them.name
		
		var entry = conversation.dialogs[conversation_head]
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
	
	# Add the dialog tree from the chosen branch into the conversation.
	var chosen_branch : Branch
	for branch in conversation.dialogs[conversation_head-1].responses:
		if branch.you_said == submitted_text:
			chosen_branch = branch
	
	conversation.dialogs = (conversation.dialogs.slice(0, conversation_head, 1, true) +
		chosen_branch.dialogs + conversation.dialogs.slice(conversation_head, len(conversation.dialogs), 1, true))
	
	advance_conversation()

func on_failed_submit(submitted_text: String) -> void:
	push_warning("Failed submission: " + submitted_text)
