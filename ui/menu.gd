class_name Menu
extends Control

func _enter_tree() -> void:
	Game.game_paused.connect(popup)
	Game.game_continued.connect(popdown)

func popup() -> void:
	show()

func popdown() -> void:
	hide()

func _on_continue_pressed() -> void:
	Game.continue_game()

func _on_quit_confirmation_dialog_confirmed() -> void:
	Game.quit_game()
