@icon("uid://br0wwafeqokfw")
class_name MainMenu
extends Container

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("open_menu") and not visible:
		open_menu()
		Game.request_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("close_menu") and visible:
		close_menu()
		Game.request_unpause()
		get_viewport().set_input_as_handled()

func open_menu() -> void:
	show()

func close_menu() -> void:
	hide()

func _on_continue_pressed() -> void:
	Game.request_unpause()
	close_menu()

func _on_save_pressed() -> void:
	Game.save_game()

func _on_load_pressed() -> void:
	Game.load_game()

func _on_randomize_ghost_pressed() -> void:
	EventBus.emit("random_ghost_requested")

func _on_quit_confirmation_dialog_confirmed() -> void:
	Game.quit_game()
