@tool
@icon("uid://bec8d0jsuhm7n")
class_name MainMenu
extends CanvasLayer

@export_group("Configuration")
@export var _multiplayer_menu: MultiplayerMenu

@onready var _main: MainNode = Main
@onready var _serializer: SerializerNode = Serializer

func _ready() -> void:
	if Engine.is_editor_hint():
		var edited_scene: Node = EditorInterface.get_edited_scene_root()
		visible = edited_scene == self or edited_scene == owner
		return
	visible = get_tree().paused

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_released("open_menu") and not visible:
		open_menu()
		_main.pause_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("close_menu") and visible:
		close_menu()
		get_viewport().set_input_as_handled()

func open_menu() -> void:
	show()

func close_menu() -> void:
	_main.unpause_game()
	hide()

func _on_continue_pressed() -> void:
	close_menu()

func _on_save_pressed() -> void:
	_serializer.save_world_state()

func _on_load_pressed() -> void:
	_serializer.load_world_state()

func _on_randomize_ghost_pressed() -> void:
	#Game.random_ghost_requested.emit()
	pass

func _on_quit_confirmation_dialog_confirmed() -> void:
	_main.quit_game()

# [Multiplayer] callbacks
func _on_local_player_name_changed(player_name: String) -> void:
	_multiplayer_menu.update_player_name(player_name)

func _on_disconnected_from_multiplayer() -> void:
	_multiplayer_menu.reset_menu()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _multiplayer_menu: warnings.append("Missing MultiplayerMenu reference.")
	return warnings
