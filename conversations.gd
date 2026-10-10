extends Node
class_name Conversations

const TINY_SLEEP: float = 0.1
const SMALL_SLEEP: float = 0.2
const MEDIUM_SLEEP: float = 0.5
const LONG_SLEEP: float = 1

const TINY_TYPE = 0.1
const MEDIUM_TYPE = 0.7
const LONG_TYPE = 1.2
const LONGEST_TYPE = 2.5
const ABSURDLY_LONG_TYPE = 5

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
	var increment: int
	
	static func choice(msg: String, dialogs: Array[Dialog] = [], increment = 0) -> Branch:
		var result = Branch.new()
		result.you_said = msg
		result.dialogs = dialogs
		result.increment = increment
		return result
 
class Cutoff:
	var fail_dialogs: Array[Dialog]
	var pass_dialogs: Array[Dialog]
	
	static func fail_or_pass(fail_dialogs: Array[Dialog], pass_dialogs: Array[Dialog]) -> Cutoff:
		var result = Cutoff.new()
		result.fail_dialogs = fail_dialogs
		result.pass_dialogs = pass_dialogs
		return result
	
class Dialog:
	var they_said: String
	var typing_indicator_duration_s: float
	var wait_duration_s: float
	var responses: Array[Branch]
	var new_conversation: Conversation
	var cutoff: Cutoff

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
		
	# Adds a conversation to the conversation tab list.
	static func add_conversation(conversation: Conversation) -> Dialog:
		var n = Dialog.new()
		n.new_conversation = conversation
		return n
		
	static func fail_or_pass(fail_dialogs: Array[Dialog], pass_dialogs: Array[Dialog]) -> Dialog:
		var n = Dialog.new()
		n.cutoff = Cutoff.fail_or_pass(fail_dialogs, pass_dialogs)
		return n
		
# shorthand for Dialog.sleep + Dialog.typing_indicator + Dialog.they_say pattern
func they_type(sleep_duration: float, type_duration: float, msg: String) -> Array[Dialog]:
	return [Dialog.sleep(sleep_duration), Dialog.typing_indicator(type_duration), Dialog.they_say(msg)]

func octavia_types(msg) -> Array[Dialog]:
	return they_type(SMALL_SLEEP, 0.8, msg)

# idk, hacky functions for Array[Dialog] + Array[Dialog] compile errors
# hopefully adding a gazillion arrays together at startup isn't slow...

func sleep(time: float) -> Array[Dialog]:
	return [Dialog.sleep(time)]
	
func they_say(msg: String) -> Array[Dialog]:
	return [Dialog.they_say(msg)]

func typing_indicator(duration_seconds: float) -> Array[Dialog]:
	return [Dialog.typing_indicator(duration_seconds)]

func you_say(options: Array[Branch]) -> Array[Dialog]:
	return [Dialog.sleep(LONG_SLEEP), Dialog.you_say(options)]

func you_say1(msg: String) -> Array[Dialog]:
	return you_say([Branch.choice(msg)])
	
func fail_or_pass(fail_dialogs: Array[Dialog], pass_dialogs: Array[Dialog]) -> Array[Dialog]:
	return [Dialog.sleep(TINY_SLEEP), Dialog.fail_or_pass(fail_dialogs, pass_dialogs)]

var palette = preload("res://ui/colors.tres")

var octavia_icon = preload("res://ui/pfps/pfp_octavia.tres")
var octavia_color = palette.colors[3]
var octavia = Person.called("Octavia", octavia_icon, octavia_color, null)

var octavia_intro_conv = Conversation.with(octavia,
	octavia_types("hello. do you have children?") +
	octavia_types("how long would you like to court before marriage?") +
	octavia_types("are you content with your current employment?") +
	you_say([
		Branch.choice(
			"no lie that's a lot all at once",
			octavia_types("what, do you want to drag this out?") +
			octavia_types("what's your stance on abortion?") +
			you_say([Branch.choice("holy moly", octavia_types("?"))]),
			-1),
		Branch.choice(
			"no, up for discussion, definitely not",
			octavia_types("mixed bag. i can work with this."),
			1)
	]) +
	octavia_types("there's so much garbage on this website. it's unbelievable.") +
	octavia_types("some guy tried to pitch his edm album to me an hour ago.") +
	octavia_types("i request that you tell me your red flags right now.") +
	you_say([
		Branch.choice(
			"i'm dead",
			octavia_types("ok. bad at jokes. i can still work with this."),
			1),
		Branch.choice(
			"i don't have any",
			octavia_types("that's a red flag. not possible.") +
			octavia_types("marking that as a future discussion point."),
			-1)
	]) +
	octavia_types("despite my hopes, you are the most normal candidate so far.") +
	octavia_types("do you have any questions for me?") +
	octavia_types("any requirements? must-haves?") +
	you_say([
		Branch.choice(
			"yes i do have something",
			octavia_types("what is it?"),
			1),
		Branch.choice(
			"i just can't tell if i can trust u lol",
			octavia_types("you barely know me, so why would you be able to?"),
			-1
		)
	]) +
	you_say1("can you prove your trustworthiness to me") +
	octavia_types("is this necessary in order for us to keep discussing our potential future?") +
	you_say([
		Branch.choice(
			"there is no future without this for me", 
			octavia_types("ok. i hear you loud and clear.") +
			octavia_types("i appreciate your candidness. tell me what to do."),
			1),
		Branch.choice(
			"in a way, ya...",
			octavia_types("the vagueness is not appreciated. another red flag."),
			-1)
	]) +
	you_say1("i need u to recite something for me") +
	octavia_types("like a poem? a passage?") +
	octavia_types("how would this prove anything to you? is there more?") +
	you_say([
		Branch.choice(
			"then u need to hide for three minutes",
			octavia_types("hide?") +
			octavia_types("i can tuck myself into a small box. i developed this skill during my four years of circus training.") +
			octavia_types("i can't believe i'm already talking about that. you've really opened up my heart."),
			1),
		Branch.choice(
			"yes but i'm sure u will figure it out",
			octavia_types("i appreciate the confidence but would like more information.") +
			octavia_types("unless that is part of the test. hm."),
			-1)
	]) +
	fail_or_pass(
		# FAIL
		octavia_types("i'm starting to sour on this arrangement. i sense you are yet another freak online.") +
		you_say1("wait no") +
		octavia_types("i wish you well in your weird endeavor. goodbye."),
		# PASS
		octavia_types("this is all rather mysterious.") +
		octavia_types("but i've grown to learn that life is often that way. as much as i wish it wasn't.") +
		octavia_types("let me center myself a little. then i will be ready to recite your passage.")
		# TODO: Trigger entity part 2
	)
)

var brad_icon = preload("res://ui/pfps/pfp_brad.tres")
var brad_color = palette.colors[0]
var brad = Person.called("Brad", brad_icon, brad_color, null)

var brad_intro_conv = Conversation.with(brad,
	they_type(TINY_SLEEP, MEDIUM_TYPE, "test"))

var dorothy_icon = preload("res://ui/pfps/pfp_dorothy.tres")
var dorothy_color = palette.colors[2]
var dorothy = Person.called("Dorothy", dorothy_icon, dorothy_color, null)

var dorothy_intro_conv = Conversation.with(dorothy,
	they_type(TINY_SLEEP, LONGEST_TYPE, "Hello") + 
	they_type(LONG_SLEEP, LONGEST_TYPE, "Did that send ? I'") +
	sleep(0.1) + they_say("M") +
	you_say([
		Branch.choice(
			"yes that sent hello!",
			they_type(SMALL_SLEEP, LONG_TYPE, ":) It's nice to meet you !"),
			1),
		Branch.choice(
			"were u trying to say something?",
			they_type(SMALL_SLEEP, MEDIUM_TYPE, "H ello") +
			they_type(SMALL_SLEEP, MEDIUM_TYPE, "Hello ?") +
			they_type(SMALL_SLEEP, MEDIUM_TYPE, "Hello ! It's nice to meet you !"),
			-1),
	]) +
	they_type(SMALL_SLEEP, LONGEST_TYPE, "My phone is a little hard ot use sometimes :)") +
	they_type(SMALL_SLEEP, LONG_TYPE, "But my grandson told me I should put myself back out there he helped me set this up his name is Theo do you know him ? ") +
	you_say([
		Branch.choice(
			"no lol i really doubt it",
			they_type(MEDIUM_SLEEP, MEDIUM_TYPE, "Really that's surprising usually eve") +
			they_type(SMALL_SLEEP, MEDIUM_TYPE, "Everyone knows him .") +
			they_type(SMALL_SLEEP, LONG_TYPE, "Do you like to stay home do you not have a lot of friends it's okay if you don't of course ?") +
			you_say([Branch.choice("yeah something like that. can you help me with something?")]),
			-1
		),
		Branch.choice(
			"maybe. describe him to me?",
			they_type(MEDIUM_SLEEP, ABSURDLY_LONG_TYPE, "He has brown eyes and short brown hair he did buzz his hair off last week but before he had really long hair it was very charming all the way down to his knees I don't know why he cut it off one of my neighbors even asked me if he was going through a crisis and I had to tell Leslie to mind her own business she loves getting into things that are none of her business but she makes th ebest brownie batter ice cream have you had it? ") +
			you_say([Branch.choice("that's great dorothy. would you mind helping me with something?")]),
			1
		)
	])
	# TODO: Finish this
)

var entity_icon = preload("res://ui/pfps/pfp_entity.tres")
var entity_theme = preload("res://sounds/03 - Call Of The Void.wav")
var entity_color = palette.colors[1]
var entity = Person.called("ENTITY", entity_icon, entity_color, entity_theme)

var entity_intro_conv_dialogs: Array[Dialog] = [
	#Dialog.sleep(0.1),
	#Dialog.typing_indicator(1.25),
	#Dialog.they_say("YOU'RE LOOKING A LITTLE PALE LATELY"),
	#Dialog.sleep(0.2),
	#Dialog.typing_indicator(1.4),
	#Dialog.they_say("DON'T TELL ME YOU CAN'T GET ANYONE TO DO YOUR RITUALS?"),
	#Dialog.sleep(1),
	#Dialog.you_say([
		#Branch.choice(
			#"I'm working on it!",
			#they_type(0.4, 1, "NOT WORKING ENOUGH") +
			#they_type(0.4, 0.8, "HA HA HA HA HA HA")),
		#Branch.choice(
			#"It's rough out here, dude.",
			#they_type(0.4, 1, "MAYBE FOR YOU") +
			#they_type(0.4, 0.8, "HA HA HA HA HA HA")),
	#]),
	#Dialog.sleep(0.4),
	#Dialog.typing_indicator(1),
	#Dialog.they_say("I SEE YOU'VE RESORTED TO DATING APPS"),
	#Dialog.sleep(0.4),
	#Dialog.typing_indicator(1),
	#Dialog.they_say("I COULD ALWAYS SMELL DESPERATION ON YOU, SO THIS IS REALLY FITTING"),
	#Dialog.sleep(0.4),
	#Dialog.typing_indicator(1),
	#Dialog.they_say("YOU KNOW WHAT'S GONNA HAPPEN IF YOU FAIL, RIGHT"),
	#Dialog.sleep(0.4),
	#Dialog.typing_indicator(1),
	#Dialog.they_say("FINAL DEATH"),
	#Dialog.sleep(0.4),
	#Dialog.typing_indicator(1),
	#Dialog.they_say("THE BIG ONE"),
	#Dialog.sleep(0.4),
	#Dialog.typing_indicator(1),
	#Dialog.they_say("AND I GET TO SEND YOU THERE"),
	#Dialog.sleep(0.4),
	#Dialog.typing_indicator(1),
	#Dialog.they_say("HA HA HA HA HA"),
	#Dialog.sleep(0.4),
	#Dialog.typing_indicator(1.25),
	#Dialog.they_say("OH THIS WILL BE SO FUN FOR ME"),
	#Dialog.sleep(1),
	#Dialog.you_say([
		#Branch.choice(
			#"I still have time!",
			#they_type(0.4, 1, "BARELY")),
		#Branch.choice(
			#"You're sick, you know that?",
			#they_type(0.4, 1, "HA HA HA HA HA HA")),
	#]),
	#Dialog.sleep(1),
	#Dialog.you_say([
		#Branch.choice(
			#"I'll figure it out. Leave me alone!",
			#they_type(0.4, 1, "AS YOU WISH") +
			#they_type(0.4, 1.2, "FOR THE LITTLE TIME YOU HAVE LEFT") +
			#they_type(0.4, 1, "HA HA HA HA HA HA")),
	#]),
	Dialog.sleep(0.2),
	Dialog.typing_indicator(1.0),
	Dialog.they_say("(skipping this conversation for brevity)"),
	Dialog.sleep(0.4),
	Dialog.add_conversation(dorothy_intro_conv),
	Dialog.sleep(0.4),
	Dialog.add_conversation(brad_intro_conv),
	Dialog.sleep(0.4),
	Dialog.add_conversation(octavia_intro_conv)
]
var entity_intro_conv = Conversation.with(entity, entity_intro_conv_dialogs)
