extends Node
class_name Conversations

class Person:
	var icon: Texture2D
	var name: String
	var color: Color
	var theme: AudioStream
	
	static func called(name: String, icon: Texture2D, color: Color, theme: AudioStream):
		var result = Person.new()
		result.icon = icon
		result.name = name
		result.color = color
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
		
# shorthand for Dialog.sleep + Dialog.typing_indicator + Dialog.they_say pattern
func they_say_after_sleep(sleep_duration: float, type_duration: float, msg: String) -> Array[Dialog]:
	return [Dialog.sleep(sleep_duration), Dialog.typing_indicator(type_duration), Dialog.they_say(msg)]

var palette = preload("res://ui/colors.tres")

var entity_icon = preload("res://ui/pfps/pfp_entity.tres")
var entity_theme = preload("res://sounds/03 - Call Of The Void.wav")
var entity_color = palette.colors[1]
var entity = Person.called("ENTITY", entity_icon, entity_color, entity_theme)

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
