@icon("uid://bes0anop2dh5u")
extends Node

@warning_ignore_start("unused_signal")
signal character_created(character: Character)

signal character_haunted(haunted_character: Character, haunting_character: Character)
signal character_unhaunted(unhaunted_character: Character)
@warning_ignore_restore("unused_signal")
