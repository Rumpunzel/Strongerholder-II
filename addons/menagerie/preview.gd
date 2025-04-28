@tool
@icon("uid://cl8p01b5kagvw")
extends Node3D

@export var _follow_distance_min = 0.0
@export var _follow_distance_max = 16.0
@export var _zoom_rate: float = 0.25

@export_custom(PROPERTY_HINT_RANGE, "0.0,360.0,suffix:°") var _turn_increment_min: float = 2.0
@export_custom(PROPERTY_HINT_RANGE, "0.0,360.0,suffix:°") var _turn_increment_max: float = 32.0
@export var _turn_time: float = 0.1

@export_group("Configuration")
@export var _preview_model: PreviewModel
@export var _phantom_camera: PhantomCamera3D
@export var _zoom_slider: Slider

var _target_rotation: float = 0.0:
	set(new_target_rotation):
		_target_rotation = new_target_rotation
		if _tween: _tween.kill()
		if not get_tree(): return
		_tween = get_tree().create_tween()
		_tween.tween_property(self, "rotation_degrees:y", _target_rotation, _turn_time)

var _tween: Tween

func _ready() -> void:
	_look_at_preview_model()

func _look_at_preview_model() -> void:
	var character_position: Vector3 = _preview_model.position
	var heads_up_anchor: Vector3 = _preview_model.get_heads_up_anchor()
	_phantom_camera.look_at_offset = (character_position + heads_up_anchor) / 2.0

func _calculate_turn_increment() -> float:
	var turn_modifier: float = 1.0 + fmod(abs(_target_rotation - rotation_degrees.y), 180.0)
	return clampf(turn_modifier, _turn_increment_min, _turn_increment_max)

func _on_model_view_zoomed_in() -> void:
	_phantom_camera.follow_distance = maxf(_phantom_camera.follow_distance - _zoom_rate, _follow_distance_min)
	_phantom_camera._set_follow_position()
	var zoom_ratio: float = (_phantom_camera.follow_distance - _follow_distance_min) / _follow_distance_max
	_zoom_slider.set_value_no_signal(zoom_ratio)

func _on_model_view_zoomed_out() -> void:
	_phantom_camera.follow_distance = minf(_phantom_camera.follow_distance + _zoom_rate, _follow_distance_max)
	_phantom_camera._set_follow_position()
	var zoom_ratio: float = (_phantom_camera.follow_distance - _follow_distance_min) / _follow_distance_max
	_zoom_slider.set_value_no_signal(zoom_ratio)

func _on_zoom_slider_value_changed(value: float) -> void:
	_phantom_camera.follow_distance = _follow_distance_min + value * _follow_distance_max

func _on_model_view_turned_left() -> void:
	_target_rotation += _calculate_turn_increment()

func _on_model_view_turned_right() -> void:
	_target_rotation -= _calculate_turn_increment()

func _on_menagerie_visibility_changed() -> void:
	visible = owner.visible
	_target_rotation = 0.0
