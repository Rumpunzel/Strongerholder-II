@tool
@icon("uid://c4udocqr7qeyj")
class_name Profile
extends Resource

@export var name: String:
	set(new_value):
		name = new_value
		changed.emit()
@export var portrait: Texture:
	set(new_value):
		portrait = new_value
		changed.emit()
@export_color_no_alpha var color: Color:
	set(new_value):
		color = new_value
		changed.emit()

@export_category("Model")
@export var _model_variations: Array[PackedScene]:
	set(new_value):
		_model_variations = new_value
		changed.emit()
@export var _collision_shape: AreaShape = preload("uid://d27l7tjgj4lrb"):
	set(new_value):
		_collision_shape = new_value
		if not _collision_shape.changed.is_connected(changed.emit): _collision_shape.changed.connect(changed.emit)
		changed.emit()
@export var _hit_box_shape: AreaShape = preload("uid://718wpxdsx3bo"):
	set(new_value):
		_hit_box_shape = new_value
		if not _hit_box_shape.changed.is_connected(changed.emit): _hit_box_shape.changed.connect(changed.emit)
		changed.emit()
@export var _interaction_area_shape: AreaShape:
	set(new_value):
		_interaction_area_shape = new_value
		if not _interaction_area_shape.changed.is_connected(changed.emit): _interaction_area_shape.changed.connect(changed.emit)
		changed.emit()

@export var heads_up_display_offset: Vector3 = Vector3(0.0, 2.0, 0.0):
	set(new_value):
		heads_up_display_offset = new_value
		changed.emit()

@export var haunted_material: Material = preload("uid://cmbf2wnye66jw"):
	set(new_value):
		haunted_material = new_value
		haunted_material.changed.connect(changed.emit)
		changed.emit()

@export_category("")
@export_group("Configuration")

func create_model(variation: int) -> Model:
	assert(not _model_variations.is_empty())
	assert(variation >= 0)
	assert(variation < _model_variations.size())
	var model: PackedScene = _model_variations[variation]
	return model.instantiate()

func configure_collision_shape(collision_shape: CollisionShape3D) -> void:
	assert(_collision_shape)
	_collision_shape.configure_collision_shape(collision_shape)

func configure_hit_box(hit_box: CollisionShape3D) -> void:
	if not _hit_box_shape: configure_collision_shape(hit_box)
	else: _hit_box_shape.configure_collision_shape(hit_box)

func configure_interaction_area_shape(collision_shape: CollisionShape3D) -> void:
	if not _interaction_area_shape: return
	_interaction_area_shape.configure_collision_shape(collision_shape)

func configure_collision_mesh(collision_mesh: MeshInstance3D) -> void:
	assert(collision_mesh)
	_collision_shape.configure_mesh(collision_mesh)

func configure_hit_box_mesh(hit_box_mesh: MeshInstance3D) -> void:
	if not _hit_box_shape: configure_collision_mesh(hit_box_mesh)
	else: _hit_box_shape.configure_mesh(hit_box_mesh)

func configure_interaction_area_mesh(hit_box_mesh: MeshInstance3D) -> void:
	if not _interaction_area_shape:
		hit_box_mesh.mesh = null
		hit_box_mesh.position = Vector3.ZERO
		hit_box_mesh.rotation_degrees = Vector3.ZERO
		return
	_interaction_area_shape.configure_mesh(hit_box_mesh)

func get_random_variation() -> int:
	assert(not _model_variations.is_empty())
	return randi() % _model_variations.size()

func get_group_name() -> StringName:
	assert(false, "Profile.get_group_name is 'virtual' and needs to be overriden!")
	return ""

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if _model_variations.is_empty(): warnings.append("Missing model variations scene.")
	return warnings
