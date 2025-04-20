@tool
@icon("uid://r4re5w2nnw4h")
class_name MultiplayerMenu
extends VBoxContainer

@export_group("Configuration")
@export var _player_name: BetterLineEdit
@export var _join_button: Button
@export var _ip_address: BetterLineEdit
@export var _host_button: Button
@export var _host_ip_address_button: Button

func _ready() -> void:
	update_player_name(Lobby.get_local_player().player_name)
	Multiplayer.game_hosted.connect(_on_game_hosted)
	Lobby.player_info_changed.connect(_on_player_info_changed)

func reset_menu() -> void:
	_join_button.disabled = false
	_join_button.button_pressed = false
	_ip_address.editable = true
	_host_button.disabled = false
	_host_button.button_pressed = false
	_host_ip_address_button.text = ""

func update_player_name(player_name: String) -> void:
	if _player_name.text == player_name: return
	_player_name.text = player_name

func _on_player_name_text_changed(new_player_name: String) -> void:
	var local_player: Player = Lobby.get_local_player()
	local_player.player_name = new_player_name

func _on_join_toggled(joining: bool) -> void:
	_ip_address.editable = not joining
	_host_button.disabled = joining
	if joining:
		var ip_address_to_join: StringName = _ip_address.text
		if ip_address_to_join.is_empty(): ip_address_to_join = Multiplayer.DEFAULT_SERVER_IP
		Multiplayer.join_game(ip_address_to_join)
	else: Multiplayer.disconnect_from_multiplayer()

func _on_ip_address_text_changed(new_ip_address: StringName) -> void:
	_join_button.disabled = not new_ip_address.is_empty() and not new_ip_address.is_valid_ip_address()

func _on_ip_address_text_submitted(new_ip_address: StringName) -> void:
	_on_ip_address_text_changed(new_ip_address)
	if _join_button.disabled: return
	_join_button.button_pressed = true

func _on_host_toggled(hosting: bool) -> void:
	_join_button.disabled = hosting
	_ip_address.editable = not hosting
	if hosting: Multiplayer.host_game()
	else: Multiplayer.disconnect_from_multiplayer()

# [Multiplayer] callbacks
func _on_game_hosted(host_ip_address: StringName, _port: int) -> void:
	_host_ip_address_button.text = host_ip_address

# [Lobby] callbacks
func _on_player_info_changed(player: Player) -> void:
	update_player_name(player.player_name)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _player_name: warnings.append("Missing player name reference.")
	if not _join_button: warnings.append("Missing join button reference.")
	if not _ip_address: warnings.append("Missing ip address reference.")
	if not _host_button: warnings.append("Missing host button reference.")
	if not _host_ip_address_button: warnings.append("Missing host ip address button reference.")
	return warnings
