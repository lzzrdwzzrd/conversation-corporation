class_name CharacterPortrait
extends Control

enum Behavior {
	NEUTRAL,
	READING,
	SURPRISED,
	ANGRY,
}

@export var portrait : Texture2D
@export var full_name := "John U. Doe"
@export var camera_label := "User (Front-facing camera #0)"
@export var age := 30

func set_behavior(behavior: Behavior) -> void:
	push_warning("set_behavior() was not implemented for portrait %s" % name)

	match behavior:
		Behavior.NEUTRAL:
			pass
		Behavior.READING:
			pass
		Behavior.SURPRISED:
			pass
		Behavior.ANGRY:
			pass
