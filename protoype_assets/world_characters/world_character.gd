@icon("uid://cpbv0myc0qfxb")
class_name WorldCharacter
extends Node3D

# TODO: create a plugin to view characters instead of doing everything in editor
#var _debug_collision_shape: CollisionShape3D:
	#set(new_debug_collision_shape):
		#assert(Engine.is_editor_hint())
		#if _debug_collision_shape:
			#if get_children().has(_debug_collision_shape): remove_child(_debug_collision_shape)
			#_debug_collision_shape.queue_free()
		#_debug_collision_shape = new_debug_collision_shape
		#if not _debug_collision_shape: return
		#_debug_collision_shape.shape = collision_shape
		#add_child(_debug_collision_shape, false, Node.INTERNAL_MODE_FRONT)
		#print.call_deferred("added collision shape: %s" % _debug_collision_shape.get_path())
#
#func _ready() -> void:
	#if Engine.is_editor_hint(): _debug_collision_shape = CollisionShape3D.new()

func play_animation(_normalized_velocity: Vector3) -> void:
	assert(false, "WorldCharacter.play_animation is 'abstract' and needs to be overriden!")

func apply_material_override(material: Material) -> void:
	assert(false, "WorldCharacter.apply_material_override is 'abstract' and needs to be overriden!")
