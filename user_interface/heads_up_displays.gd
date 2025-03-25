@icon("uid://bs3bnvm5r50sd")
extends Control

var _input_prompts: Dictionary[StringName, InputPrompt] = { }

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Game.available_action_changed.connect(_on_available_action_changed)

func clear_all_input_prompts() -> void:
	for input_prompt: InputPrompt in _input_prompts.values():
		input_prompt.hide_prompt()
	_input_prompts.clear()

func _on_available_action_changed(available_actions: Array[StringName], heads_up_anchor: HeadsUpAnchor = null) -> void:
	# heads_up_anchor must not be null unless available_actions is empty
	assert(available_actions.is_empty() == (heads_up_anchor == null))
	clear_all_input_prompts()
	for available_action: StringName in available_actions:
		var input_events_for_action: Array[InputEvent] = InputMap.action_get_events(available_action)
		var input_prompt_for_action: InputPrompt = InputPrompt.create(input_events_for_action, heads_up_anchor)
		_input_prompts[available_action] = input_prompt_for_action
		add_child(input_prompt_for_action)
