extends Panel

@export var call_manager: MyCallManager
@export var phone: Node3D
@export var particle_emitter_hack: GPUParticles2D

func _on_button_pressed() -> void:
	particle_emitter_hack.emitting = false
	particle_emitter_hack.visible = false

	# When the game begins, the user lifts up their phone and then receives a
	# call.
	var tween: Tween = phone.create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(phone, "position", Vector3.ZERO, 2)
	tween.tween_callback(func():
		call_manager.start_call(call_manager.entity_intro_call)
	)

	visible = false
	
