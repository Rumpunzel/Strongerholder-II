@tool
class_name CharacterModel
extends WorldCharacter

@export_group("Configuration")
@export var _meshes: Array[MeshInstance3D]
@export var _animation_tree: AnimationTree

@onready var _state_machine: AnimationNodeStateMachinePlayback = _animation_tree["parameters/playback"]

func play_animation(normalized_velocity: Vector3) -> void:
	if normalized_velocity:
		_state_machine.travel("Walk")
		_animation_tree.set("parameters/Walk/blend_position", normalized_velocity.length_squared())
	else:
		_state_machine.travel("Idle")

func apply_material_override(material: Material) -> void:
	for mesh: MeshInstance3D in _meshes:
		mesh.material_override = material

func apply_material_overlay(material: Material) -> void:
	for mesh: MeshInstance3D in _meshes:
		mesh.material_overlay = material

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if _meshes.is_empty(): warnings.append("No meshes referenced.")
	if not _animation_tree: warnings.append("Missing AnimationTree reference.")
	return warnings
