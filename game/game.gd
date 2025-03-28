@icon("uid://bes0anop2dh5u")
extends Node

signal character_created(character: Character)

@warning_ignore_start("unused_signal")
signal character_haunted(haunted_character: Character, haunting_character: Character)
signal character_unhaunted(unhaunted_character: Character)
@warning_ignore_restore("unused_signal")

func create_character(character_profile: CharacterProfile, spawn_transform: Transform3D) -> Character:
	assert(character_profile)
	var character: Character = character_profile.create(spawn_transform)
	character_created.emit(character)
	return character
