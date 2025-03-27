@tool
@icon("uid://bwsawlgvt1651")
class_name PropertiesSerializer
extends Node

enum Type {
	## Properties will be restored normally
	NORMAL = 0,
	## Marks this serliazier as unreliable, such as multiplayer peers
	## Will try to restore normally and then potentialy restor asynchronously if not found
	INTANGIBLE = 64,
	## Marks the root of this serliazier as unreliable and important, such as state data of multiplayer peers
	## Will try to restore normally and discard if not found
	EPHEMERAL = 128,
}

@export var type: Type = Type.NORMAL

## Lower [code]restoriation_order[/code] will be restored first
## If [code]<0[/code] order is based on [code]type[/code]
@export var _restoriation_order: int = -1

@export_group("Configuration")
@export var _synchronizer: Synchronizer

var restoriation_order: int:
	get: return _restoriation_order if _restoriation_order >=0 else type

func _ready() -> void:
	add_to_group("SerializersProperties")
	var parent: Node = get_parent()
	if not _synchronizer and parent is Synchronizer:
		_synchronizer = parent

## Collects all properties data
## @returns a [Dictionary] with [int]s representing the restoration orde to a [Dictionary] [NodePath]s of the responsible [PropertiesSerializer] to the properties data
static func collect_properties_data(properties_serializers: Array[Node]) -> Dictionary[int, Dictionary]:
	var properties_data: Dictionary[int, Dictionary] = { }
	for properties_serializer: PropertiesSerializer in properties_serializers:
		# Properties are collected in a [Dictionary] with the parameter as [NodePath] to the value as a [Variant]
		var collected_properties: Dictionary[NodePath, Variant] = properties_serializer.collect_properties()
		var restoration_order: int = properties_serializer.restoriation_order
		var properties_data_for_restoration_order: Dictionary[NodePath, Dictionary] = properties_data.get_or_add(restoration_order, { } as Dictionary[NodePath, Dictionary])
		properties_data_for_restoration_order[properties_serializer.get_path()] = collected_properties
		properties_data[restoration_order] = properties_data_for_restoration_order
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
