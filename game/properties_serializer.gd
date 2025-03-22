@tool
class_name PropertiesSerializer
extends Node

## Optional MultiplayerSynchronizer; serializes synced propertes if supplied
@export var _multiplayer_synchronizer: MultiplayerSynchronizer
## Properties to seralize if no MultiplayerSynchronizer is supplied
#@export var _properties_to_serialize: Array[NodePath]

func _ready() -> void:
	add_to_group("PropertiesSerializers")

func collect_properties() -> Dictionary[NodePath, Dictionary]:
	assert(_multiplayer_synchronizer)
	var properties_to_serialize := _multiplayer_synchronizer.replication_config.get_properties()
	var root_node_path := _multiplayer_synchronizer.root_path
	var root_node := get_node(root_node_path)
	
	var properties_dict: Dictionary[NodePath, Variant] = { }
	for property_path: NodePath in properties_to_serialize:
		var property_node_path := NodePath(property_path.get_concatenated_subnames())
		var property_value: Variant = root_node.get_indexed(property_node_path)
		properties_dict[property_node_path] = property_value
	
	return { root_node_path: properties_dict }

func parse_properties(collected_properties: Dictionary[NodePath, Dictionary]) -> void:
	assert(_multiplayer_synchronizer)
	var root_node := get_node(_multiplayer_synchronizer.root_path)
	
	for property_path: NodePath in collected_properties.keys():
		var property_node_path := NodePath(property_path.get_concatenated_subnames())
		var property_value: Variant = collected_properties[property_path]
		root_node.set_indexed(property_node_path, property_value)

func serialize() -> String:
	return Serialization.encode_data(collect_properties())

func deserialize(serialized_dict: String) -> void:
	var collected_properties: Dictionary[NodePath, Dictionary] = Serialization.decode_data(serialized_dict)
	assert(collected_properties is Dictionary[NodePath, Dictionary])
	parse_properties(collected_properties)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := [ ]
	#if not _multiplayer_synchronizer and _properties_to_serialize.is_empty(): warnings.append("Nothing will be serialized!")
	#if _multiplayer_synchronizer and not _properties_to_serialize.is_empty(): warnings.append("Only MultiplayerSynchronizer OR property list is allowed!")
	return warnings
