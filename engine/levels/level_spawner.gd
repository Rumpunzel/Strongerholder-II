@tool
@icon("uid://byik03x1jlrlv")
class_name LevelSpawner
extends Spawner

@export_group("Configuration")

var _level: Level

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	spawn_function = _spawn_level

func _ready() -> void:
	super._ready()

func load_level(level_scene_path: String) -> void:
	assert(multiplayer.is_server())
	assert(not _level)
	spawn(level_scene_path)

func unload_level() -> void:
	assert(multiplayer.is_server())
	assert(_level)
	remove_child(_level)
	_level.queue_free()
	_level = null

func _spawn_level(level_scene_path: String) -> Level:
	assert(not _level)
	var level_scene: PackedScene = load(level_scene_path)
	_level = level_scene.instantiate()
	return _level

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
