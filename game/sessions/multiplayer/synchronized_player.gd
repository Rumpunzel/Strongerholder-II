@icon("uid://blrejsngag72k")
class_name SynchronizedPlayer
extends Node

const SYNCHRONIZED_PLAYER_SCENE: PackedScene = preload("uid://cuclrr5bep4gn")

@export var player_id: int = Game.HOST_ID:
	set(new_player_id):
		player_id = new_player_id
		name = "%d" % player_id

@export var player_name: String:
	get: return player_name if not player_name.is_empty() else "Player %d" % player_id

@export var player: Player:
	set(new_player):
		assert(new_player)
		assert(not player)
		player = new_player
		add_child(player)

func _ready() -> void:
	_configure_processing()

func _process(_delta: float) -> void:
	if player.is_disabled: return
	if not player.is_local_player: return
	assert(player_id == multiplayer.get_unique_id(), "Expected player_id %d to be equal to multiplayer.get_unique_id() but was %d!" % [player_id, multiplayer.get_unique_id()])
	assert(player_id == get_multiplayer_authority(), "Cannot process on SynchronizedPlayer without multiplayer authority!")

static func from_player(existing_player: Player) -> SynchronizedPlayer:
	var new_synchronized_player: SynchronizedPlayer = SYNCHRONIZED_PLAYER_SCENE.instantiate()
	new_synchronized_player.player_id = Game.HOST_ID
	new_synchronized_player.player_name = Game.player_name
	new_synchronized_player.player = existing_player
	return new_synchronized_player

static func from_player_info(player_info: Dictionary) -> SynchronizedPlayer:
	validate_player_info(player_info)
	var new_synchronized_player: SynchronizedPlayer = SYNCHRONIZED_PLAYER_SCENE.instantiate()
	new_synchronized_player.player_id = player_info.id
	new_synchronized_player.player_name = player_info.name
	var new_player: Player = Player.create()
	new_synchronized_player.player = new_player
	return new_synchronized_player

static func validate_player_info(player_info: Dictionary) -> void:
	assert(player_info.has_all(["id", "name"]))
	assert(player_info.keys().size() == 2)

func to_player_info() -> Dictionary:
	return { "id": player_id, "name": player_name, }

func _configure_processing() -> void:
	if not is_inside_tree():
		printerr("Trying to configure SynchronizedPlayer while outside tree, aborting!")
		return
	player.is_local_player = player_id == multiplayer.get_unique_id()
	set_multiplayer_authority.call_deferred(player_id)
