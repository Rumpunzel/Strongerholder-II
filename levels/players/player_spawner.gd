extends MultiplayerSpawner

@export var _player_scene: PackedScene = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _on_player_spawn

func _on_player_spawn(player_id: int) -> Player:
	if not _player_scene:
		printerr("No player scene specified!")
		return
	var player: Player = _player_scene.instantiate()
	player.player_id = player_id
	player.name = str(player_id)
	# Give authority over the player input to the appropriate peer.
	#player.get_node("InputSynchronizer").set_multiplayer_authority(player_id)
	print_debug("Spawned player <%d>" % player_id)
	return player
