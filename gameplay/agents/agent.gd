@icon("uid://dv6mpdxcuq5j5")
class_name Agent
extends Node

const AGENT_SCENE: PackedScene = preload("uid://bbjgxgkshjet6")

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		_check_disabled()
		if not character_controller:
			character = null
			_character_controller_path = NodePath()
			return
		character = character_controller.character
		_character_controller_path = character_controller.get_path()

@export_group("Configuration")
@export var _hit_box: HitBox

var character: Character:
	set(new_character):
		character = new_character
		_hit_box.character = character

var is_disabled: bool = false:
	set(new_is_disabled):
		is_disabled = new_is_disabled
		_hit_box.visible = not is_disabled

## This is used for serialization purposes; serves otherwise no purpose 
var _character_controller_path: NodePath:
	set(new_character_controller_path):
		_character_controller_path = new_character_controller_path
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_check_disabled()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if is_disabled: return
	assert(character_controller)
	_hit_box.follow_node(character_controller)

static func create(existing_character_controller: CharacterController) -> Agent:
	var new_agent: Agent = AGENT_SCENE.instantiate()
	new_agent.character_controller = existing_character_controller
	return new_agent

func _check_disabled() -> void:
	if Engine.is_editor_hint(): return
	is_disabled = not character_controller

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _hit_box: warnings.append("Missing HitBox reference.")
	return warnings
