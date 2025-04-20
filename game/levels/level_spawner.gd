@tool
@icon("uid://byik03x1jlrlv")
class_name LevelSpawner
extends Spawner

@export_group("Configuration")
@export var _default_level: PackedScene

func spawn_level(scene: PackedScene = _default_level) -> void:
	var level: Level = scene.instantiate()
	add_child(level)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _default_level: warnings.append("Missing default level scene.")
	return warnings
