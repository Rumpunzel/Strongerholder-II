@tool
@icon("uid://c4udocqr7qeyj")
class_name Profile
extends Resource

@export var name: String
@export var portrait: Texture
@export_color_no_alpha var color: Color

@export_category("Attributes")
@export_custom(PROPERTY_HINT_RANGE, "0.001,1000.0,exp,suffix:kg") var mass: float = 75.0

@export_category("Model")
@export var haunted_material: Material = preload("uid://cmbf2wnye66jw")
@export var heads_up_display_offset: Vector3 = Vector3(0.0, 2.0, 0.0)

@export var _collision_shape: AreaShape = preload("uid://d27l7tjgj4lrb")
@export var _hit_box_shape: AreaShape = preload("uid://718wpxdsx3bo")
@export var _model_variations: Array[PackedScene]

@export_category("")
@export_group("Configuration")

func get_random_variation() -> int:
	assert(not _model_variations.is_empty())
	return randi() % _model_variations.size()

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

func create_heads_up_anchor() -> HeadsUpAnchor:
	return HeadsUpAnchor.create(heads_up_display_offset)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if _model_variations.is_empty(): warnings.append("Missing model variations scene.")
	return warnings
