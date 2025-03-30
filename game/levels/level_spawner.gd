@tool
@icon("uid://byik03x1jlrlv")
class_name LevelSpawner
extends Spawner

@export_group("Configuration")
@export var _default_level: PackedScene
@export var _editor_material: Material = preload("uid://dilpjt8kd3s4d")

func _ready() -> void:
	if true or Engine.is_editor_hint():
		var level: Level = _default_level.instantiate()
		#if _editor_material: level.apply_material_override(_editor_material)
		add_child(level)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _default_level: warnings.append("Missing default level scene.")
	return warnings
