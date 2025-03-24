@tool
@icon("uid://cyrqlm5mdw05a")
class_name CharacterAreaShape
extends Resource

@export var _shape: Shape3D
@export var _offset: Vector3
@export var _automatic_ground_offset: bool = true

func create_collision_shape() -> CollisionShape3D:
	assert(_shape)
	var new_collision_shape: CollisionShape3D = CollisionShape3D.new()
	new_collision_shape.shape = _shape
	new_collision_shape.position = _offset
	if _automatic_ground_offset: new_collision_shape.position.y = ground_offset_from_shape(_shape)
	return new_collision_shape

static func ground_offset_from_shape(shape: Shape3D) -> float:
	assert(shape)
	var ground_offset: float = 0.0
	match shape.get_class():
		"BoxShape3D":
			var box_shape: BoxShape3D = shape
			ground_offset = box_shape.size.y / 2.0
		"CapsuleShape3D":
			var capsule_shape: CapsuleShape3D = shape
			ground_offset = capsule_shape.height / 2.0
		"ConcavePolygonShape3D": printerr("ConcavePolygonShape3D is not yet implemented!")
		"ConvexPolygonShape3D": printerr("ConvexPolygonShape3D is not yet implemented!")
		"CylinderShape3D":
			var cylinder_shape: CylinderShape3D = shape
			ground_offset = cylinder_shape.height / 2.0
		"HeightMapShape3D": printerr("HeightMapShape3D is not yet implemented!")
		"SeparationRayShape3D": printerr("SeparationRayShape3D is not yet implemented!")
		"SphereShape3D":
			var sphere_shape: CylinderShape3D = shape
			ground_offset = sphere_shape.radius
		"WorldBoundaryShape3D": printerr("WorldBoundaryShape3D is not yet implemented!")
	return ground_offset

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _shape: warnings.append("Missing Shape3D.")
	if _automatic_ground_offset and _offset.y != 0.0: warnings.append("automatic_ground_offset = true; manual offset Y position will be overridden.")
	return warnings
