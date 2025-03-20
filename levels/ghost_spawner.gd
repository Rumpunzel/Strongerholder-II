extends MultiplayerSpawner

@export var king_scene: PackedScene
@export var rogue_scene: PackedScene

func _ready() -> void:
	Game.multiplayer_node.player_connected.connect(_on_player_connected)
	Game.multiplayer_node.player_disconnected.connect(_on_player_disconnected)

func _on_player_connected(peer_id: int, _player_info: Dictionary, player: SynchronizedPlayer) -> void:
	if player == null:
		printerr("no player")
		return
	var new_ghost: CharacterController = king_scene.instantiate() if peer_id == Multiplayer.HOST_ID else rogue_scene.instantiate()
	new_ghost.name = "%d" % peer_id
	%Ghosts.add_child(new_ghost)
	player.character = new_ghost

func _on_player_disconnected(peer_id: int) -> void:
	var old_ghost := %Ghosts.get_node("%d" % peer_id)
	%Ghosts.remove_child(old_ghost)
	old_ghost.queue_free()
