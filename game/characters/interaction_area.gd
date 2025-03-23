@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends Area3D

signal hit_box_entered(hit_box: HitBox)
signal hit_box_exited(hit_box: HitBox)

var hit_boxes_in_area: Array[HitBox] = [ ]

func follow_character(character_controller: CharacterController) -> void:
	transform = character_controller.transform

func _on_area_entered(area: Area3D) -> void:
	if not area is HitBox: return
	hit_boxes_in_area.append(area)
	hit_box_entered.emit(area)

func _on_area_exited(area: Area3D) -> void:
	if not area is HitBox: return
	hit_boxes_in_area.erase(area)
	hit_box_exited.emit(area)
