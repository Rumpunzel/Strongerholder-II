@tool
@icon("uid://c8lah4qxw5f0v")
class_name GhostSprite
extends WorldCharacter

@export_group("Configuration")
@export var _animated_sprite: AnimatedSprite3D

var _random_frame: int = -1:
	set(new_random_frame):
		if new_random_frame < 0: return
		_random_frame = new_random_frame
		_animated_sprite.frame = _random_frame

func _ready() -> void:
	_random_ghost()
	Game.random_ghost_requested.connect(_random_ghost)

func play_animation(_normalized_velocity: Vector3) -> void:
	pass

func _random_ghost() -> void:
	if _random_frame < 0: _random_frame = randi() % 19

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _animated_sprite: warnings.append("Missing AnimatedSprite3D reference.")
	return warnings + super._get_configuration_warnings()
