@tool
@icon("uid://byik03x1jlrlv")
class_name LevelSpawner
extends Spawner

@export_group("Configuration")

var _level: Level

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	spawn_function = _spawn_level

func unload_level() -> void:
	assert(multiplayer.is_server())
	assert(_level)
	_level.queue_free()

func _spawn_level(scene_path: String) -> Level:
	assert(not _level)
	var level_scene: PackedScene = load(scene_path)
	_level = level_scene.instantiate()
	return _level

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
