@tool
class_name PlayerInfo
extends PanelContainer

@export var player: Player:
	set(new_player):
		player = new_player
		_update_player_info()
		player.player_info_changed.connect(_update_player_info)

@export_group("Configuration")
@export var _ghost_sprite: TextureRect
@export var _player_name: Label

func _update_player_info() -> void:
	print("there")
	name = "%d" % player.player_id
	_player_name.text = player.player_name
	var ghost_sprites: AnimatedTexture = _ghost_sprite.texture
	ghost_sprites.current_frame = player.ghost_sprite_frame

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _ghost_sprite: warnings.append("Missing ghost sprite.")
	if not _player_name: warnings.append("Missing player name.")
	return warnings
