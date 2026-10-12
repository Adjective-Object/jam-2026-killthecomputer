extends Node
class_name Flags

# singleton of flags for easy lookup from anywhere
# it's the last day of the jam and i'm sleepy

static var instance: Flags

var flags: Array[String]

func _ready() -> void:
	instance = self
	flags = []
	
func is_flag_set(flag: String):
	return flag in flags
	
func set_flag(flag: String):
	if not is_flag_set(flag):
		flags.append(flag)
