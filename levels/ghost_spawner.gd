extends MultiplayerSpawner

@export var king: Character
@export var rogue: Character

@onready var spawn_node := get_node(spawn_path)

func _ready() -> void:
	Game.singleplayer_node.started.connect(_on_singleplayer_started)
	Game.singleplayer_node.stopped.connect(_on_singleplayer_stopped)
	
	Game.multiplayer_node.player_connected.connect(_on_player_connected)
	Game.multiplayer_node.player_disconnected.connect(_on_player_disconnected)

func _remove_all_ghosts() -> void:
	for old_ghost: CharacterController in spawn_node.get_children():
		spawn_node.remove_child(old_ghost)
		old_ghost.queue_free()

func _on_singleplayer_started(player: Player) -> void:
	_remove_all_ghosts()
	var new_ghost: CharacterController = king.create()
	print(new_ghost.character.resource_path)
	spawn_node.add_child(new_ghost, true)
	player.character_controller = new_ghost

func _on_singleplayer_stopped() -> void:
	_remove_all_ghosts()

func _on_player_connected(peer_id: int, _player_info: Dictionary, player: SynchronizedPlayer) -> void:
	if player == null:
		printerr("no player")
		return
	var new_ghost: CharacterController = king.create() if peer_id == Multiplayer.HOST_ID else rogue.create()
	new_ghost.name = "%d" % peer_id
	print(new_ghost.character.resource_path)
	spawn_node.add_child(new_ghost, true)
	player.character_controller = new_ghost

func _on_player_disconnected(peer_id: int) -> void:
	var old_ghost := spawn_node.get_node("%d" % peer_id)
	spawn_node.remove_child(old_ghost)
	old_ghost.queue_free()
