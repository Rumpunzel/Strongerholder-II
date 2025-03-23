@tool
class_name CharacterModel
extends WorldCharacter

@export_group("Configuration")
@export var _animation_tree: AnimationTree

@onready var _state_machine: AnimationNodeStateMachinePlayback = _animation_tree["parameters/playback"]

func play_animation(normalized_velocity: Vector3) -> void:
	if normalized_velocity:
		_state_machine.travel("Walk")
		_animation_tree.set("parameters/Walk/blend_position", normalized_velocity.length_squared())
	else:
		_state_machine.travel("Idle")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _animation_tree: warnings.append("Missing AnimationTree reference.")
	return warnings
