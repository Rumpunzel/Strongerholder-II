@tool
@icon("uid://c73t2rg8wrdt3")
class_name Player
extends Synchronizer

signal player_info_changed(player_info: Dictionary[StringName, Variant])

const ID: StringName = "player_id"
const NAME: StringName = "player_name"
const GHOST_SPRITE_FRAME: StringName = "ghost_sprite_frame"

const PLAYER_SCENE: PackedScene = preload("uid://bvdlyl1asckv4")

@export var player_id: int = Multiplayer.HOST_ID:
	set(new_player_id):
		if not Engine.is_editor_hint(): name = "%d" % new_player_id
		if new_player_id == player_id: return
		player_id = new_player_id
		player_info_changed.emit(get_player_info())

@export var player_name: String:
	set(new_player_name):
		if new_player_name == player_name: return
		player_name = new_player_name
		player_info_changed.emit(get_player_info())

@export var ghost_sprite_frame: int = 0:
	set(new_ghost_sprite_frame):
		if new_ghost_sprite_frame == ghost_sprite_frame: return
		ghost_sprite_frame = new_ghost_sprite_frame
		player_info_changed.emit(get_player_info())

@export_group("Configuration")

static func create(new_player_id: int, new_player_name: String) -> Player:
	var new_player: Player = PLAYER_SCENE.instantiate()
	new_player.player_id = new_player_id
	new_player.player_name = new_player_name
	return new_player

static func from_player_info(player_info: Dictionary[StringName, Variant]) -> Player:
	validate_player_info(player_info)
	var new_player_id: int = player_info[ID]
	var new_player_name: String = player_info[NAME]
	var new_player: Player = Player.create(new_player_id, new_player_name)
	return new_player

static func validate_player_info(player_info: Dictionary[StringName, Variant]) -> void:
	assert(player_info.has_all([ID, NAME, GHOST_SPRITE_FRAME]))
	assert(player_info.size() == 3)

func is_local_player() -> bool:
	return multiplayer.multiplayer_peer == null or multiplayer.get_unique_id() == player_id

func get_player_info() -> Dictionary[StringName, Variant]:
	var player_info: Dictionary[StringName, Variant] = {
		ID: player_id,
		NAME: player_name if not player_name.is_empty() else "Player %d" % player_id,
		GHOST_SPRITE_FRAME: ghost_sprite_frame,
	}
	validate_player_info(player_info)
	return player_info

func _on_player_name_changed(new_player_name: String) -> void:
	player_name = new_player_name

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
