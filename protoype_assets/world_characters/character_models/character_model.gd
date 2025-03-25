@tool
class_name CharacterModel
extends WorldCharacter

@onready var _meshes: Array[MeshInstance3D] = gather_all_geometry_instances_on(self)

@export_group("Configuration")
@export var _animation_tree: AnimationTree

@onready var _state_machine: AnimationNodeStateMachinePlayback = _animation_tree["parameters/playback"]

static func gather_all_geometry_instances_on(node: Node) -> Array[MeshInstance3D]:
	var geometry_instances: Array[MeshInstance3D] = [ ]
	for child: Node in node.get_children():
		if child is MeshInstance3D: geometry_instances.append(child)
		geometry_instances.append_array(gather_all_geometry_instances_on(child))
	return geometry_instances

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
	if not _animation_tree: warnings.append("Missing AnimationTree reference.")
	return warnings + super._get_configuration_warnings()
