class_name BetterMultiplayerSpawner
extends MultiplayerSpawner

@onready var spawn_node: Node = get_node(spawn_path)

func _ready() -> void:
	Game.game_joined.connect(_on_game_joined)

func get_spawnable_scene_paths() -> Array[String]:
	var spawnable_scene_count: int = get_spawnable_scene_count()
	var spawnable_scene_paths: Array[String] = [ ]
	for index: int in range(spawnable_scene_count):
		var spawnable_scene_path: String = get_spawnable_scene(index)
		spawnable_scene_paths.append(spawnable_scene_path)
	return spawnable_scene_paths

func get_all_spawned_nodes() -> Dictionary[StringName, Array]:
	var spawned_nodes: Dictionary[StringName, Array] = { }
	var spawnable_scene_paths: Array[String] = get_spawnable_scene_paths()
	for node: Node in spawn_node.get_children():
		var node_scene_path: StringName = node.scene_file_path
		if not spawnable_scene_paths.has(node_scene_path): continue
		var node_paths: Array[String] = spawned_nodes.get_or_add(node_scene_path, [ ])
		node_paths.append(node.get_path())
	return spawned_nodes

func remove_all_spawned_nodes() -> int:
	var nodes_freed: int = 0
	var spawnable_scene_paths: Array[String] = get_spawnable_scene_paths()
	for node: Node in spawn_node.get_children():
		if not spawnable_scene_paths.has(node.scene_file_path): continue
		spawn_node.remove_child(node)
		node.queue_free()
		nodes_freed += 1
	return nodes_freed

func _on_game_joined(_ip_address: StringName, _port: int) -> void:
	remove_all_spawned_nodes()
