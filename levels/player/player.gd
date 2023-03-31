class_name Player
extends TopDownCamera

const _ray_length := 1000.0


func get_adjusted_movement(input_vector: Vector2) -> Vector3:
	var ajusted_movement: Vector3
	var camera_forward: Vector3 = transform.basis.z
	camera_forward.y = 0.0
	var camera_right: Vector3 = transform.basis.x
	camera_right.y = 0.0
	ajusted_movement = camera_right.normalized() * input_vector.x + camera_forward.normalized() * input_vector.y
	return ajusted_movement

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
