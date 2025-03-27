@tool
@icon("uid://dv6mpdxcuq5j5")
class_name Agent
extends Node

const AGENT_SCENE: PackedScene = preload("uid://bbjgxgkshjet6")

@export var character: Character:
	set(new_character):
		character = new_character
		if not character:
			_character_path = NodePath()
			return
		if not character.is_inside_tree(): await character.ready
		_character_path = character.get_path()

## This is used for serialization purposes; serves otherwise no purpose
var _character_path: NodePath:
	get: return character.get_path() if character else NodePath()
	set(new_character_path):
		if new_character_path == _character_path: return
		if character or _character_path.is_empty(): return
		await get_tree().process_frame
		character = get_node(_character_path)

static func create(existing_character: Character) -> Agent:
	var new_agent: Agent = AGENT_SCENE.instantiate()
	new_agent.character = existing_character
	return new_agent

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
