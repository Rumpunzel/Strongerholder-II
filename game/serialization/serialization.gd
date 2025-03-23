@icon("uid://lafgp3e7lvc3")
class_name Serialization
extends Node

const NODES: String = "nodes"
const PROPERTIES: String = "properties"
const INTANGIBLE: String = "intangible"

const SERIALIZATION_SCENE: PackedScene = preload("uid://kquuu3wv8puv")

@export_category("Toast")
@export var text_color: Color = Color(1, 1, 1, 1)
@export var background_color: Color = Color(0, 0, 0, 0.7)
@export var success_background_color: Color = Color(0, 1, 0, 0.7)
@export var error_background_color: Color = Color(1, 0, 0, 0.7)
@export_enum("top", "bottom") var gravity: String = "top"
@export_enum("left", "center", "right") var direction: String = "center"
@export var text_size: int = 18
@export var custom_toast_font: bool = false

var _queued_intangible_data: Dictionary[NodePath, Dictionary] = { }

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)

static func create() -> Serialization:
	return SERIALIZATION_SCENE.instantiate()

static func encode_data(value: Variant, full_objects: bool = false) -> String:
	return JSON.stringify(JSON.from_native(value, full_objects))

static func decode_data(string: String, allow_objects: bool = false) -> Variant:
	return JSON.to_native(JSON.parse_string(string), allow_objects)

static func merge_array_dictionaries(dictionaries: Array[Dictionary]) -> Dictionary[Variant, Array]:
	var merged_dictionary: Dictionary[Variant, Array] = { }
	for dictionary: Dictionary[Variant, Array] in dictionaries:
		assert(dictionary is Dictionary[Variant, Array])
		for key: Variant in dictionary.keys():
			var merged_arrays: Array = merged_dictionary.get_or_add(key, [ ])
			var array_to_merge: Array = dictionary[key]
			merged_arrays.append_array(array_to_merge)
	return merged_dictionary

func collect_data() -> Dictionary[String, Dictionary]:
	var node_serializers: Array[Node] = get_tree().get_nodes_in_group("NodeSerializers")
	var node_data_to_serialize: Dictionary[NodePath, Dictionary] = { }
	for node_serializer: NodeSerializer in node_serializers:
		var collected_nodes: Dictionary[String, Array] = node_serializer.collect_nodes()
		node_data_to_serialize[node_serializer.get_path()] = collected_nodes
	
	var properties_serializers: Array[Node] = get_tree().get_nodes_in_group("PropertiesSerializers")
	var properties_data_to_serialize: Dictionary[NodePath, Dictionary] = { }
	for properties_serializer: PropertiesSerializer in properties_serializers:
		var collected_properties: Dictionary[NodePath, Variant] = properties_serializer.collect_properties()
		properties_data_to_serialize[properties_serializer.get_path()] = collected_properties
	
	var intangible_serializers: Array[Node] = get_tree().get_nodes_in_group("IntangibleSerializers")
	var intangible_data_to_serialize: Dictionary[NodePath, Dictionary] = { }
	for properties_serializer: PropertiesSerializer in intangible_serializers:
		var collected_properties: Dictionary[NodePath, Variant] = properties_serializer.collect_properties()
		intangible_data_to_serialize[properties_serializer.get_path()] = collected_properties
	
	return {
		NODES: node_data_to_serialize,
		PROPERTIES: properties_data_to_serialize,
		INTANGIBLE: intangible_data_to_serialize,
	}

func parse_data(collected_data: Dictionary[String, Dictionary]) -> void:
	assert(collected_data.has_all([NODES, PROPERTIES, INTANGIBLE]))
	assert(collected_data.keys().size() == 3)
	var node_data: Dictionary[NodePath, Dictionary] = collected_data[NODES]
	assert(node_data is Dictionary[NodePath, Dictionary])
	for node_serializer_path: NodePath in node_data:
		var collected_nodes: Dictionary[String, Array] = node_data[node_serializer_path]
		assert(collected_nodes is Dictionary[String, Array])
		var node_serializer: NodeSerializer = get_node(node_serializer_path)
		assert(node_serializer)
		node_serializer.parse_nodes(collected_nodes)
	print_debug("Parsed serialized node data of size: %d" % node_data.size())
	
	await get_tree().process_frame
	
	var properties_data: Dictionary[NodePath, Dictionary] = collected_data[PROPERTIES]
	assert(properties_data is Dictionary[NodePath, Dictionary])
	for properties_serializer_path: NodePath in properties_data.keys():
		var collected_properties: Dictionary[NodePath, Variant] = properties_data[properties_serializer_path]
		assert(collected_properties is Dictionary[NodePath, Variant])
		var properties_serializer: PropertiesSerializer = get_node(properties_serializer_path)
		assert(properties_serializer)
		properties_serializer.parse_properties(collected_properties)
	print_debug("Parsed serialized properties data of size: %d" % properties_data.size())
	
	var intangible_data: Dictionary[NodePath, Dictionary] = collected_data[INTANGIBLE]
	assert(intangible_data is Dictionary[NodePath, Dictionary])
	for properties_serializer_path: NodePath in intangible_data.keys():
		var collected_properties: Dictionary[NodePath, Variant] = intangible_data[properties_serializer_path]
		assert(collected_properties is Dictionary[NodePath, Variant])
		var properties_serializer: PropertiesSerializer = get_node_or_null(properties_serializer_path)
		if properties_serializer:
			# Deserialize normally
			properties_serializer.parse_properties(collected_properties)
			# print_debug("Found INTANGIBLE PropertiesSerializer at %s; deserialization as normal!" % properties_serializer_path)
		else:
			# Queue for later deserialization
			_queued_intangible_data[properties_serializer_path] = collected_properties
			print_debug("Could not find INTANGIBLE PropertiesSerializer at %s; queuing deserialization for later..." % properties_serializer_path)
	print_debug("Parsed serialized intangible data. of size: %d" % intangible_data.size())

func serialize() -> String:
	var collected_data: Dictionary[String, Dictionary] = collect_data()
	_show_toast("Game saved!", success_background_color)
	return encode_data(collected_data)

func deserialize(serialized_dict: String) -> void:
	var collected_data: Dictionary[String, Dictionary] = decode_data(serialized_dict)
	assert(collected_data is Dictionary[String, Dictionary])
	parse_data(collected_data)
	_show_toast("Game loaded!", success_background_color)

func _show_toast(message: String, toast_background: Color = background_color) -> void:
	assert(not message.is_empty())
	ToastParty.show({
		"text": message,
		"bgcolor": toast_background,
		"color": text_color,
		"gravity": gravity,
		"direction": direction,
		"text_size": text_size,
		"use_font": custom_toast_font,
	})

func _on_node_added(node: Node) -> void:
	if _queued_intangible_data.is_empty(): return
	var node_path: NodePath = node.get_path()
	if not _queued_intangible_data.has(node_path): return
	var collected_properties: Dictionary[NodePath, Variant] = _queued_intangible_data[node_path]
	assert(collected_properties is Dictionary[NodePath, Variant])
	
	await get_tree().process_frame
	
	var properties_serializer: PropertiesSerializer = node
	properties_serializer.parse_properties(collected_properties)
	_queued_intangible_data.erase(node_path)
