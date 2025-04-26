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

func get_all_spawned_nodes() -> Dictionary[StringName, Array]:
	var spawned_nodes: Dictionary[StringName, Array] = super.get_all_spawned_nodes()
	var spawned_levels: Dictionary[StringName, Array] = {}
	if _level: spawned_levels[_level.scene_file_path] = [_level.get_path()]
	var merged_spawned_nodes: Variant = Serializer.merge_array_dictionaries([spawned_nodes, spawned_levels])
	return merged_spawned_nodes

func _spawn_level(level_scene_path: String) -> Level:
	assert(not _level)
	var level_scene: PackedScene = load(level_scene_path)
	return level_scene.instantiate()

func _on_child_entered_tree(node: Node) -> void:
	if not node is Level: return
	assert(not _level)
	_level = node

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
