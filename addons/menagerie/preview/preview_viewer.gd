@tool
@icon("uid://cl8p01b5kagvw")
extends Node3D

signal zoom_value_changed(zoom_value: float)

@export var _follow_distance_min = 0.0
@export var _follow_distance_max = 16.0
@export var _zoom_rate: float = 0.25

@export_custom(PROPERTY_HINT_RANGE, "0.0,360.0,suffix:°") var _turn_increment_min: float = 2.0
@export_custom(PROPERTY_HINT_RANGE, "0.0,360.0,suffix:°") var _turn_increment_max: float = 32.0
@export var _turn_time: float = 0.1

@export_group("Configuration")
@export var _camera: Camera3D
@export var _phantom_camera: PhantomCamera3D
@export var _phantom_camera_host: PhantomCameraHost

var _target_rotation: float = 0.0:
	set(new_target_rotation):
		_target_rotation = new_target_rotation
		if _tween: _tween.kill()
		if not get_tree(): return
		_tween = get_tree().create_tween()
		_tween.tween_property(self, "rotation_degrees:y", _target_rotation, _turn_time)

var _tween: Tween

func _process(delta: float) -> void:
	if not visible: return
	_phantom_camera.process_logic(delta)

func _calculate_turn_increment() -> float:
	var turn_modifier: float = 1.0 + fmod(abs(_target_rotation - rotation_degrees.y), 180.0)
	return clampf(turn_modifier, _turn_increment_min, _turn_increment_max)

func _on_model_preview_zoom_changed(new_zoom: float) -> void:
	var follow_distance: float = _follow_distance_min + new_zoom * _follow_distance_max
	_phantom_camera.follow_distance = follow_distance
	_phantom_camera.auto_follow_distance_min = follow_distance

func _on_model_preview_zoomed_out() -> void:
	var follow_distance: float = minf(_phantom_camera.follow_distance + _zoom_rate, _follow_distance_max)
	_phantom_camera.follow_distance = follow_distance
	_phantom_camera.auto_follow_distance_min = follow_distance
	var zoom_ratio: float = (_phantom_camera.follow_distance - _follow_distance_min) / _follow_distance_max
	zoom_value_changed.emit(zoom_ratio)

func _on_model_preview_zoomed_in() -> void:
	var follow_distance: float = maxf(_phantom_camera.follow_distance - _zoom_rate, _follow_distance_min)
	_phantom_camera.follow_distance = follow_distance
	_phantom_camera.auto_follow_distance_min = follow_distance
	var zoom_ratio: float = (_phantom_camera.follow_distance - _follow_distance_min) / _follow_distance_max
	zoom_value_changed.emit(zoom_ratio)

func _on_model_preview_turned_left() -> void:
	_target_rotation += _calculate_turn_increment()

func _on_model_preview_turned_right() -> void:
	_target_rotation -= _calculate_turn_increment()

func _on_sky_box_changed(new_sky_box: PanoramaSkyMaterial) -> void:
	_camera.environment.sky.sky_material = new_sky_box

func _on_model_preview_visibility_changed() -> void:
	visible = owner.is_visible_in_tree()
	if visible: _phantom_camera.set_is_active(_phantom_camera_host, true)
	_target_rotation = 0.0
