@icon("uid://bigo28m2mor2y")
extends CanvasLayer

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Gameplay.available_action_changed.connect(_on_available_action_changed)

func clear_all_input_prompts() -> void:
	for input_prompt: InputPrompt in get_children():
		input_prompt.hide_prompt()

func _on_available_action_changed(available_actions: Array[CharacterInteraction]) -> void:
	clear_all_input_prompts()
	for available_action: CharacterInteraction in available_actions:
		var input_prompt_for_action: InputPrompt = InputPrompt.create(available_action)
		add_child(input_prompt_for_action)
