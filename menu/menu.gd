extends CanvasLayer

func _ready() -> void:
	Game.game_continued.connect(_on_game_continued)
	Game.game_paused.connect(_on_game_paused)

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if visible:
			Game.continue_game()
		else:
			Game.pause_game()
		get_viewport().set_input_as_handled()

func _on_game_continued() -> void:
	visible = false

func _on_game_paused() -> void:
	visible = true
