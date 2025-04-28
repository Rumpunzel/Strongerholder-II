@tool
@icon("uid://cpbv0myc0qfxb")
class_name PreviewModel
extends RigidBody3D

signal profile_changed

## Determines the varation of the [Model]
## If [code]<0[/code] a random [Model] will be used
@export var variation: int = -1:
	set(new_variation):
		if new_variation == variation: return
		variation = new_variation
		if not profile: return
		if not model: return
		model = profile.create_model(variation)

@export var profile: Profile:
	set(new_profile):
		profile = new_profile
		if not profile:
			model = null
			_collision_shape.shape = null
			_collision_shape.position = Vector3.ZERO
			_collision_shape.rotation_degrees = Vector3.ZERO
			_collision_mesh.mesh = null
			_collision_mesh.position = Vector3.ZERO
			_collision_mesh.rotation_degrees = Vector3.ZERO
			_hit_box_mesh.mesh = null
			_hit_box_mesh.position = Vector3.ZERO
			_hit_box_mesh.rotation_degrees = Vector3.ZERO
			_heads_up_anchor.position = Vector3.ZERO
			profile_changed.emit()
			return
		if variation < 0: variation = profile.get_random_variation()
		model = profile.create_model(variation)
		profile.configure_collision_shape(_collision_shape)
		profile.configure_collision_mesh(_collision_mesh)
		profile.configure_hit_box_mesh(_hit_box_mesh)
		print(_collision_mesh.mesh)
		_heads_up_anchor.position = get_heads_up_anchor()
		profile_changed.emit()

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D
@export var _collision_mesh: MeshInstance3D
@export var _hit_box_mesh: MeshInstance3D
@export var _heads_up_anchor: HeadsUpAnchor

var model: Model:
	set(new_model):
		if model:
			remove_child(model)
			model.queue_free()
		model = new_model
		if not model: return
		add_child(model, true)

func play_animation(normalized_velocity: Vector3, is_on_floor: bool) -> void:
	model.play_animation(normalized_velocity, is_on_floor)

func get_portrait() -> Texture:
	if model.portrait_override:
		return model.portrait_override
	return profile.portrait

func get_heads_up_anchor() -> Vector3:
	return position + profile.heads_up_display_offset

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	return warnings
