class_name CharacterController
extends CharacterBody3D

@export var movement_attributes: MovementAttributes

var direction_input := Vector3.ZERO

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	apply_direction_input()
	apply_gravity(delta)
	
	move_and_slide()


func apply_direction_input() -> void:
	var move_speed := movement_attributes.move_speed	
	if direction_input:
		velocity = direction_input * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

func apply_gravity(delta: float) -> void:
	if is_on_floor(): return
	velocity.y -= _gravity * delta
