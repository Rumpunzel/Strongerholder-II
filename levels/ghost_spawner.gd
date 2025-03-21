extends MultiplayerSpawner

@export var ghost: Character

@export var _host_ghosts: Node3D

var _host_ghost: CharacterController

@onready var spawn_node := get_node(spawn_path)

func _ready() -> void:
	Game.singleplayer_node.started.connect(_on_singleplayer_started)
	Game.singleplayer_node.stopped.connect(_on_singleplayer_stopped)
	
	Game.multiplayer_node.player_connected.connect(_on_player_connected)
	Game.multiplayer_node.player_disconnected.connect(_on_player_disconnected)

func _configre_host_ghost(player: Player) -> void:
	if _host_ghost:
		# Everything is as it should be
		if _host_ghost == player.character_controller: return
		_host_ghosts.remove_child(_host_ghost)
		_host_ghost.queue_free()
	
	_host_ghost = ghost.create()
	_host_ghost.name = "%d" % Multiplayer.HOST_ID
	_host_ghosts.add_child(_host_ghost, true)
	player.character_controller = _host_ghost

func _remove_all_host_ghosts() -> void:
	for ghost_controller: CharacterController in spawn_node.get_children():
		spawn_node.remove_child(ghost_controller)
		ghost_controller.queue_free()

func _on_singleplayer_started(player: Player) -> void:
	_remove_all_host_ghosts()
	_configre_host_ghost(player)

func _on_singleplayer_stopped(_host_from_singleplayer: SynchronizedPlayer) -> void:
	_remove_all_host_ghosts()

func _on_player_connected(peer_id: int, player: SynchronizedPlayer) -> void:
	if peer_id == multiplayer.get_unique_id(): return
	assert(player)
	for ghost_controller: CharacterController in spawn_node.get_children():
		# CharacterController already exists, does not need to be created
		if ghost_controller == player.character_controller:
			return
	var new_ghost: CharacterController = ghost.create()
	new_ghost.name = "%d" % peer_id
	spawn_node.add_child(new_ghost, true)
	player.character_controller = new_ghost

func _on_player_disconnected(peer_id: int) -> void:
	if peer_id == Multiplayer.HOST_ID: return
	var old_ghost := spawn_node.get_node("%d" % peer_id)
	spawn_node.remove_child(old_ghost)
	old_ghost.queue_free()
