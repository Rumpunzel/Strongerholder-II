@tool
@icon("uid://c73t2rg8wrdt3")
class_name Player
extends Synchronizer

signal player_info_changed

## Config
const PLAYER_SECTION: StringName = "player"

const ID: StringName = "player_id"
const NAME: StringName = "player_name"
const GHOST_SPRITE_FRAME: StringName = "ghost_sprite_frame"

@export var player_id: int = Multiplayer.HOST_ID:
	set(new_player_id):
		if not Engine.is_editor_hint(): name = "%d" % new_player_id
		if new_player_id == player_id: return
		player_id = new_player_id
		if Engine.is_editor_hint(): return
		set_multiplayer_authority(player_id)
		player_info_changed.emit()

@export var player_name: String:
	set(new_player_name):
		if new_player_name == player_name: return
		player_name = new_player_name
		if Engine.is_editor_hint(): return
		player_info_changed.emit()
		if not is_local_player(): return
		Client.update_value_in_config(player_name, PLAYER_SECTION, NAME)

@export var ghost_sprite_frame: int = 0:
	set(new_ghost_sprite_frame):
		if new_ghost_sprite_frame == ghost_sprite_frame: return
		ghost_sprite_frame = new_ghost_sprite_frame
		if Engine.is_editor_hint(): return
		player_info_changed.emit()
		if not is_local_player(): return
		Client.update_value_in_config(ghost_sprite_frame, PLAYER_SECTION, GHOST_SPRITE_FRAME)

@export_group("Configuration")

static func create(new_player_id: int, new_player_name: String, new_player_ghost_sprite_frame: int) -> Player:
	var new_player: Player = PackedScenes.PLAYER_SCENE.instantiate()
	new_player.player_id = new_player_id
	new_player.player_name = new_player_name
	new_player.ghost_sprite_frame = new_player_ghost_sprite_frame
	return new_player

static func get_local_player_info() -> Dictionary[StringName, Variant]:
	var local_player_id: int = Multiplayer.HOST_ID
	var local_player_name: String = Client.get_value_from_config(PLAYER_SECTION, NAME, "")
	var local_ghost_sprite_frame: int = Client.get_value_from_config(PLAYER_SECTION, GHOST_SPRITE_FRAME, 0)
	var player_info: Dictionary[StringName, Variant] = {
		ID: local_player_id,
		NAME: local_player_name if not local_player_name.is_empty() else "Player %d" % local_player_id,
		GHOST_SPRITE_FRAME: local_ghost_sprite_frame,
	}
	validate_player_info(player_info)
	return player_info

static func from_player_info(player_info: Dictionary[StringName, Variant]) -> Player:
	validate_player_info(player_info)
	var new_player_id: int = player_info[ID]
	var new_player_name: String = player_info[NAME]
	var new_ghost_sprite_frame: int = player_info[GHOST_SPRITE_FRAME]
	var new_player: Player = create(new_player_id, new_player_name, new_ghost_sprite_frame)
	return new_player

static func validate_player_info(player_info: Dictionary[StringName, Variant]) -> void:
	assert(player_info.has_all([ID, NAME, GHOST_SPRITE_FRAME]))
	assert(player_info.size() == 3)

func is_local_player() -> bool:
	if not Multiplayer.is_online(): return true
	if not is_inside_tree(): return Multiplayer.multiplayer.get_unique_id() == player_id
	return multiplayer.get_unique_id() == player_id

func get_player_info() -> Dictionary[StringName, Variant]:
	var player_info: Dictionary[StringName, Variant] = {
		ID: player_id,
		NAME: player_name if not player_name.is_empty() else "Player %d" % player_id,
		GHOST_SPRITE_FRAME: ghost_sprite_frame,
	}
	validate_player_info(player_info)
	return player_info

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
