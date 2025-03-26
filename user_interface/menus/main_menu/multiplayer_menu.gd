@icon("uid://r4re5w2nnw4h")
class_name MultiplayerMenu
extends VBoxContainer

@onready var _player_name: LineEdit = %PlayerName
@onready var _join_button: Button = %Join
@onready var _ip_address: LineEdit = %IpAddress
@onready var _host_button: Button = %Host
@onready var _host_ip_address_button: Button = %HostIpAddress

func _ready() -> void:
	_on_player_name_changed(Game.player_name)
	Game.player_name_changed.connect(_on_player_name_changed)
	Game.game_hosted.connect(_on_game_hosted)
	Game.stopped_hosting_game.connect(_on_stopped_hosting_game)
	Game.disconnected_from_multiplayer.connect(_on_disconnected_from_multiplayer)

func _on_player_name_text_changed(new_player_name: String) -> void:
	Game.player_name = new_player_name

func _on_join_toggled(joining: bool) -> void:
	if joining:
		var ip_address_to_join: StringName = _ip_address.text
		if ip_address_to_join.is_empty(): ip_address_to_join = Game.DEFAULT_SERVER_IP
		Game.join_game(ip_address_to_join)
	else:
		Game.leave_game()
	_ip_address.editable = not joining
	_host_button.disabled = joining

func _on_ip_address_text_changed(new_ip_address: StringName) -> void:
	_join_button.disabled = not new_ip_address.is_empty() and not new_ip_address.is_valid_ip_address()

func _on_ip_address_text_submitted(new_ip_address: StringName) -> void:
	_on_ip_address_text_changed(new_ip_address)
	if _join_button.disabled: return
	_join_button.button_pressed = true

func _on_host_toggled(hosting: bool) -> void:
	if hosting: Game.host_game()
	else: Game.stop_hosting_game()
	_join_button.disabled = hosting
	_ip_address.editable = not hosting

# Game callbacks
func _on_player_name_changed(player_name: String) -> void:
	if _player_name.text == player_name: return
	_player_name.text = player_name

func _on_game_hosted(host_ip_address: StringName, _port: int) -> void:
	_host_ip_address_button.text = host_ip_address

func _on_stopped_hosting_game() -> void:
	_host_ip_address_button.text = ""

func _on_disconnected_from_multiplayer() -> void:
	_join_button.disabled = false
	_join_button.button_pressed = false
	_ip_address.editable = true
	_host_button.disabled = false
	_host_button.button_pressed = false
	_host_ip_address_button.text = ""
