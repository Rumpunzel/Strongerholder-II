@tool
@icon("uid://c8lah4qxw5f0v")
class_name GhostSprite
extends CharacterModel

@export_group("Configuration")
@export var _animated_sprite: AnimatedSprite3D

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_random_ghost()
	Game.random_ghost_requested.connect(_random_ghost)

func play_animation(_normalized_velocity: Vector3) -> void:
	pass

func _random_ghost() -> void:
	_animated_sprite.frame = randi() % 19

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _animated_sprite: warnings.append("Missing AnimatedSprite3D reference.")
	return warnings + super._get_configuration_warnings()
