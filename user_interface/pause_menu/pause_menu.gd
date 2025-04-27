@tool
@icon("uid://bec8d0jsuhm7n")
class_name PauseMenu
extends CanvasLayer

signal new_game_requested
signal save_requested
signal load_requested

signal opened
signal closed

@export_group("Configuration")
@export var _new_game_button: Button
@export var _save_button: Button
@export var _load_button: Button

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	visible = get_tree().paused
	Multiplayer.joining_multiplayer.connect(_on_joining_multiplayer)
	Multiplayer.disconnected_from_multiplayer.connect(_on_disconnected_from_multiplayer)
	Client.game_paused.connect(open_menu)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_load_button.disabled = not Serializer.has_save_file(Serializer.SAVE_FILE_PATH)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	var viewport: Viewport = get_viewport()
	if event.is_action_released("open_menu") and not visible:
		open_menu()
		viewport.set_input_as_handled()
	if not visible or viewport.is_input_handled(): return
	if event.is_action_released("close_menu"):
		close_menu()
	viewport.set_input_as_handled()

func open_menu() -> void:
	if visible: return
	get_tree().call_group("HUD", "hide")
	show()
	Client.pause_game()
	opened.emit()

func close_menu() -> void:
	if not visible: return
	Client.unpause_game()
	hide()
	get_tree().call_group("HUD", "show")
	closed.emit()

func reset_menu() -> void:
	_new_game_button.disabled = false
	_save_button.disabled = false
	_load_button.disabled = false

func _on_continue_pressed() -> void:
	close_menu()

func _on_new_game_pressed() -> void:
	new_game_requested.emit()

func _on_save_pressed() -> void:
	save_requested.emit()

func _on_load_pressed() -> void:
	load_requested.emit()

func _on_randomize_ghost_pressed() -> void:
	Lobby.get_local_player().ghost_sprite_frame = randi() % 20

func _on_quit_confirmation_dialog_confirmed() -> void:
	save_requested.emit()
	Client.quit_game()

# [Multiplayer] callbacks
func _on_joining_multiplayer() -> void:
	close_menu()
	_new_game_button.disabled = true
	_save_button.disabled = true
	_load_button.disabled = true

func _on_disconnected_from_multiplayer() -> void:
	reset_menu()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings

# [Serializer] callbacks
func _on_saving_finished() -> void:
	_load_button.disabled = not Serializer.has_save_file(Serializer.SAVE_FILE_PATH)
