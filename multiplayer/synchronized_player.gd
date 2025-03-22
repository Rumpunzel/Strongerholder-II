class_name SynchronizedPlayer
extends Player

@export var player_id := 1:
	set(new_player_id):
		player_id = new_player_id
		name = "%d" % player_id
		set_multiplayer_authority.call_deferred(player_id)

@export var player_name: String

var _player_scene: PackedScene = load("uid://ckcrpkujohkql")

func _ready() -> void:
	var is_local_player := player_id == multiplayer.get_unique_id()
	_camera.current = is_local_player
	var is_authorized := get_multiplayer_authority() == multiplayer.get_unique_id()
	if not is_authorized:
		does_process = false
		return

func _process(_delta: float) -> void:
	assert(player_id == multiplayer.get_unique_id(), "Expected player_id %d to be equal to multiplayer.get_unique_id() but was %d!" % [player_id, multiplayer.get_unique_id()])
	assert(player_id == get_multiplayer_authority(), "Cannot process on SynchronizedPlayer without multiplayer authority!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("toggle_menu"):
		UserInterface.menu.show_menu()
		get_viewport().set_input_as_handled()

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

func to_player_info() -> Dictionary:
	return { "id": player_id, "name": player_name, }

func to_player() -> Player:
	var new_player: Player = _player_scene.instantiate()
	new_player.character_controller = character_controller
	return new_player
