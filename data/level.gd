class_name Level
extends Node

@export var completion_threshold := 0

@export var chat_name : String = "Untitled chat"
@export var is_urgent : bool = false
@export var user : PackedScene
@export var vocabulary_biases : Array[String] = []

var draft : Array[Dictionary] = [{ word = "", pos = "start", tags = [], flags = {} }]
var options : Array[Dictionary] = []

var context_start := 1
var backspaces_available := 3

func is_pending() -> bool:
	return get_child_count() and !get_child(-1).is_from_player

func last_pos() -> String:
	if draft.size() > 0:
		return draft[-1].pos
	return ""
