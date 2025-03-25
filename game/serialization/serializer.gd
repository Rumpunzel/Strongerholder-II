@icon("uid://lafgp3e7lvc3")
class_name Serializer
extends Node

signal serialized
signal deserialized

const NODES: StringName = "nodes"
const PROPERTIES: StringName = "properties"
const INTANGIBLE: StringName = "intangible"

const SERIALIZER_SCENE: PackedScene = preload("uid://kquuu3wv8puv")

var _queued_intangible_data: Dictionary[NodePath, Dictionary] = { }

static func create() -> Serializer:
	return SERIALIZER_SCENE.instantiate()

static func encode_data(value: Variant, full_objects: bool = false) -> String:
	return JSON.stringify(JSON.from_native(value, full_objects))

static func decode_data(string: String, allow_objects: bool = false) -> Variant:
	return JSON.to_native(JSON.parse_string(string), allow_objects)

static func merge_array_dictionaries(dictionaries: Array[Dictionary]) -> Dictionary[Variant, Array]:
	var merged_dictionary: Dictionary[Variant, Array] = { }
	for dictionary: Dictionary[Variant, Array] in dictionaries:
		assert(dictionary is Dictionary[Variant, Array])
		for key: Variant in dictionary:
			var merged_arrays: Array = merged_dictionary.get_or_add(key, [ ])
			var array_to_merge: Array = dictionary[key]
			merged_arrays.append_array(array_to_merge)
	return merged_dictionary

func serialize(save_file_path: StringName) -> Error:
	assert(save_file_path.is_absolute_path())
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	var collected_data: Dictionary[StringName, Dictionary] = collect_data()
	var serialized_game_state: String = encode_data(collected_data)
	save_file.store_line(serialized_game_state)
	serialized.emit()
	return Error.OK

func deserialize(save_file_path: StringName) -> Error:
	assert(FileAccess.file_exists(save_file_path))
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
	var serialized_game_state: String = save_file.get_as_text()
	var collected_data: Dictionary[StringName, Dictionary] = decode_data(serialized_game_state)
	assert(collected_data is Dictionary[StringName, Dictionary])
	restore_state(collected_data)
	deserialized.emit()
	return Error.OK

func collect_data() -> Dictionary[StringName, Dictionary]:
	var node_serializers: Array[Node] = get_tree().get_nodes_in_group("NodeSerializers")
	var properties_serializers: Array[Node] = get_tree().get_nodes_in_group("PropertiesSerializers")
	var intangible_serializers: Array[Node] = get_tree().get_nodes_in_group("IntangibleSerializers")
	var node_data: Dictionary[NodePath, Dictionary] = NodeSerializer.collect_node_data(node_serializers)
	var properties_data: Dictionary[NodePath, Dictionary] = PropertiesSerializer.collect_properties_data(properties_serializers)
	var intangible_data: Dictionary[NodePath, Dictionary] = PropertiesSerializer.collect_properties_data(intangible_serializers)
	return {
		NODES: node_data,
		PROPERTIES: properties_data,
		INTANGIBLE: intangible_data,
	}

func restore_state(collected_data: Dictionary[StringName, Dictionary]) -> void:
	assert(collected_data.has_all([NODES, PROPERTIES, INTANGIBLE]))
	assert(collected_data.size() == 3)
	
	var node_data: Dictionary[NodePath, Dictionary] = collected_data[NODES]
	assert(node_data is Dictionary[NodePath, Dictionary])
	restore_nodes(node_data)
	
	await get_tree().process_frame
	
	var properties_data: Dictionary[NodePath, Dictionary] = collected_data[PROPERTIES]
	assert(properties_data is Dictionary[NodePath, Dictionary])
	restore_properties(properties_data)
	
	var intangible_data: Dictionary[NodePath, Dictionary] = collected_data[INTANGIBLE]
	assert(intangible_data is Dictionary[NodePath, Dictionary])
	restore_properties(intangible_data, true)

func restore_nodes(node_data: Dictionary[NodePath, Dictionary]) -> void:
	for node_serializer_path: NodePath in node_data:
		var collected_nodes: Dictionary[StringName, Array] = node_data[node_serializer_path]
		assert(collected_nodes is Dictionary[StringName, Array])
		var node_serializer: NodeSerializer = get_node(node_serializer_path)
		assert(node_serializer)
		node_serializer.restore_state(collected_nodes)

func restore_properties(properties_data: Dictionary[NodePath, Dictionary], allow_async: bool = false) -> void:
	for properties_serializer_path: NodePath in properties_data:
		var collected_properties: Dictionary[NodePath, Variant] = properties_data[properties_serializer_path]
		assert(collected_properties is Dictionary[NodePath, Variant])
		var properties_serializer: PropertiesSerializer = get_node_or_null(properties_serializer_path)
		if properties_serializer: properties_serializer.restore_state(collected_properties)
		elif not allow_async: printerr("Could not find PropertiesSerializer at %s; skipped!" % properties_serializer_path)
		else:
			# Queue for later restoration
			_queued_intangible_data[properties_serializer_path] = collected_properties
			if not get_tree().node_added.is_connected(_on_node_added):
				get_tree().node_added.connect(_on_node_added)
				print_debug("Started listening to nodes being added...")
			print_debug("Could not find PropertiesSerializer at %s; queuing restoration for later..." % properties_serializer_path)
	if allow_async: print_debug("Queued %d intangible data..." % _queued_intangible_data.size())

func _on_node_added(node: Node) -> void:
	if _queued_intangible_data.is_empty(): return
	var node_path: NodePath = node.get_path()
	if not _queued_intangible_data.has(node_path): return
	var collected_properties: Dictionary[NodePath, Variant] = _queued_intangible_data[node_path]
	assert(collected_properties is Dictionary[NodePath, Variant])
	
	await get_tree().process_frame
	
	var properties_serializer: PropertiesSerializer = node
	properties_serializer.restore_state(collected_properties)
	_queued_intangible_data.erase(node_path)
	if _queued_intangible_data.is_empty():
		get_tree().node_added.disconnect(_on_node_added)
		print_debug("Stopped listening to nodes being added!")
