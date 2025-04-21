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

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	spawn_function = _spawn_player_ghost

func start_synching_players() -> void:
	assert(multiplayer.is_server())
	var connected_players: Array[Player] = Lobby.get_connected_players()
	for connected_player: Player in connected_players:
		spawn_player_ghost(connected_player)
	Lobby.player_connected.connect(spawn_player_ghost)

func stop_synching_players() -> void:
	assert(multiplayer.is_server())
	remove_all_spawned_nodes()
	Lobby.player_connected.disconnect(spawn_player_ghost)

func spawn_player_ghost(player: Player) -> void:
	assert(multiplayer.is_server())
	assert(player)
	var all_player_spawn_points: Array[Node] = get_tree().get_nodes_in_group("PlayerSpawnPoints")
	assert(all_player_spawn_points.size() == 1)
	var character_spawn_point: CharacterSpawnPoint = all_player_spawn_points.front()
	assert(character_spawn_point)
	var character_data: Dictionary[StringName, Variant] = character_spawn_point.get_character_data()
	var character: Character = _character_spawner.spawn(character_data)
	assert(character)
	var player_ghost_data: Dictionary[StringName, Variant] = {
		PlayerGhost.PLAYER_ID: player.player_id,
		PlayerGhost.CHARACTER_PATH: character.get_path(),
	}
	PlayerGhost.validate_player_ghost_data(player_ghost_data)
	spawn(player_ghost_data)

func _spawn_player_ghost(player_ghost_data: Dictionary[StringName, Variant]) -> PlayerGhost:
	PlayerGhost.validate_player_ghost_data(player_ghost_data)
	var player_id: int = player_ghost_data[PlayerGhost.PLAYER_ID]
	var player: Player = Lobby.get_player(player_id)
	assert(player)
	var character_path: NodePath = player_ghost_data[PlayerGhost.CHARACTER_PATH]
	var character: Character = get_node(character_path)
	assert(character)
	var player_ghost: PlayerGhost = PlayerGhost.create(player, character)
	player.tree_exited.connect(remove_player_ghost.bind(player))
	_player_ghosts[player] = player_ghost
	player_ghost_created.emit(player_ghost)
	return player_ghost

func remove_player_ghost(player: Player) -> void:
	assert(multiplayer.is_server())
	var player_ghost_to_remove: PlayerGhost = _player_ghosts[player]
	assert(player_ghost_to_remove.player == player)
	_player_ghosts.erase(player)
	player_ghost_to_remove.character.queue_free()
	player_ghost_to_remove.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _character_spawner: warnings.append("Missing CharacterSpawner reference.")
	if not _player_ghost_character_profile: warnings.append("Missing player ghost CharacterProfile.")
	return warnings
