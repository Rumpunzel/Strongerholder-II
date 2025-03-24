@tool
@icon("uid://drw5rl4ut3rge")
class_name NodeSerializer
extends Node

@export var _multiplayer_spawner: MultiplayerSpawner

func _enter_tree() -> void:
	var parent: Node = get_parent()
	if not _multiplayer_spawner and parent is MultiplayerSpawner:
		_multiplayer_spawner = parent

## Collects all data for dynamically spawned nodes
## @returns a [Dictionary] with [NodePath]s of the responsible [NodeSerializer]s to the node data
static func collect_node_data(node_serializers: Array[Node]) -> Dictionary[NodePath, Dictionary]:
	var node_data: Dictionary[NodePath, Dictionary] = { }
	for node_serializer: NodeSerializer in node_serializers:
		# Nodes are collected in a Dictionar with scene paths to NodePaths
		var collected_nodes: Dictionary[StringName, Array] = node_serializer.collect_nodes()
		node_data[node_serializer.get_path()] = collected_nodes
	return node_data

## @returns a [Dictionary] with scene paths to [NodePath]s
func collect_nodes() -> Dictionary[StringName, Array]:
	assert(_multiplayer_spawner)
	var spawnable_scene_count: int = _multiplayer_spawner.get_spawnable_scene_count()
	# All scene paths spawned by the MultiplayerSpawner
	var spawnable_scene_paths: Array[StringName] = [ ]
	for index: int in range(spawnable_scene_count):
		var spawnable_scene_path: StringName = _multiplayer_spawner.get_spawnable_scene(index)
		spawnable_scene_paths.append(spawnable_scene_path)
	
	var spawn_node: Node = get_node(_multiplayer_spawner.spawn_path)
	# Nodes are collected in a Dictionar with scene paths to NodePaths
	var nodes_to_serialize: Dictionary[StringName, Array] = { }
	for node: Node in spawn_node.get_children():
		var node_scene_path: NodePath = node.scene_file_path
		if not spawnable_scene_paths.has(node_scene_path): continue
		var node_paths: Array[NodePath] = nodes_to_serialize.get_or_add(node_scene_path, [ ])
		node_paths.append(node.get_path())
	return nodes_to_serialize

func restore_state(collected_nodes: Dictionary[StringName, Array]) -> void:
	assert(_multiplayer_spawner)
	var spawnable_scene_count: int = _multiplayer_spawner.get_spawnable_scene_count()
	var spawnable_scene_paths: Array[StringName] = [ ]
	for index: int in range(spawnable_scene_count):
		var spawnable_scene_path: NodePath = _multiplayer_spawner.get_spawnable_scene(index)
		spawnable_scene_paths.append(spawnable_scene_path)
	
	# Clean state
	var nodes_freed: int = 0
	var spawn_node: Node = get_node(_multiplayer_spawner.spawn_path)
	for node: Node in spawn_node.get_children():
		var node_scene_path: StringName = node.scene_file_path
		if not spawnable_scene_paths.has(node_scene_path): continue
		spawn_node.remove_child(node)
		node.queue_free()
	print_debug("Removed %d nodes for %s" % [nodes_freed, get_path()])
	
	var nodes_restored: int = 0
	for node_scene_path: StringName in collected_nodes.keys():
		var node_paths: Array[NodePath] = collected_nodes[node_scene_path]
		var scene_to_spawn: PackedScene = load(node_scene_path)
		assert(scene_to_spawn is PackedScene)
		for node_path: NodePath in node_paths:
			var node_to_spawn: Node = scene_to_spawn.instantiate()
			var parent_node_path: NodePath = node_path.slice(0, -1)
			var parent_node: Node = get_node(parent_node_path)
			node_to_spawn.name = node_path.get_name(node_path.get_name_count() - 1)
			parent_node.add_child(node_to_spawn)
	print_debug("Restored %d nodes for %s" % [nodes_restored, get_path()])

func serialize(save_file_path: StringName) -> Error:
	assert(save_file_path.is_absolute_path())
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	var collected_nodes: Dictionary[StringName, Array] = collect_nodes()
	assert(collected_nodes is Dictionary[StringName, Array])
	var serialized_nodes: String = Serializer.encode_data(collected_nodes)
	save_file.store_line(serialized_nodes)
	return Error.OK

func deserialize(save_file_path: StringName) -> Error:
	assert(FileAccess.file_exists(save_file_path))
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
	var serialized_nodes: String = save_file.get_as_text()
	var collected_nodes: Dictionary[StringName, Array] = Serializer.decode_data(serialized_nodes)
	assert(collected_nodes is Dictionary[StringName, Array])
	restore_state(collected_nodes)
	return Error.OK

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _multiplayer_spawner: warnings.append("Missing MultiplayerSpawner reference.")
	return warnings
