@tool
@icon("uid://cifpff841ra6r")
class_name CharacterCollisionShape
extends CollisionShape3D

func _set(property: StringName, value: Variant) -> bool:
	match property:
		"shape":
			assert(value is Shape3D)
			shape = value
			position.y = Character.y_offset_from_shape(shape)
			return true
	return false
