class_name SynchronizedPlayer
extends Player

const SYNCHRONIZED_PLAYER_SCENE: PackedScene = preload("uid://cuclrr5bep4gn")

@export var player_id := Game.HOST_ID:
	set(new_player_id):
		player_id = new_player_id
		name = "%d" % player_id

@export var player_name: String

func _ready() -> void:
	super._ready()
	_configure_processing()

func _process(delta: float) -> void:
	super._process(delta)
	assert(player_id == multiplayer.get_unique_id(), "Expected player_id %d to be equal to multiplayer.get_unique_id() but was %d!" % [player_id, multiplayer.get_unique_id()])
	assert(player_id == get_multiplayer_authority(), "Cannot process on SynchronizedPlayer without multiplayer authority!")

static func from_player(player: Player) -> SynchronizedPlayer:
	assert(not player is  SynchronizedPlayer)
	var new_player: SynchronizedPlayer = SYNCHRONIZED_PLAYER_SCENE.instantiate()
	new_player.player_id = Game.HOST_ID
	new_player.player_name = Game.session.player_name
	new_player.character_controller = player.character_controller
	return new_player

static func from_player_info(player_info: Dictionary) -> SynchronizedPlayer:
	validate_player_info(player_info)
	var synchronized_player_scene: PackedScene = load("uid://cuclrr5bep4gn")
	var new_player: SynchronizedPlayer = synchronized_player_scene.instantiate()
	new_player.player_name = player_info.name
	assert(new_player.player_name == player_info.name)
	new_player.player_id = player_info.id
	assert(new_player.player_id == player_info.id)
	return new_player

static func validate_player_info(player_info: Dictionary) -> void:
	assert(player_info.has_all(["id", "name"]))
	assert(player_info.keys().size() == 2)

func to_player() -> Player:
	var new_player: Player = PLAYER_SCENE.instantiate()
	new_player.character_controller = character_controller
	return new_player

func to_player_info() -> Dictionary:
	return { "id": player_id, "name": player_name, }

func _configure_processing() -> void:
	if not is_inside_tree():
		printerr("Trying to configure SynchronizedPlayer while outside tree, aborting!")
		return
	var is_local_player := player_id == multiplayer.get_unique_id()
	if _camera: _camera.current = is_local_player
	does_process = is_local_player
	set_multiplayer_authority.call_deferred(player_id)
