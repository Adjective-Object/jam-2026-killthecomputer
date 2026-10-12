extends Node
class_name Sounds

@onready var msg_received: AudioStreamPlayer = $MsgReceived
@onready var msg_sent: AudioStreamPlayer = $MsgSent
@onready var new_match: AudioStreamPlayer = $NewMatch
@onready var typing: AudioStreamPlayer = $Typing

static var instance: Sounds

func _ready() -> void:
	instance = self

func play_msg_received():
	msg_received.volume_db = -15
	msg_received.pitch_scale = randf_range(0.92, 1.08)
	msg_received.play()

func play_msg_sent():
	msg_sent.volume_db = -15
	msg_sent.play()
	
func play_new_match():
	new_match.volume_db = -15
	new_match.pitch_scale = randf_range(0.92, 1.08)
	new_match.play()
	
func play_typing():
	print("play typing sound")
	typing.pitch_scale = randf_range(0.5, 1.2)
	typing.volume_db = randf_range(-17, -15)
	typing.play()
