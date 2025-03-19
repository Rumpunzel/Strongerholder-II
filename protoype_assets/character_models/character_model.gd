class_name CharacterModel
extends Node3D

@export var animation_tree: AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func play_animation(velocity: Vector3, move_speed: float) -> void:
	if velocity:
		state_machine.travel("Walk")
		var normalized_velocity := velocity / move_speed
		animation_tree.set("parameters/Walk/blend_position", normalized_velocity.length_squared())
	else:
		state_machine.travel("Idle")
