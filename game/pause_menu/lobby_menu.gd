@tool
class_name LobbyMenu
extends PanelContainer

func _ready() -> void:
	var connected_players: Array[Player] = Lobby.get_connected_players()
	for connected_player: Player in connected_players:
		create_player_info(connected_player)
	
	Lobby.player_connected.connect(create_player_info)
	Lobby.player_disconnected.connect(remove_player_info)

@export_group("Configuration")
@export var _player_infos_container: Control
@export var _player_info_scene: PackedScene

var _player_infos: Dictionary[Player, PlayerInfo] = {}

func create_player_info(player: Player) -> void:
	assert(player)
	var new_player_info: PlayerInfo = _player_info_scene.instantiate()
	new_player_info.player = player
	_player_infos[player] = new_player_info
	_player_infos_container.add_child(new_player_info, true)

func remove_player_info(player: Player) -> void:
	var player_info_to_remove: PlayerInfo = _player_infos[player]
	_player_infos.erase(player)
	player_info_to_remove.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _player_infos_container: warnings.append("Missing player infos container.")
	if not _player_info_scene: warnings.append("Missing PlayerInfo reference.")
	return warnings
