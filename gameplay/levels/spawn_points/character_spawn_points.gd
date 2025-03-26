@tool
class_name CharacterSpawnPoints
extends Node3D

func spawn_all_character_controllers(spawn_parent: Node) -> Array[CharacterController]:
	var spawned_character_controllers: Array[CharacterController] = [ ]
	for character_spawn_point: CharacterSpawnPoint in get_children():
		var new_character_controller: CharacterController = character_spawn_point.spawn_character_controller(spawn_parent)
		spawned_character_controllers.append(new_character_controller)
		await get_tree().process_frame
	return spawned_character_controllers
