@tool
@icon("uid://duke3cveuxxso")
class_name CharacterSpawner
extends MultiplayerSpawner

@export_group("Configuration")
@export var _character_spawn_points: CharacterSpawnPoints

@onready var _spawn_node: Node = get_node(spawn_path)

func _ready() -> void:
	assert(_character_spawn_points)
	_character_spawn_points.spawn_all_character_controllers(_spawn_node)

func _remove_all_characters() -> void:
	for character_controller: CharacterController in _spawn_node.get_children():
		_spawn_node.remove_child(character_controller)
		character_controller.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _character_spawn_points: warnings.append("Missing CharacterSpawnPoints reference.")
	return warnings
