extends CharacterPortrait

@onready var mouth_thing_timer: Timer = $SubViewportContainer/SubViewport/Background/Teal/MouthThing/MouthThingTimer

func _ready() -> void:
	mouth_thing_timer.wait_time = randf_range(30.0, 60.0)
	mouth_thing_timer.start()

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


func _on_mouth_thing_timeout() -> void:
	$SubViewportContainer/SubViewport/Background/Teal/MouthThing.play("thing")
	mouth_thing_timer.wait_time = randf_range(30.0, 60.0)


func _on_blink_cycle_finished(anim_name: StringName) -> void:
	if randf() < 0.1:
		$SubViewportContainer/SubViewport/Background/Teal/BlinkCycle.play("EyeThing")
	else:
		$SubViewportContainer/SubViewport/Background/Teal/BlinkCycle.play("loop")
