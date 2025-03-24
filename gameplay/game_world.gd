@icon("uid://bq2ao4pir5jfp")
extends Node

signal saving_started
signal saving_finished

signal loading_started
signal loading_finished

@onready var _kingdom: Kingdom = _initialize_kingdom()
@onready var _serializer: Serializer = _initialize_serializer()

func save_world_state(save_file_path: StringName = Game.SAVE_FILE_PATH) -> void:
	saving_started.emit()
	_serializer.serialize(save_file_path)
	saving_finished.emit()

func load_world_state(save_file_path: StringName = Game.SAVE_FILE_PATH) -> void:
	if not has_save_file(save_file_path):
		printerr("Tried to load without a save file; skipped!")
		return
	loading_started.emit()
	_serializer.deserialize(save_file_path)
	loading_finished.emit()

func has_save_file(save_file_path: StringName = Game.SAVE_FILE_PATH) -> bool:
	return FileAccess.file_exists(save_file_path)

func _initialize_kingdom() -> Kingdom:
	assert(not _kingdom)
	_kingdom = Kingdom.create()
	add_child(_kingdom)
	return _kingdom

func _initialize_serializer() -> Serializer:
	assert(not _serializer)
	_serializer = Serializer.create()
	add_child(_serializer)
	return _serializer
