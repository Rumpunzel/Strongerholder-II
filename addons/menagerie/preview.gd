@tool
@icon("uid://cl8p01b5kagvw")
extends Node3D

@export_custom(PROPERTY_HINT_RANGE, "0.0,360.0,suffix:°") var _turn_increment_min: float = 2.0
@export_custom(PROPERTY_HINT_RANGE, "0.0,360.0,suffix:°") var _turn_increment_max: float = 32.0
@export var _turn_time: float = 0.1

var _target_rotation: float = 0.0:
	set(new_target_rotation):
		_target_rotation = new_target_rotation
		if _tween: _tween.kill()
		if not get_tree(): return
		_tween = get_tree().create_tween()
		_tween.tween_property(self, "rotation_degrees:y", _target_rotation, _turn_time)

var _tween: Tween

func _calculate_turn_increment() -> float:
	var turn_modifier: float = 1.0 + fmod(abs(_target_rotation - rotation_degrees.y), 180.0)
	return clampf(turn_modifier, _turn_increment_min, _turn_increment_max)

func _on_model_view_turned_left() -> void:
	_target_rotation += _calculate_turn_increment()

func _on_model_view_turned_right() -> void:
	_target_rotation -= _calculate_turn_increment()

func _on_menagerie_visibility_changed() -> void:
	visible = owner.visible
	_target_rotation = 0.0
