@tool
@icon("uid://2fcoorprkcjl")
class_name PlayerGhostSpawner
extends Spawner

signal player_ghost_created(player_ghost: PlayerGhost)

signal character_haunted(haunted_character: Character, haunting_character: Character)
signal character_unhaunted(unhaunted_character: Character)

@export_group("Configuration")
@export var _character_spawner: CharacterSpawner
@export var _player_ghost_character_profile: CharacterProfile

var _player_ghosts: Dictionary[Player, PlayerGhost] = {}

func start_synching_players() -> void:
	assert(multiplayer.is_server())
	var connected_players: Array[Player] = Lobby.get_connected_players()
	for connected_player: Player in connected_players:
		create_player_ghost(connected_player)
	
	Lobby.player_connected.connect(create_player_ghost)
	Lobby.child_exiting_tree.connect(remove_player_ghost)

func stop_synching_players() -> void:
	remove_all_spawned_nodes()
	
	Lobby.player_connected.disconnect(create_player_ghost)
	Lobby.child_exiting_tree.disconnect(remove_player_ghost)

func create_player_ghost(player: Player, character: Character = _player_ghost_character_profile.create(Transform3D())) -> void:
	assert(player)
	assert(character)
	var new_player_ghost: PlayerGhost = PlayerGhost.create(player, character)
	_player_ghosts[player] = new_player_ghost
	_character_spawner.spawn_character(character)
	spawn_node.add_child(new_player_ghost, true)
	player_ghost_created.emit(new_player_ghost)

func remove_player_ghost(player: Player) -> void:
	var player_ghost_to_remove: PlayerGhost = _player_ghosts[player]
	_player_ghosts.erase(player)
	player_ghost_to_remove.character.queue_free()
	player_ghost_to_remove.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _character_spawner: warnings.append("Missing CharacterSpawner reference.")
	if not _player_ghost_character_profile: warnings.append("Missing player ghost CharacterProfile.")
	return warnings
