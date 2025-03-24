@tool
@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends CharacterArea

var current_interaction: HitBox

##
var _priority_index: int = 0:
	set(new_priority_index):
		_priority_index = (new_priority_index + hit_boxes_in_area.size()) % hit_boxes_in_area.size()

func nearest_hit_box_in_area() -> HitBox:
	return hit_boxes_in_area[_priority_index] if not hit_boxes_in_area.is_empty() else null
	#var nearest_hit_box: HitBox = null
	#var distance_to_nearest_hit_box: float = INF
	#for near_hit_box: HitBox in hit_boxes_in_area:
		#if not nearest_hit_box_in_area or position.distance_squared_to(near_hit_box.position) < distance_to_nearest_hit_box:
			#nearest_hit_box = near_hit_box
	#return nearest_hit_box

func _setup_collision_shape() -> void:
	collision_shape = character.interaction_area_shape.create_collision_shape()
	super._setup_collision_shape()

func _on_hit_box_entered(hit_box: HitBox) -> void:
	if current_interaction: return
	current_interaction = hit_box
	print("current_interaction: %s" % current_interaction.get_parent().name)

func _on_hit_box_exited(hit_box: HitBox) -> void:
	if hit_box != current_interaction: return
	current_interaction = nearest_hit_box_in_area()
	_priority_index = 0
	if current_interaction: print("current_interaction: %s" % current_interaction.get_parent().name)
	else: print("current_interaction: Nothing")
