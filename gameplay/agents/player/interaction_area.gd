@tool
@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends CharacterArea

@export var selection_material: Material

var current_interaction: HitBox:
	set(new_current_interaction):
		if current_interaction: current_interaction.apply_material_overlay(null)
		current_interaction = new_current_interaction
		if not current_interaction: return
		current_interaction.apply_material_overlay(selection_material)

func nearest_hit_box_in_area() -> HitBox:
	var nearest_hit_box: HitBox = null
	var distance_to_nearest_hit_box: float = INF
	for near_hit_box: HitBox in hit_boxes_in_area:
		if not nearest_hit_box_in_area or position.distance_squared_to(near_hit_box.position) < distance_to_nearest_hit_box:
			nearest_hit_box = near_hit_box
	return nearest_hit_box

func _setup_collision_shape() -> void:
	_collision_shape = _character.interaction_area_shape.create_collision_shape()
	super._setup_collision_shape()

func _on_hit_box_entered(hit_box: HitBox) -> void:
	if current_interaction: return
	current_interaction = hit_box

func _on_hit_box_exited(hit_box: HitBox) -> void:
	if hit_box != current_interaction: return
	current_interaction = nearest_hit_box_in_area()
