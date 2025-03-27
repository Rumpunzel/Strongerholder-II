@tool
@icon("uid://bec8d0jsuhm7n")
class_name MainMenu
extends CanvasLayer

signal unpause_requested
signal quit_requested

signal player_name_change_requested(player_name: String)

signal host_game_requested
signal stop_hosting_game_requested

signal join_game_requested(ip_address_to_join: StringName)
signal leave_game_requested

@export_group("Configuration")
@export var multiplayer_menu: MultiplayerMenu

func _ready() -> void:
	if Engine.is_editor_hint():
		visible = false
		return
	visible = get_tree().paused

func open_menu() -> void:
	if visible: return
	show()

func close_menu() -> void:
	if not visible: return
	hide()

func _on_continue_pressed() -> void:
	unpause_requested.emit()
	close_menu()

func _on_save_pressed() -> void:
	Gameplay.request_save()

func _on_load_pressed() -> void:
	Gameplay.request_load()

func _on_randomize_ghost_pressed() -> void:
	#GameplayGame.random_ghost_requested.emit()
	pass

func _on_quit_confirmation_dialog_confirmed() -> void:
	quit_requested.emit()

# [MultiplayerMenu] callbacks
func _on_player_name_change_requested(player_name: String) -> void:
	player_name_change_requested.emit(player_name)
	
func _on_host_game_requested() -> void:
	host_game_requested.emit()

func _on_stop_hosting_game_requested() -> void:
	stop_hosting_game_requested.emit()

func _on_join_game_requested(ip_address_to_join: StringName) -> void:
	join_game_requested.emit(ip_address_to_join)

func _on_leave_game_requested() -> void:
	leave_game_requested.emit()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not multiplayer_menu: warnings.append("Missing MultiplayerMenu reference.")
	return warnings
