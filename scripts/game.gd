extends Control

@onready var text_input: RichTextLabel = $HBoxContainer/MainChatArea/VBoxContainer/PanelContainer/TextInput
@onready var option_buttons: HBoxContainer = $HBoxContainer/MainChatArea/VBoxContainer/Buttons
@onready var qs_buffer_clear_timer: Timer = $QsBufferClearTimer

var current_message : Array[Dictionary] = [
	{ word = "", pos = "start", tags = [], flags = {} }
]

var current_options : Array[Dictionary] = []
var quick_select_buffer : String
var tp_table : Dictionary
var backspaces_available := 3

func _ready() -> void:
	tp_table = Dict.load_transpositions()
	_generate_options()
	_render_message(current_message)

func capitalize(word: String) -> String:
	var trimmed : String = word.strip_edges()
	return (" " if word.begins_with(" ") else "") + trimmed[0].to_upper() + trimmed.substr(1)

func _render_message(tokens: Array[Dictionary]) -> void:
	var text := ""
	var should_capitalize := true

	for token in tokens:
		var word : String = token.word
		if token.pos in ["start", "end"]: continue

		if should_capitalize and token.pos != "jargon":
			word = capitalize(word)

		should_capitalize = token.pos == "period"

		text += word

	text = text.strip_edges()
	text_input.text = text

func _generate_options() -> void:
	current_options.clear()
	var last_token : Dictionary = current_message[-1]
	var next_pos : Array = tp_table.get("w: " + last_token.word, tp_table.get(last_token.pos, []))
	var recently_used : Array = current_message.slice(-3, current_message.size()).map(func(token): return token.word)

	var biases : Dictionary[String, int] = {}
	for tag in current_message[-1].tags:
		if tag.begins_with("bias: "):
			biases[tag.substr(6)] = biases.get(tag.substr(6), 0) + 1

	# todo level-specific terminology here

	var eligible : Array[Dictionary] = Dict.corpus.filter(func(token: Dictionary) -> bool:
		if !(token.pos in next_pos):
			return false

		if current_message.size() > 1 and token.has("is_eligible") and not token["is_eligible"].call(current_message):
			return false

		if token.word in recently_used:
			return false

		return true
	)

	eligible.shuffle() # todo better sampling that takes biases into account

	for i in range(min(8, eligible.size())):
		current_options.append(eligible[i])

	_set_option_buttons(current_options)

func _on_option_selected(index: int) -> void:
	if index < 0 or index >= current_options.size():
		return

	var selected_token : Dictionary = current_options[index]
	current_message.append(selected_token)
	backspaces_available = min(3, backspaces_available + 1)

	_render_message(current_message)
	_generate_options()

func _set_option_buttons(options: Array[Dictionary]) -> void:
	var buttons_needed : int = options.size()
	var should_capitalize : bool = current_message[-1].pos in ["period", "start"]

	if buttons_needed > option_buttons.get_child_count():
		for i in range(option_buttons.get_child_count(), buttons_needed):
			var button : Button = Button.new()
			button.connect("pressed", Callable(self, "_on_option_selected").bind(i))
			option_buttons.add_child(button)

	for i in range(option_buttons.get_child_count()):
		var button : Button = option_buttons.get_child(i)
		if i < buttons_needed:
			var word : String = options[i].word.strip_edges()
			button.text = capitalize(word) if should_capitalize else word
			button.visible = true
		else:
			button.visible = false

func _try_focusing_first_option(match: String) -> bool:
	for i in range(current_options.size()):
		var option_word : String = current_options[i].word.strip_edges().to_lower()
		if option_word.begins_with(match) and !option_buttons.get_child(i).has_focus():
			option_buttons.get_child(i).grab_focus.call_deferred()
			return true

	return false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var char_ := event.as_text().replace("Period", ".").replace("Comma", ",").replace("Minus", "—")

		if char_ == "Backspace" and backspaces_available > 0 and current_message.size() > 1:
			current_message.pop_back()
			backspaces_available -= 1
			_render_message(current_message)
			_generate_options()
			return

		if char_.length() == 1:
			qs_buffer_clear_timer.start()
			quick_select_buffer += char_.to_lower()

			if _try_focusing_first_option(quick_select_buffer):
				return

			quick_select_buffer = char_.to_lower()

			if _try_focusing_first_option(quick_select_buffer):
				return

			quick_select_buffer = ""

func _on_qs_buffer_clear_timeout() -> void:
	quick_select_buffer = ""
