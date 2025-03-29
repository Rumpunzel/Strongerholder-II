@tool
@icon("uid://7ukvgik2xafc")
class_name PlayerGhostSpawner
extends Spawner

@export_group("Configuration")

var _player_ghosts: Dictionary[Player, PlayerGhost] = {}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	var connected_players: Array[Player] = Lobby.get_connected_players()
	for connected_player: Player in connected_players:
		create_player_ghost(connected_player)
	Lobby.player_connected.connect(create_player_ghost)
	Lobby.player_disconnected.connect(create_player_ghost)

func create_player_ghost(player: Player) -> void:
	var new_player_ghost: PlayerGhost = PlayerGhost.create()
	spawn_node.add_child(new_player_ghost, true)
	_player_ghosts[player] = new_player_ghost

func remove_player_ghost(player: Player) -> void:
	_player_ghosts.erase(player)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
