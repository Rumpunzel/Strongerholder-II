class_name WorldCharacter
extends Node3D

func play_animation(_normalized_velocity: Vector3) -> void:
	assert(false, "WorldCharacter.play_animation is 'abstract' and needs to be overriden!")
