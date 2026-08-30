extends Control

const MESSAGE_UI = preload("uid://blo88av83s2hf")
const MESSAGE_DATA = preload("uid://crs07133xthwa")

const agendas = [
	"teal", # perception of the founder and burbleai
	"surveillance", # denial of mass surveillance
	"climate", # denial of contribution to climate change
	"trading", # denial of market manipulation and insider trading
	"air", # denial of air pollution
	"lobbying", # denial of unelected government influence
	"healthcare", # affirmation of quality of healthcare, denial of corruption
	"image", # perception of the chatbot itself
	"weasel", # deflection and evasion of responsibility
]

@export var locked_color : Color = Color(0.5, 0.5, 0.5)

@onready var text_input: RichTextLabel = $HBoxContainer/MainChatArea/VBoxContainer/PanelContainer/HBoxContainer/TextInput
@onready var option_buttons: HFlowContainer = $HBoxContainer/MainChatArea/VBoxContainer/Buttons
@onready var qs_buffer_clear_timer: Timer = $QsBufferClearTimer
@onready var pending_chats: VBoxContainer = $HBoxContainer/ChatDrawer/ScrollContainer/Levels/AwaitingResponse # if !level.get_child(-1).is_from_player
@onready var idle_chats: VBoxContainer = $HBoxContainer/ChatDrawer/ScrollContainer/Levels/Idle
@onready var button_template: Button = $HBoxContainer/ChatDrawer/ScrollContainer/Levels/ButtonTemplate # duplicate this into pending_chats and idle_chats whenever needed
@onready var levels: Node = $Levels
@onready var main_vbox: VBoxContainer = $HBoxContainer/MainChatArea/VBoxContainer
@onready var empty_label: Label = $HBoxContainer/MainChatArea/EmptyLabel
@onready var messages: VBoxContainer = $HBoxContainer/MainChatArea/VBoxContainer/Messages
@onready var send_button: Button = $HBoxContainer/MainChatArea/VBoxContainer/PanelContainer/HBoxContainer/SendButton

@onready var user_portrait: Control = $UserPortrait
@onready var name_label: Label = $UserPortrait/NameLabel
@onready var camera_label: Label = $UserPortrait/CameraLabel
var active_portrait : Control

var current_message : Array[Dictionary] = [
	{ word = "", pos = "start", tags = [], flags = {} }
]

var context_start := 1
var active_level : Node
var current_options : Array[Dictionary] = []
var quick_select_buffer : String
var backspaces_available := 3
var is_input_locked := false:
	set(value):
		is_input_locked = value

		if value:
			text_input.text = "[color=#808080]Nothing to reply to...[/color]"
			option_buttons.hide()
		else:
			_render_message(current_message)
			option_buttons.show()

var levels_completed := 0

func _ready() -> void:
	_set_level_buttons()
	empty_label.show()
	main_vbox.hide()

func capitalize(word: String) -> String:
	var trimmed : String = word.strip_edges()
	return (" " if word.begins_with(" ") else "") + trimmed[0].to_upper() + trimmed.substr(1)

func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)

func _set_can_send(can_send: bool) -> void:
	send_button.disabled = !can_send
	send_button.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN if !can_send else Control.CURSOR_POINTING_HAND
	send_button.tooltip_text = "Your message is too short!" if !can_send else ""

func _render_message(tokens: Array[Dictionary]) -> void:
	var text := ""
	var should_capitalize := true

	if tokens.size() - 1 > backspaces_available:
		text += "[color=#%s]" % locked_color.to_html(false)

	for i in range(tokens.size()):
		var token := tokens[i]
		var word : String = token.word
		if token.pos in ["start", "end"]: continue

		if should_capitalize and token.pos != "jargon":
			word = capitalize(word)

		should_capitalize = token.pos in ["period", "jargon_sentence"]

		text += word

		if i == tokens.size() - backspaces_available - 1:
			text += "[/color]"

	text = text.strip_edges()
	text_input.text = text if text else "[color=#808080]Reply as BurbleAI...[/color]"

func _generate_options() -> void:
	current_options.clear()

	var viable_templates := _get_viable_templates()
	var next_positions: Array[String] = []
	var token_biases := {}

	for token in active_level.vocabulary_biases:
		token_biases[token] = 3.0

	for tag in current_message[-1]:
		if tag.begins_with("bias:"):
			var parts : Array = tag.split(":", false, 1)
			if parts.size() == 2:
				token_biases[parts[1]] = 4.0

	for template in viable_templates:
		var index := current_message.size() - context_start

		if index < template.size():
			var pos: String = template[index]
			if pos not in next_positions:
				next_positions.append(pos)

	$HBoxContainer/MainChatArea/VBoxContainer/Label.text = "DEBUG: %s viable templates, nextpos %s" % [viable_templates.size(), "/".join(next_positions)]

	var recently_used: Array = current_message.slice(-3, current_message.size()).map(
		func(token): return token.word
	)

	var eligible: Array[Dictionary] = Dict.corpus.filter(func(token: Dictionary) -> bool:
		if token.pos not in next_positions:
			return false

		if current_message.size() > 1 and token.has("is_eligible"):
			if not token["is_eligible"].call(current_message):
				return false

		if token.word in recently_used:
			return false

		return true
	)

	eligible.shuffle()

	for i in range(min(8, eligible.size())):
		current_options.append(eligible[i])

	_set_option_buttons(current_options)

func _update_context_start() -> void:
	context_start = 1
	for i in range(current_message.size() - 1, 0, -1):
		if current_message[i].pos in ["period", "jargon_sentence"]:
			context_start = i + 1
			break

func _expand_template(template: Array, index := 0, result: Array = [], current: Array = []) -> Array:
	if index >= template.size():
		result.append(current.duplicate())
		return result

	var element: String = template[index]

	if element.ends_with("?"):
		_expand_template(template, index + 1, result, current)

	element = element.trim_suffix("?")

	if element.contains("|"):
		for sub_element in element.split("|"):
			current.append(sub_element)
			_expand_template(template, index + 1, result, current)
			current.pop_back()
	else:
		current.append(element)
		_expand_template(template, index + 1, result, current)
		current.pop_back()

	return result

func _is_template_prefix(template: Array, message: Array[Dictionary]) -> bool:
	var sentence_length := message.size() - context_start

	if sentence_length - 1 > template.size():
		return false

	for i in range(sentence_length):
		if message[context_start + i].pos != template[i]:
			return false

	return true

func _get_viable_templates() -> Array:
	var templates: Array = []

	for template in Dict.sentence_structures:
		var variants := _expand_template(template)

		for variant in variants:
			if current_message[-1].pos == variant[-1]:
				return Dict.sentence_structures

			if _is_template_prefix(variant, current_message):
				templates.append(variant)

	return templates if not templates.is_empty() else Dict.sentence_structures

func _on_option_selected(index: int) -> void:
	if index < 0 or index >= current_options.size():
		return

	var selected_token : Dictionary = current_options[index]
	current_message.append(selected_token)
	_set_can_send(current_message.size() > 3)
	backspaces_available = min(3, backspaces_available + 1)

	if selected_token.pos in ["period", "jargon_sentence"]:
		_update_context_start()

	_render_message(current_message)
	_generate_options()

func _set_option_buttons(options: Array[Dictionary]) -> void:
	var buttons_needed : int = options.size()
	var should_capitalize : bool = current_message[-1].pos in ["period", "start", "jargon_sentence"]

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

func _set_level_buttons() -> void:
	for child in pending_chats.get_children():
		child.queue_free()
	for child in idle_chats.get_children():
		child.queue_free()

	for level in levels.get_children():
		if level.completion_threshold > levels_completed:
			continue

		var button : Button = button_template.duplicate()
		button.text = level.chat_name
		button.button_pressed = active_level and level.chat_name == active_level.chat_name
		button.disabled = button.button_pressed

		if level.is_pending():
			pending_chats.add_child(button)
		else:
			idle_chats.add_child(button)

		button.show()

		if !button.button_pressed:
			button.pressed.connect(_on_level_selected.bind(level))

	$HBoxContainer/ChatDrawer/ScrollContainer/Levels/Separator.visible = pending_chats.get_child_count() > 0
	$HBoxContainer/ChatDrawer/ScrollContainer/Levels/Separator2.visible = idle_chats.get_child_count() > 0

func _on_level_selected(level: Node) -> void:
	if active_level and active_level.chat_name == level.chat_name:
		return

	if active_level:
		active_level.draft = current_message.duplicate()
		active_level.options = current_options.duplicate()
		active_level.context_start = context_start
		active_level.backspaces_available = backspaces_available

	active_level = level
	current_message = level.draft.duplicate()
	current_options = level.options.duplicate()
	context_start = level.context_start
	backspaces_available = level.backspaces_available
	is_input_locked = !level.is_pending()
	_set_can_send(!is_input_locked and current_message.size() > 3)

	empty_label.hide()
	main_vbox.show()
	_render_messages()

	if active_portrait: active_portrait.queue_free()
	active_portrait = level.user.instantiate()
	user_portrait.add_child(active_portrait)
	name_label.text = "%s, %d" % [active_portrait.full_name, active_portrait.age]
	camera_label.text = active_portrait.camera_label
	$HBoxContainer/MainChatArea/VBoxContainer/PanelContainer2/HBoxContainer/Agenda.text = "AGENDA: %s" % level.agenda_message

	if !is_input_locked:
		_render_message(current_message)
		if !current_options.size():
			_generate_options()
		else:
			_set_option_buttons(current_options)

	_set_level_buttons()

func _render_messages() -> void:
	for child in messages.get_children():
		child.queue_free()

	for message in active_level.get_children():
		var message_instance : Control = MESSAGE_UI.instantiate()
		message_instance.text = message.text_content

		message_instance.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if message.is_from_player else Control.SIZE_SHRINK_END
		message_instance.get_node("NinePatchRect").offset_transform_scale = Vector2.ONE if message.is_from_player else Vector2(-1, 1)
		message_instance.get_node("AuthorRight").visible = message.is_from_player
		message_instance.get_node("AuthorLeft").visible = !message.is_from_player

		messages.add_child(message_instance)

func _submit_answer() -> void:
	if is_input_locked or !active_level:
		return

	var message_data_instance : Node = MESSAGE_DATA.instantiate()
	message_data_instance.is_from_player = true
	message_data_instance.text_content = strip_bbcode(text_input.text.strip_edges())

	active_level.add_child(message_data_instance)

	_render_messages()
	_set_can_send(false)

	current_message = [{ word = "", pos = "start", tags = [], flags = {} }]
	active_level.options.clear()
	active_level.context_start = 1
	active_level.backspaces_available = 3
	active_level.draft = current_message.duplicate()

	current_options.clear()
	_set_option_buttons(current_options)

	context_start = 1
	active_level.backspaces_available = 3
	is_input_locked = true

	levels_completed += 1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var char_ := event.as_text().replace("Period", ".").replace("Comma", ",").replace("Minus", "—")

		if char_ == "Backspace" and backspaces_available > 0 and current_message.size() > 1:
			current_message.pop_back()
			backspaces_available -= 1

			_update_context_start()
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

func _on_send_button_pressed() -> void:
	if is_input_locked or !active_level or current_message.size() <= 3:
		return

	_submit_answer()
