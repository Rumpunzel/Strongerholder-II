@tool
@icon("uid://bec8d0jsuhm7n")
class_name PauseMenu
extends CanvasLayer

signal opened
signal closed

@export_group("Configuration")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	visible = get_tree().paused
	Client.game_paused.connect(open_menu)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_released("open_menu") and not visible:
		open_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("close_menu") and visible:
		close_menu()
		get_viewport().set_input_as_handled()

func open_menu() -> void:
	if visible: return
	show()
	Client.pause_game()
	opened.emit()

func close_menu() -> void:
	if not visible: return
	Client.unpause_game()
	hide()
	closed.emit()

func _on_continue_pressed() -> void:
	close_menu()

func _on_save_pressed() -> void:
	Serializer.save_world_state()

func _on_load_pressed() -> void:
	Serializer.load_world_state()

func _on_randomize_ghost_pressed() -> void:
	Lobby.get_local_player().ghost_sprite_frame = randi() % 20

func _on_quit_confirmation_dialog_confirmed() -> void:
	Client.quit_game()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
