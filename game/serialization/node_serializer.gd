@tool
class_name NodeSerializer
extends Node

## Optional MultiplayerSpawner; serializes spawned nodes if supplied
@export var _multiplayer_spawner: MultiplayerSpawner

func _ready() -> void:
	add_to_group("NodeSerializers")
	print(serialize())

func collect_nodes() -> Dictionary[String, Array]:
	assert(_multiplayer_spawner)
	var spawnable_scene_count := _multiplayer_spawner.get_spawnable_scene_count()
	var spawnable_scene_paths: Array[String] = [ ]
	for index: int in range(spawnable_scene_count):
		var spawnable_scene_path := _multiplayer_spawner.get_spawnable_scene(index)
		print(spawnable_scene_path)
		spawnable_scene_paths.append(spawnable_scene_path)
	
	var spawn_node := get_node(_multiplayer_spawner.spawn_path)
	var nodes_to_serialize: Dictionary[String, Array] = { }
	for node: Node in spawn_node.get_children():
		var node_scene_path := node.scene_file_path
		print(node_scene_path)
		if not spawnable_scene_paths.has(node_scene_path): continue
		var node_paths: Array[NodePath] = nodes_to_serialize.get_or_add(node_scene_path, [ ])
		node_paths.append(node.get_path())
	
	return nodes_to_serialize

func parse_nodes(collected_nodes: Dictionary[String, Array]) -> void:
	assert(_multiplayer_spawner)
	var spawnable_scene_count := _multiplayer_spawner.get_spawnable_scene_count()
	var spawnable_scene_paths: Array[String] = [ ]
	for index: int in range(spawnable_scene_count):
		var spawnable_scene_path := _multiplayer_spawner.get_spawnable_scene(index)
		print(spawnable_scene_path)
		spawnable_scene_paths.append(spawnable_scene_path)
	
	# Clean state
	var spawn_node := get_node(_multiplayer_spawner.spawn_path)
	for node: Node in spawn_node.get_children():
		var node_scene_path := node.scene_file_path
		if not spawnable_scene_paths.has(node_scene_path): continue
		spawn_node.remove_child(node)
		node.queue_free()
	
	for node_scene_path: String in collected_nodes.keys():
		var node_paths: Array[NodePath] = collected_nodes[node_scene_path]
		var scene_to_spawn: PackedScene = load(node_scene_path)
		assert(scene_to_spawn is PackedScene)
		for node_path: NodePath in node_paths:
			var node_to_spawn := scene_to_spawn.instantiate()
			print(node_path)
			var parent_node_path := node_path.slice(0, -1)
			print(parent_node_path)
			var parent_node := get_node(parent_node_path)
			node_to_spawn.name = node_path.get_name(node_path.get_name_count() - 1)
			parent_node.add_child(node_to_spawn)

func serialize() -> String:
	return Serialization.encode_data(collect_nodes())

func deserialize(serialized_dict: String) -> void:
	var collected_nodes: Dictionary[String, Array] = Serialization.decode_data(serialized_dict)
	assert(collected_nodes is Dictionary[String, Array])
	parse_nodes(collected_nodes)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := [ ]
	#if not _multiplayer_synchronizer and _properties_to_serialize.is_empty(): warnings.append("Nothing will be serialized!")
	#if _multiplayer_synchronizer and not _properties_to_serialize.is_empty(): warnings.append("Only MultiplayerSynchronizer OR property list is allowed!")
	return warnings
