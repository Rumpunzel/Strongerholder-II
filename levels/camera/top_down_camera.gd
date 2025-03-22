class_name TopDownCamera
extends Camera3D

const _ray_length := 1000.0

@export var distance_off_ground := 20.0
@export var distance_from_follow := 20.0
@export var camera_angle_offset := 45.0
@export var camera_turn_angle := 90.0
@export var zoom := 1.0

var _turnIndex := 0

func frame_node(node_to_frame: Node3D) -> void:
	assert(node_to_frame)
	print("framing node: %s" % node_to_frame.name)
	frame_point(node_to_frame.position)

func frame_point(point_to_frame: Vector3) -> void:
	assert(point_to_frame != null)
	print("framing point: %s" % point_to_frame)
	var angle := deg_to_rad(_turnIndex * camera_turn_angle + camera_angle_offset)
	var inverse_zoom := 1.0 / zoom
	var inverse_zoom_root := sqrt(inverse_zoom)
	
	var offset := Vector3(
		distance_from_follow * cos(angle) * inverse_zoom_root,
		distance_off_ground * inverse_zoom - point_to_frame.y,
		distance_from_follow * sin(angle) * inverse_zoom_root,
	)
	
	position = point_to_frame + offset
	look_at(point_to_frame, Vector3.UP)

func get_adjusted_movement(input_vector: Vector2) -> Vector2:
	var camera_forward := transform.basis.z
	camera_forward.y = 0.0
	var camera_right := transform.basis.x
	camera_right.y = 0.0
	var adjusted_input_vector := camera_forward.normalized() * input_vector.y + camera_right.normalized() * input_vector.x
	return Vector2(adjusted_input_vector.x, adjusted_input_vector.z)

func mouse_as_world_point() -> CameraRay:
	var mouse_position := get_viewport().get_mouse_position()
	var from := project_ray_origin(mouse_position)
	var to := from + project_ray_normal(mouse_position) * _ray_length
	return CameraRay.new(from, to)


class CameraRay:
	var from: Vector3
	var to: Vector3
	
	func _init(new_from: Vector3, new_to: Vector3) -> void:
		from = new_from
		to = new_to
