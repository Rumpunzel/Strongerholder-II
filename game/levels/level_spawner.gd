@tool
@icon("uid://byik03x1jlrlv")
class_name LevelSpawner
extends Spawner

@export_group("Configuration")

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	spawn_function = _spawn_level

func _spawn_level(scene_path: String) -> Level:
	var level_scene: PackedScene = load(scene_path)
	var level: Level = level_scene.instantiate()
	return level

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
