@tool
@icon("uid://bwsawlgvt1651")
class_name PropertiesSerializer
extends Node

## Marks the root of this serliazier as unreliable, such as nodes created by multiplayer; are serialized asynchronously
@export var intangible: bool = false

@export var _synchronizer: Synchronizer

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
	return _synchronizer.collect_properties()

func restore_state(collected_properties: Dictionary[NodePath, Variant]) -> void:
	_synchronizer.restore_state(collected_properties)

func serialize(save_file_path: StringName) -> Error:
	assert(save_file_path.is_absolute_path())
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	var collected_properties: Dictionary[NodePath, Variant] = collect_properties()
	assert(collected_properties is Dictionary[NodePath, Variant])
	var serialized_properties: String = Serializer.encode_data(collected_properties)
	save_file.store_line(serialized_properties)
	return Error.OK

func deserialize(save_file_path: StringName) -> Error:
	assert(FileAccess.file_exists(save_file_path))
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
	var serialized_properties: String = save_file.get_as_text()
	var collected_properties: Dictionary[NodePath, Variant] = Serializer.decode_data(serialized_properties)
	assert(collected_properties is Dictionary[NodePath, Variant])
	restore_state(collected_properties)
	return Error.OK

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _synchronizer: warnings.append("Missing Synchronizer reference.")
	return warnings
