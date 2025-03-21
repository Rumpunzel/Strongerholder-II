class_name CharacterModel
extends Node3D

@export var animation_tree: AnimationTree

@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func play_animation(normalized_velocity: Vector3) -> void:
	if normalized_velocity:
		state_machine.travel("Walk")
		animation_tree.set("parameters/Walk/blend_position", normalized_velocity.length_squared())
	else:
		state_machine.travel("Idle")
