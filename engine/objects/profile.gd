@tool
@icon("uid://c4udocqr7qeyj")
class_name Profile
extends Resource

@export var name: String
@export var portrait: Texture
@export_color_no_alpha var color: Color

@export_category("Model")
@export var collision_shape: AreaShape = preload("uid://d27l7tjgj4lrb")
@export var hit_box_shape: AreaShape = preload("uid://718wpxdsx3bo")
@export var haunted_material: Material = preload("uid://cmbf2wnye66jw")

@export var heads_up_display_offset: Vector3 = Vector3(0.0, 2.0, 0.0)

@export var _model_variations: Array[PackedScene]

@export_category("")
@export_group("Configuration")

func create_model(variation: int) -> Model:
	assert(not _model_variations.is_empty())
	var model: PackedScene
	if variation < 0:
		model = _model_variations.pick_random()
	else:
		assert(variation < _model_variations.size())
		model = _model_variations[variation]
	return model.instantiate()

func create_heads_up_anchor() -> HeadsUpAnchor:
	return HeadsUpAnchor.create(heads_up_display_offset)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if _model_variations.is_empty(): warnings.append("Missing model variations scene.")
	return warnings
