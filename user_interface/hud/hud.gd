@icon("uid://bigo28m2mor2y")
class_name HUD
extends CanvasLayer

func _ready() -> void:
	if not is_multiplayer_authority():
		hide()

func update_available_actions(available_actions: Array[Interaction]) -> void:
	_clear_all_input_prompts()
	for available_action: Interaction in available_actions:
		var input_prompt_for_action: InputPrompt = InputPrompt.create(available_action)
		add_child(input_prompt_for_action)

func _clear_all_input_prompts() -> void:
	for input_prompt: InputPrompt in get_children():
		input_prompt.hide_prompt()

func _on_available_actions_changed(available_actions: Array[Interaction]) -> void:
	update_available_actions(available_actions)
