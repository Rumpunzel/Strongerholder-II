@tool
@icon("uid://2fcoorprkcjl")
class_name PlayerGhostSpawner
extends Spawner

signal player_ghost_created(player_ghost: PlayerGhost)

@export var _player_ghost_character_profile: CharacterProfile

@export_group("Configuration")

var _player_ghosts: Dictionary[Player, PlayerGhost] = {}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	var connected_players: Array[Player] = Lobby.get_connected_players()
	for connected_player: Player in connected_players:
		create_player_ghost(connected_player)
	Lobby.player_connected.connect(create_player_ghost)
	Lobby.player_disconnected.connect(create_player_ghost)

func create_player_ghost(player: Player, character: Character = _player_ghost_character_profile.create(Transform3D())) -> void:
	assert(player)
	assert(character)
	var new_player_ghost: PlayerGhost = PlayerGhost.create(player, character)
	_player_ghosts[player] = new_player_ghost
	spawn_node.add_child(new_player_ghost, true)
	player_ghost_created.emit(new_player_ghost)

func remove_player_ghost(player: Player) -> void:
	var player_ghost_to_remove: PlayerGhost = _player_ghosts[player]
	_player_ghosts.erase(player)
	player_ghost_to_remove.character.queue_free()
	player_ghost_to_remove.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _player_ghost_character_profile: warnings.append("Missing player ghost CharacterProfile.")
	return warnings
