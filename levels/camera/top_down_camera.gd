class_name TopDownCamera
extends Camera3D

@export var distance_off_ground := 60.0
@export var distance_from_follow := 60.0
@export var camera_angle_offset := 45.0
@export var camera_turn_angle := 90.0
@export var zoom := 1.0

var _turnIndex := 0

func frame_node(node_to_frame: Node3D) -> void:
	assert(node_to_frame)
	var angle := deg_to_rad(_turnIndex * camera_turn_angle + camera_angle_offset)
	var inverse_zoom := 1.0 / zoom
	var inverse_zoom_root := sqrt(inverse_zoom)
	
	var offset := Vector3(
		distance_from_follow * cos(angle) * inverse_zoom_root,
		distance_off_ground * inverse_zoom - node_to_frame.position.y,
		distance_from_follow * sin(angle) * inverse_zoom_root,
	)
	
	position = node_to_frame.position + offset
	look_at(node_to_frame.position, Vector3.UP)
