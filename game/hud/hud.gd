@icon("uid://bigo28m2mor2y")
extends CanvasLayer

func update_available_actions(available_actions: Array[CharacterInteraction]) -> void:
	_clear_all_input_prompts()
	for available_action: CharacterInteraction in available_actions:
		var input_prompt_for_action: InputPrompt = InputPrompt.create(available_action)
		add_child(input_prompt_for_action)

func _clear_all_input_prompts() -> void:
	for input_prompt: InputPrompt in get_children():
		input_prompt.hide_prompt()
