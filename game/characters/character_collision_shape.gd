@tool
@icon("uid://cifpff841ra6r")
class_name CharacterCollisionShape
extends CollisionShape3D

func _set(property: StringName, value: Variant) -> bool:
	match property:
		"shape":
			assert(value is Shape3D)
			shape = value
			if not shape:
				position.y = 0.0
				return true
			var y_offset: float
			match shape.get_class():
				"BoxShape3D":
					var box_shape: BoxShape3D = shape
					y_offset = box_shape.size.y / 2.0
				"CapsuleShape3D":
					var capsule_shape: CapsuleShape3D = shape
					y_offset = capsule_shape.height / 2.0
				"ConcavePolygonShape3D": printerr("ConcavePolygonShape3D is not yet implemented!")
				"ConvexPolygonShape3D": printerr("ConvexPolygonShape3D is not yet implemented!")
				"CylinderShape3D":
					var cylinder_shape: CylinderShape3D = shape
					y_offset = cylinder_shape.height / 2.0
				"HeightMapShape3D": printerr("HeightMapShape3D is not yet implemented!")
				"SeparationRayShape3D": printerr("SeparationRayShape3D is not yet implemented!")
				"SphereShape3D":
					var sphere_shape: CylinderShape3D = shape
					y_offset = sphere_shape.radius
				"WorldBoundaryShape3D": printerr("WorldBoundaryShape3D is not yet implemented!")
			position.y = y_offset
			return true
	return false
