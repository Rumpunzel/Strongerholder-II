class_name Player
extends TopDownCamera

const _ray_length := 1000.0

@export var player: CharacterController

func _process(_delta: float) -> void:
	if not player: return
	
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.direction_input = get_adjusted_movement(input_vector)
	frame_node(player)


func get_adjusted_movement(input_vector: Vector2) -> Vector3:
	var camera_forward := transform.basis.z
	camera_forward.y = 0.0
	var camera_right := transform.basis.x
	camera_right.y = 0.0
	return camera_forward.normalized() * input_vector.y + camera_right.normalized() * input_vector.x

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
