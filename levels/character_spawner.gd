extends MultiplayerSpawner

@export var king: Character
@export var rogue: Character

@onready var spawn_node := get_node(spawn_path)

func _ready() -> void:
	pass

func _remove_all_characters() -> void:
	for character_controller: CharacterController in spawn_node.get_children():
		spawn_node.remove_child(character_controller)
		character_controller.queue_free()

func _on_singleplayer_started(player: Player) -> void:
	_remove_all_characters()
	var new_character: CharacterController = king.create()
	spawn_node.add_child(new_character, true)
	player.character_controller = new_character

func _on_singleplayer_stopped() -> void:
	_remove_all_characters()

func _on_player_connected(peer_id: int, player: SynchronizedPlayer) -> void:
	if player == null:
		printerr("no player")
		return
	var new_character: CharacterController = king.create() if peer_id == Multiplayer.HOST_ID else rogue.create()
	new_character.name = "%d" % peer_id
	spawn_node.add_child(new_character, true)
	player.character_controller = new_character

func _on_player_disconnected(peer_id: int) -> void:
	var old_ghost := spawn_node.get_node("%d" % peer_id)
	spawn_node.remove_child(old_ghost)
	old_ghost.queue_free()
