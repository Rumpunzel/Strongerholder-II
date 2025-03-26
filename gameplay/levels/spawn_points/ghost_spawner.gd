@tool
@icon("uid://2fcoorprkcjl")
class_name GhostSpawner
extends MultiplayerSpawner

@export var ghost_spawn_point: CharacterSpawnPoint

@export_group("Configuration")
@export var _local_ghosts: Node

var _host_ghost: CharacterController

@onready var _spawn_node: Node = get_node(spawn_path)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Game.game_hosted.connect(_on_game_hosted)
	Game.game_joined.connect(_on_game_joined)
	Game.stopped_hosting_game.connect(_on_singleplayer_started)
	Game.left_game.connect(_on_singleplayer_started)
	Game.player_connected.connect(_on_player_connected)
	Game.player_disconnected.connect(_on_player_disconnected)

func _configre_host_ghost(player: Player) -> void:
	if _host_ghost:
		# Everything is as it should be
		if _host_ghost == player.character_controller: return
		_host_ghost.queue_free()
	
	_host_ghost = ghost_spawn_point.spawn_character_controller(_local_ghosts)
	_host_ghost.name = "%d" % Game.HOST_ID
	player.character_controller = _host_ghost

func _remove_all_visitor_ghosts() -> void:
	for ghost_controller: CharacterController in _spawn_node.get_children():
		_spawn_node.remove_child(ghost_controller)
		ghost_controller.queue_free()

func _on_game_hosted(_ip_address: StringName, _port: int) -> void:
	pass

func _on_game_joined(_ip_address: StringName, _port: int) -> void:
	pass

func _on_singleplayer_started() -> void:
	_remove_all_visitor_ghosts()
	#_configre_host_ghost(single_player_session.player)

func _on_player_connected(peer_id: int, player: Player) -> void:
	print("here")
	#if peer_id == multiplayer.get_unique_id(): return
	assert(player)
	for ghost_controller: CharacterController in _spawn_node.get_children():
		# CharacterController already exists, does not need to be created
		print("there")
		if ghost_controller == player.character_controller: return
		print("there 2")
	var new_ghost: CharacterController = ghost_spawn_point.spawn_character_controller(_local_ghosts)
	new_ghost.name = "%d" % peer_id
	player.character_controller = new_ghost

func _on_player_disconnected(peer_id: int, _player: Player) -> void:
	if peer_id == Game.HOST_ID: return
	var old_ghost: CharacterController = _spawn_node.get_node("%d" % peer_id)
	_spawn_node.remove_child(old_ghost)
	old_ghost.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _local_ghosts: warnings.append("Missing local ghosts Node reference.")
	return warnings
