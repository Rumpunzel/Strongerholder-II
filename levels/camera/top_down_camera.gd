class_name TopDownCamera
extends Camera3D

@export var _node_to_follow: Node3D

@export var _distance_off_ground := 23.0
@export var _distance_from_follow := 36.0
@export var _camera_angle_offset := 45.0
@export var _camera_turn_angle := 90.0

var _offset := Vector3.ZERO
var _angle := 0.0
var _turnIndex := 0
var _zoom := 1.0


func _ready() -> void:
	if not _node_to_follow:
		return
	_frame_node(_node_to_follow)

func _process(_delta: float) -> void:
	if not _node_to_follow:
		return
	_frame_node(_node_to_follow)


func _frame_node(node_to_frame: Node3D) -> void:
	_angle = deg_to_rad(_turnIndex * _camera_turn_angle + _camera_angle_offset)
	
	var inverse_zoom := 1.0 / _zoom
	var zoom := sqrt(inverse_zoom)
	_offset.x = _distance_from_follow * cos(_angle) * zoom
	_offset.z = _distance_from_follow * sin(_angle) * zoom
	
	position = node_to_frame.position + _offset
	position.y = _distance_off_ground * inverse_zoom
	
	look_at(node_to_frame.position, Vector3.UP)
