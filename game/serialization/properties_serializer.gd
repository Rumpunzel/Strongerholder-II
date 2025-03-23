@tool
@icon("uid://drw5rl4ut3rge")
class_name PropertiesSerializer
extends Node

## Marks the root of this serliazier as unreliable, such as nodes created by multiplayer; are serialized asynchronously
@export var intangible: bool = false

## Optional [MultiplayerSynchronizer]; serializes synced propertes if supplied
@export var _multiplayer_synchronizer: MultiplayerSynchronizer
## Properties to seralize if no [MultiplayerSynchronizer] is supplied
#@export var _properties_to_serialize: Array[NodePath]

func _ready() -> void:
	if intangible: add_to_group("IntangibleSerializers")
	else: add_to_group("PropertiesSerializers")

## Collects all properties data
## @returns a [Dictionary] with [NodePath]s of the responsible [PropertiesSerializer] to the properties data
static func collect_properties_data(properties_serializers: Array[Node]) -> Dictionary[NodePath, Dictionary]:
	var properties_data: Dictionary[NodePath, Dictionary] = { }
	for properties_serializer: PropertiesSerializer in properties_serializers:
		# Properties are collected in a [Dictionary] with the parameter as [NodePath] to the value as a [Variant]
		var collected_properties: Dictionary[NodePath, Variant] = properties_serializer.collect_properties()
		properties_data[properties_serializer.get_path()] = collected_properties
	return properties_data

## @returns a [Dictionary] with the parameter as [NodePath] to the value as a [Variant]
func collect_properties() -> Dictionary[NodePath, Variant]:
	assert(_multiplayer_synchronizer)
	var properties_to_serialize: Array[NodePath] = _multiplayer_synchronizer.replication_config.get_properties()
	var root_node_path: NodePath = _multiplayer_synchronizer.root_path
	var root_node: Node = get_node(root_node_path)
	
	var properties_dict: Dictionary[NodePath, Variant] = { }
	for property_path: NodePath in properties_to_serialize:
		var node_path: NodePath = NodePath(property_path.get_concatenated_names())
		var node: Node = root_node.get_node(node_path)
		var property_node_path: NodePath = NodePath(property_path.get_concatenated_subnames())
		var property_value: Variant = node.get_indexed(property_node_path)
		properties_dict[property_path] = property_value
	return properties_dict

func restore_state(collected_properties: Dictionary[NodePath, Variant]) -> void:
	assert(_multiplayer_synchronizer)
	var root_node: Node = get_node(_multiplayer_synchronizer.root_path)
	for property_path: NodePath in collected_properties.keys():
		var node_path: NodePath = NodePath(property_path.get_concatenated_names())
		var node: Node = root_node.get_node(node_path)
		var property_node_path: NodePath = NodePath(property_path.get_concatenated_subnames())
		var property_value: Variant = collected_properties[property_path]
		node.set_indexed(property_node_path, property_value)
	print_debug("Restored %d properties for %s" % [collected_properties.size(), get_path()])

func serialize(save_file_path: String) -> Error:
	assert(save_file_path.is_absolute_path())
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	var collected_properties: Dictionary[NodePath, Variant] = collect_properties()
	assert(collected_properties is Dictionary[NodePath, Variant])
	var serialized_properties: String = Serialization.encode_data(collected_properties)
	save_file.store_line(serialized_properties)
	return Error.OK

func deserialize(save_file_path: String) -> Error:
	assert(FileAccess.file_exists(save_file_path))
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
	var serialized_properties: String = save_file.get_as_text()
	var collected_properties: Dictionary[NodePath, Variant] = Serialization.decode_data(serialized_properties)
	assert(collected_properties is Dictionary[NodePath, Variant])
	restore_state(collected_properties)
	return Error.OK

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	#if not _multiplayer_synchronizer and _properties_to_serialize.is_empty(): warnings.append("Nothing will be serialized!")
	#if _multiplayer_synchronizer and not _properties_to_serialize.is_empty(): warnings.append("Only MultiplayerSynchronizer OR property list is allowed!")
	return warnings
