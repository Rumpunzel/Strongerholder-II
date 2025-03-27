@tool
@icon("uid://dv6mpdxcuq5j5")
class_name Agent
extends Node

const AGENT_SCENE: PackedScene = preload("uid://bbjgxgkshjet6")

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		if not character_controller:
			_character_controller_path = NodePath()
			return
		if not character_controller.is_inside_tree(): await character_controller.ready
		_character_controller_path = character_controller.get_path()

## This is used for serialization purposes; serves otherwise no purpose
var _character_controller_path: NodePath:
	get: return character_controller.get_path() if character_controller else NodePath()
	set(new_character_controller_path):
		if new_character_controller_path == _character_controller_path: return
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

static func create(existing_character_controller: CharacterController) -> Agent:
	var new_agent: Agent = AGENT_SCENE.instantiate()
	new_agent.character_controller = existing_character_controller
	return new_agent

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	return warnings
