class_name TopDownCamera
extends Camera3D

const _ray_length := 1000.0

@export var follow_node: Node3D = null :
	set(new_node):
		follow_node = new_node
		set_process(follow_node != null)

@export var _shoulder_height := 1.5
@export var _distance_off_ground := 16.0
@export var _distance_from_follow := 24.0
@export var _angle_offset := 45.0

func _ready() -> void:
	set_process(follow_node != null)

func _process(_delta: float) -> void:
	frame_node(follow_node)

func mouse_as_world_ray() -> CameraRay:
	var mouse_position := get_viewport().get_mouse_position()
	var from := project_ray_origin(mouse_position)
	var to := from + project_ray_normal(mouse_position) * _ray_length
	return CameraRay.new(from, to)

func get_adjusted_movement(input_vector: Vector2) -> Vector3:
	var camera_forward := transform.basis.z
	var camera_right := transform.basis.x
	camera_forward.y = 0.0
	camera_right.y = 0.0
	return camera_right * input_vector.x + camera_forward * input_vector.y

func frame_node(node: Node3D) -> void:
	var new_offset := Vector3(_distance_from_follow * cos(_angle_offset), 0.0, _distance_from_follow * sin(_angle_offset))
	var new_position := node.position + new_offset
	new_position.y = _shoulder_height + _distance_off_ground
	position = new_position
	look_at(Vector3(node.position.x, _shoulder_height, node.position.z), Vector3.UP)

@rpc("any_peer", "reliable")
func set_follow_node_path(new_node_path: String) -> void:
	follow_node = get_node_or_null(new_node_path)

class CameraRay:
	var from: Vector3
	var to: Vector3
	
	func _init(new_from: Vector3, new_to: Vector3) -> void:
		from = new_from
		to = new_to
