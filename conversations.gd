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
	var msg_speed: float 
	
	static func called(name: String, icon: Texture2D, color: Color, theme: AudioStream, msg_speed: float = 1.0):
		var result = Person.new()
		result.icon = icon
		result.name = name
		result.color = color
		result.theme = theme
		result.msg_speed = msg_speed
		return result
	
class Conversation:
	var them: Person
	var dialogs: Array[Dialog]
	var pause_life_timer: bool
	
	static func with(them: Person, dialogs: Array[Dialog], pause_life_timer: bool = false) -> Conversation:
		var result = Conversation.new()
		result.them = them
		result.dialogs = dialogs
		result.pause_life_timer = pause_life_timer
		return result
		
class EntitySideChat:
	var tag: String
	var dialogs: Array[Dialog]
	
	static func create(tag: String, dialogs: Array[Dialog]) -> EntitySideChat:
		var result = EntitySideChat.new()
		result.tag = tag
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
	var start_life_timer: bool = false
	var speedup_life_timer: bool = false
	var allow_midpoint_call: bool = false
	var allow_ending_call: bool = false
	var entity_side_chat: EntitySideChat
	var trigger_ending: bool = false

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
	
	static func do_start_life_timer() -> Dialog:
		var n = Dialog.new()
		n.start_life_timer = true
		return n
	
	static func do_speedup_life_timer() -> Dialog:
		var n = Dialog.new()
		n.speedup_life_timer = true
		return n
	
	static func do_allow_midpoint_call() -> Dialog:
		var n = Dialog.new()
		n.allow_midpoint_call = true
		return n
	
	static func do_allow_ending_call() -> Dialog:
		var n = Dialog.new()
		n.allow_ending_call = true
		return n
	
	static func do_entity_side_chat(tag: String, dialogs: Array[Dialog]) -> Dialog:
		var n = Dialog.new()
		n.entity_side_chat = EntitySideChat.create(tag, dialogs)
		return n
	
	static func do_trigger_ending() -> Dialog:
		var n = Dialog.new()
		n.trigger_ending = true
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

func allow_midpoint_call() -> Array[Dialog]:
	return [Dialog.do_allow_midpoint_call()]

func allow_ending_call() -> Array[Dialog]:
	return [Dialog.do_allow_ending_call()]

func start_life_timer() -> Array[Dialog]:
	return [Dialog.do_start_life_timer()]
	
func speedup_life_timer() -> Array[Dialog]:
	return [Dialog.do_speedup_life_timer()]

func entity_side_chat(tag: String, dialogs: Array[Dialog]) -> Array[Dialog]:
	return [Dialog.do_entity_side_chat(tag, dialogs)]
	
func add_conversation(conversation: Conversation) -> Array[Dialog]:
	return [Dialog.add_conversation(conversation)]

func trigger_ending() -> Array[Dialog]:
	return [Dialog.do_trigger_ending()]

var palette = preload("res://ui/colors.tres")

var octavia_icon = preload("res://ui/pfps/pfp_octavia.png")
var octavia_color = palette.colors[3]
var octavia = Person.called("octavia", octavia_icon, octavia_color, null)

var octavia_midpoint_conv = Conversation.with(octavia,
	octavia_types("ok. i've prepared and centered myself.") +
	octavia_types("do you need a video of me reciting this?") +
	you_say([
		Branch.choice("no not at all",  octavia_types("a real trust exercise. fascinating."), 1), 
		Branch.choice("that's a little excessive imo", octavia_types("blind trust is also a little excessive."), -1),
	]) +
	sleep(2) +
	octavia_types("i'm ready whenever you are. what's the passage?") +
	you_say1("\"dead wood, closed eyes, still heart, come alive\"") + 
# Player: say it 3 times in a row (idk seems excessive to have two player msgs in a row) 
	octavia_types("did you write that yourself?") + 
	you_say([
		Branch.choice("no why",
			octavia_types("oh, good. it's not very good and extremely corny.") +
			octavia_types("i knew you could do better than that."),
			-1),
		Branch.choice("and what if i did",
			octavia_types("oh. nevermind."),
			1),
	]) +
	sleep(2) +
	octavia_types("ok. reciting now.") +
	sleep(10) +
	octavia_types("my lights just went out. that's incredible timing.") +
	sleep(1) +
	octavia_types("and my heat too? that disappeared quicker than expected.") +
	sleep(1) +
	octavia_types("i think my window just shattered. is there a storm?") +
	entity_side_chat("octavia_midpoint",
		entity_says("THIS OCTAVIA GIRL HAS A LOT OF OWL STATUES") +
		entity_says("HOOT HOOT") +
		entity_says("HA HA HA HA HA")
	) +
	you_say([
		Branch.choice("do u like owls",
			octavia_types("how did you know that? yes, i do. quite a bit.") +
			octavia_types("is there actual power behind this chant?"),
			1),
		Branch.choice("u said u were fast right",
			octavia_types("i said no such thing. are you confusing me with a different girl?") +
			octavia_types("that's rather disappointing."),
			-1)
	]) +
	sleep(4) +
	octavia_types("i hear footsteps. there's someone in my apartment.") +
	octavia_types("i'm going to get them out of here. one moment.") +
	you_say1("u need to hide somewhere immediately") +
	octavia_types("you want me to let this intruder wander around my home?") + 
	entity_side_chat("octavia_midpoint",
		entity_says("WHY ARE THERE SO MANY CLOWN FIGURINES IN HERE")
	) +
	you_say([
		Branch.choice("i know it's crazy but pls just trust me",
			octavia_types("this is beyond crazy."),
			1),
		Branch.choice("go hide right now",
			octavia_types("don't speak to me that way."),
			-1),
	]) + 
	octavia_types("ok. gonna go hide. be back soon.") +
	sleep(15) +
	fail_or_pass(
		# FAIL
		entity_side_chat("octavia_midpoint",
			entity_says("SO SHE IS YELLING AT ME WHICH I DO NOT APPRECIATE") +
			entity_says("WELL TO BE SPECIFIC") +
			entity_says("SHE *WAS* YELLING AT ME") +
			entity_says("HA HA HA HA HA") +
			entity_says("I'M TAKING A CLOWN") +
			entity_says("DO YOU WANT ONE")),

		# PASS
		octavia_types("i'm back. whoever it was is gone.") +
		octavia_types("my window is also not shattered anymore. i'm not sure how that is possible.") +
		you_say1("u did it u actually did it. oh thank god") +
		octavia_types("i've done my part. do you trust me now?") + 
		you_say1("with my life") + 
		octavia_types("not possible. you have not met me. this is getting intense rather quickly.") +
		octavia_types("ugh. ok. this was fun but that's one too many red flags.") +
		octavia_types("good luck out there. do not message me again.") +
		sleep(2) +
		allow_ending_call()
	)
)

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
	sleep(2) +
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
	sleep(2) + # feels more natural to have a rest here
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
			-1),
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
		sleep(2) +
		octavia_types("this is all rather mysterious.") +
		octavia_types("but i've grown to learn that life is often that way. as much as i wish it wasn't.") +
		octavia_types("let me center myself a little. then i will be ready to recite your passage.") +
		sleep(2) + allow_midpoint_call()
	)
)

var brad_icon = preload("res://ui/pfps/pfp_brad.png")
var brad_color = palette.colors[0]
var brad = Person.called("brad", brad_icon, brad_color, null)

var brad_intro_conv = Conversation.with(brad,
	they_type(TINY_SLEEP, MEDIUM_TYPE, "test"))

var dorothy_icon = preload("res://ui/pfps/pfp_dorothy.png")
var dorothy_color = palette.colors[2]
var dorothy = Person.called("dorothy", dorothy_icon, dorothy_color, null)

func dorothy_types(msg: String, long: bool = false) -> Array[Dialog]:
	return they_type(0.8, long and 3 or 1.8, msg)

var dorothy_midpoint_conv = Conversation.with(dorothy,
	dorothy_types("OK sweet pea I'm at my Frigidaire microwave :)") +
	dorothy_types("You have some numbers for me right or did I get that wrong ?") +
	you_say([
		Branch.choice("oh you are a life saver dorothy", dorothy_types("I thought you said you were a ghost how can I be a life saver ?"), 1),
		Branch.choice("what took you so long", dorothy_types("Did I take too long sweet pea I'm so sorry it's hard for me to walk around much these days but I do try my best"), -1),
	]) +
	dorothy_types("My grandson Theo will be here in just a few minutes so I can't help for long can you p") +
	dorothy_types("lease give me the numberss you need ?") +
	you_say([
		Branch.choice("yes pls enter 665666565565",
			dorothy_types("Oh wow that's really long are you sure you need all those numbers ?") +
			dorothy_types("Most numbers aren't that long are you sure you didn't make a mistake somewhere?"),
			-1),
		Branch.choice("yes but i need to make this easier to remember",
			dorothy_types("Oh that's very true if it's a big number sweet pea I'll lose myself easily in the numbers if Theo was here he could read to me but he's not here yet I can call him if you want .", true),
			1),
	]) +
	you_say1("i'll give you the numbers a few at a time") +
	dorothy_types("Oh yes that would be wonderful for helping me keep track of it all .") + 
	dorothy_types("You are so sweet I hope you find a spouse on here someday can ghosts get legally married I heard Theo talking about something like that the other day but I couldn't quite hear .") +
	you_say([
		Branch.choice("6656", sleep(3) + dorothy_types("OK Next numbers please ."), 1),
		Branch.choice("6",
			dorothy_types("If you only give me one number at a time this will take too long I have to go when Theo gets here he wants to play a video game with me .") +
			you_say1("ok sorry 6656") +
			sleep(3) + dorothy_types("OK Next numbers please ."), -1)
	]) +
	you_say1("6656") +
	dorothy_types("Isn't that the same numbers you just gave me are you sure you read that right ?") +
	you_say([
		Branch.choice("oh my god yes just enter the numbers",
			dorothy_types("I'm sorry I make a lot of mistakes sometimes so I just like to check and make sure other people meant what they say so they feel understood and appreciated but it seems that bothered you and I'm dsappointed in myselff I will enter the numbers again .", true),
			-1),
		Branch.choice("yes they are the same again", dorothy_types("OK I understand I will enter them again :)"), 1),
	]) +
	sleep(3) +
	dorothy_types("Someone just opened my back door why is the house suddenly cold .") +
	dorothy_types("Theo never comes through the back door but I did catch my neighbor Leslie use it once while she thought I was out to try to borrow my good soup pot and she didn't think to call for permission I can't believe the gall of her sometimes .", true) +
	dorothy_types("If it is her again I will give her a piece of my mind .") +
	entity_side_chat("dorothy_midpoint", entity_says("WOW THIS OLD LADY HAS A LOT OF FINE CHINA")) +
	sleep(2) +
	dorothy_types("Something just shattered oh my goodness she's going for my soup pot !") +
	you_say([
		Branch.choice("dorothy do not go back there",
			dorothy_types("Oh it would just take a few minutes sweet pea I promise I will be back .") +
			dorothy_types("Oh wait then Theo will be here by then and I would have to leave .") +
			dorothy_types("OK I can wait to tell Leslie to get out of my house I hid the soup pot above my microwave so she'd never find it over there anyway ."),
			1),
		Branch.choice("ur just hearing things i promise",
			dorothy_types("My hearing is perfectly fine sweet pea but I appreciate you being concerned for my well being :)") +
			dorothy_types("But I have been a bit stressed lately so you could be right .") +
			dorothy_types("I just wish my grandson Theo hadn't cut his hair it was so beautiful before . "), -1)
	]) +
	sleep(1) +
	dorothy_types("How many numbers are left ?") +
	you_say1("just one more set") +
	dorothy_types("Oh wonderful may I") +
	dorothy_types("I have them please ?") +
	they_type(0.4, 0.5, "? :)") +
	sleep(1) +
	dorothy_types("Something else shattered wow Leslie really has no manners in my house I will see that she pays in full for replacements .") +
	you_say([
		Branch.choice("just swap the numbers 5565",
			dorothy_types("Swap the numbers do you mean I should start over I will need the full set of numbers again please ?") +
			you_say1("no no no this is the last set") +
			dorothy_types("Then what am I swapping ? ") +
			you_say1("forget the swapping just enter 5565") +
			dorothy_types("That was confusing for me I'm sorry you should work on your clarity skill they seem to be lacking a little ."),
			-1),
		Branch.choice("last set 5565", dorothy_types("OK one moment sweet pea :)"), 1),
	])  
)

var dorothy_intro_conv = Conversation.with(dorothy,
	they_type(TINY_SLEEP, LONGEST_TYPE, "Hello") + 
	they_type(3, LONGEST_TYPE, "Did that send ? I'") +
	sleep(0.2) + they_say("M") +
	sleep(0.5) +
	you_say([
		Branch.choice(
			"yes that sent hello!",
			they_type(LONG_SLEEP, LONG_TYPE, ":) It's nice to meet you !"),
			1),
		Branch.choice(
			"were u trying to say something?",
			they_type(LONG_SLEEP, MEDIUM_TYPE, "H ello") +
			they_type(MEDIUM_SLEEP, MEDIUM_TYPE, "Hello ?") +
			they_type(MEDIUM_SLEEP, MEDIUM_TYPE, "Hello ! It's nice to meet you !"),
			-1),
	]) +
	they_type(MEDIUM_SLEEP, LONGEST_TYPE, "My phone is a little hard ot use sometimes :)") +
	they_type(MEDIUM_SLEEP, LONG_TYPE, "But my grandson told me I should put myself back out there he helped me set this up his name is Theo do you know him ? ") +
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
			# sleep(0.5) + # extra sleep since the last message is long
			you_say([Branch.choice("that's great dorothy. would you mind helping me with something?")]),
			1
		)
	]) +
	dorothy_types("Of course sweet pea what do you need ?") +
	you_say1("i'll give it to you straight. i'm a ghost and i need help") +
	they_type(MEDIUM_SLEEP, MEDIUM_TYPE, "What ?") +
	dorothy_types("Are you going to ask me for money because the last time that happened they weren't happy when I gave them my credentials and they saw my bank account .") +
#	sleep(1) + # last message long
	you_say([
		Branch.choice(
			"i promise i don't need any money",
			dorothy_types("Then what do you need ?"),
			1),
		Branch.choice(
			"wow did u get scammed?",
			dorothy_types("Scammed why would I get scammed ?"),
			-1)
	]) +
	you_say1("okay well is there a keypad or number pad nearby") +
	dorothy_types("My microwave has one I believe .") +
	you_say([
		Branch.choice("anything other than a microwave?",
			dorothy_types("I used to have a calculator but someone stole it from me during our last bunco night I'm sorry sweet pea ."),
			-1),
		Branch.choice("perfect that will work great",
			dorothy_types("It's a Frigidaire is that okay I know some people are very particular about their microwaves ."),
			1),
	]) +
	you_say1("okay, i need you to enter a specific sequence of numbers") +
	dorothy_types("Into the microwave ?") +
	dorothy_types("Do you want me to heat something up ?") +
	you_say([
		Branch.choice("no just enter the numbers",
			dorothy_types("And then what ?"),
			-1),
		Branch.choice("if u want but it's a rly big number",
			dorothy_types("How long ?") +
			dorothy_types("I believe my microwave has a limit to how long it can run is that going to still work ?"), 1),
	]) +
	you_say1("that's it just enter the numbers") +
	dorothy_types("But then what do I put in the microwave ?") +
	you_say1("dorothy u don't put anything in the microwave") +
	dorothy_types("Then why am I using the microwave ?") +
	you_say([
		Branch.choice("i need a living person to enter the numbers anywhere to save my soul",
			dorothy_types("Oh that's so strange isn't that usually through baptism I can call Theo he knows a very good church nearby who is pro Gay and Lebanese and probably pro Gghost ?", true) +
			you_say1("this is all i need i promise"),
			1),
		Branch.choice("dorothy please",
			dorothy_types("What's wrong sweet pea are you feeling okay ?") +
			you_say1("please just go to the microwave"),
			-1)
	]) +
	fail_or_pass(
		# FAIL
		dorothy_types("Oh Theo is here goodbye this was a fun chat good luck with everything sweet pea ! :)") +
		you_say1("DOROTHY COME BACK"),
		# PASS
		dorothy_types("OK one moment please :)") +
		sleep(2) + allow_midpoint_call()
	)
)

var entity_icon = preload("res://ui/pfps/pfp_entity.png")
var entity_theme = preload("res://sounds/03 - Call Of The Void.wav")
var entity_color = palette.colors[1]
var entity = Person.called("ENTITY", entity_icon, entity_color, entity_theme)

func entity_says(msg: String) -> Array[Dialog]:
	return they_type(SMALL_SLEEP, MEDIUM_TYPE, msg)

var entity_ending_conv: Conversation = Conversation.with(entity,
	entity_says("WHAT THE FUCK") +
	entity_says("WHY DID THAT WORK") +
	you_say([
		Branch.choice("and u doubted me",
			entity_says("OF COURSE I DID") +
			entity_says("YOU SUCK")),
		Branch.choice("it did. now go away",
			entity_says("WHAT WHY") +
			entity_says("I THOUGHT WE WERE BESTIES") +
			entity_says("HA HA HA HA HA HA")),
	]) +
	entity_says("YOUR TIME WILL RUN SHORT AGAIN SOON ENOUGH") +
	entity_says("SEE YOU SOON") +
	sleep(2) +
	trigger_ending(),
	true # pause_life_timer
)

var entity_midpoint_conv: Conversation = Conversation.with(entity,
	entity_says("I CAN'T BELIEVE SOMEONE IS HELPING YOU") +
	entity_says("I ALMOST FEEL BAD FOR THEM") +
	entity_says("IF ONLY THEY KNEW HOW LAME YOU WERE") +
	you_say([
		Branch.choice("fuck u dude",
			entity_says("YOU WISH") +
			entity_says("HA HA HA HA HA HA")),
		Branch.choice("think whatever you want, my plan is working",
			entity_says("FOR NOW") +
			entity_says("HA HA HA HA HA HA")),
	]) +
	entity_says("I CAN'T WAIT TO SEE HOW THEY DO") +
	entity_says("THEY LOOK LIKE THEY SCARE EASILY") +
	entity_says("HA HA HA HA HA HA") +
	you_say1("please just leave them alone") +
	entity_says("WHERE WOULD THE FUN BE IN THAT") +
	sleep(0.4) +
	add_conversation(octavia_midpoint_conv) +
	sleep(0.4) +
	add_conversation(dorothy_midpoint_conv) +
	sleep(0.4),
	true # pause_life_meter
)

var entity_intro_conv_dialogs: Array[Dialog] = [
	Dialog.sleep(0.1),
	Dialog.typing_indicator(1.25),
	Dialog.they_say("YOU'RE LOOKING A LITTLE PALE LATELY"),
	Dialog.sleep(0.2),
	Dialog.typing_indicator(1.4),
	Dialog.they_say("DON'T TELL ME YOU CAN'T GET ANYONE TO DO YOUR RITUALS?"),
	Dialog.sleep(1),
	Dialog.you_say([
		Branch.choice(
			"i'm working on it",
			they_type(0.4, 1, "NOT WORKING ENOUGH") +
			they_type(0.4, 0.8, "HA HA HA HA HA HA")),
		Branch.choice(
			"this is rough dude",
			they_type(0.4, 1, "MAYBE FOR YOU") +
			they_type(0.4, 0.8, "HA HA HA HA HA HA")),
	]),
	Dialog.sleep(3),
	Dialog.typing_indicator(1),
	Dialog.they_say("I SEE YOU'VE RESORTED TO DATING APPS"),
	Dialog.sleep(0.4),
	Dialog.typing_indicator(1),
	Dialog.they_say("I COULD ALWAYS SMELL DESPERATION ON YOU, SO THIS IS REALLY FITTING"),
	Dialog.sleep(2),
	Dialog.typing_indicator(1),
	Dialog.they_say("YOU KNOW WHAT'S GONNA HAPPEN IF YOU FAIL, RIGHT"),
	Dialog.sleep(2),
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
	Dialog.sleep(1.2),
	Dialog.typing_indicator(1.25),
	Dialog.they_say("OH THIS WILL BE SO FUN FOR ME"),
	Dialog.sleep(1),
	Dialog.you_say([
		Branch.choice(
			"i still have time",
			they_type(0.4, 1, "BARELY")),
		Branch.choice(
			"you're sick, you know that?",
			they_type(0.4, 1, "HA HA HA HA HA HA")),
	]),
	Dialog.sleep(1),
	Dialog.you_say([
		Branch.choice(
			"i'll figure it out. leave me alone!",
			they_type(0.4, 1, "AS YOU WISH") +
			they_type(0.4, 1.2, "FOR THE LITTLE TIME YOU HAVE LEFT") +
			they_type(0.4, 1, "HA HA HA HA HA HA")),
	]),
	Dialog.do_start_life_timer(),
	Dialog.sleep(0.4),
	Dialog.add_conversation(dorothy_intro_conv),
	Dialog.sleep(0.4),
	Dialog.add_conversation(brad_intro_conv),
	Dialog.sleep(0.4),
	Dialog.add_conversation(octavia_intro_conv)
]
var entity_intro_conv = Conversation.with(
	entity, entity_intro_conv_dialogs,
	true # pause_life_meter
)
