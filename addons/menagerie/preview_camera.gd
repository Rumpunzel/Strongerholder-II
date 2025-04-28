@tool
extends Camera3D

@export var _preview_model: PreviewModel

func _ready() -> void:
	_look_at_preview_model()

func _look_at_preview_model() -> void:
	var character_position: Vector3 = _preview_model.position
	var heads_up_anchor: Vector3 = _preview_model.get_heads_up_anchor()
	var look_position: Vector3 = (character_position + heads_up_anchor) / 2.0
	look_at(look_position)
