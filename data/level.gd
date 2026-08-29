class_name Level
extends Node

@export var chat_name : String = "Untitled chat"
@export var is_urgent : bool = false
@export var user : PackedScene
@export var vocabulary_biases : Array[String] = []

var draft : Array[Dictionary] = []
var options : Array[Dictionary] = []
