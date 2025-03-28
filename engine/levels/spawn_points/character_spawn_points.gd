@tool
class_name CharacterSpawnPoints
extends Node3D

func spawn_all_characters(spawn_parent: Node) -> Array[Character]:
	var spawned_characters: Array[Character] = []
	for character_spawn_point: CharacterSpawnPoint in get_children():
		var new_character: Character = character_spawn_point.spawn_character(spawn_parent)
		spawned_characters.append(new_character)
	return spawned_characters
