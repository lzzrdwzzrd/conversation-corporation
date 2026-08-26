extends CharacterPortrait

func set_behavior(behavior: Behavior) -> void:
	push_warning("set_behavior() was not implemented for portrait %s" % name)

	match behavior:
		Behavior.NEUTRAL:
			pass
		Behavior.ANGRY:
			pass
		# teal specifically probably shouldn't have these two
		Behavior.READING:
			pass
		Behavior.SURPRISED:
			pass
