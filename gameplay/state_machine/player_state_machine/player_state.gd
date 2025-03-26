@tool
@icon("uid://c73t2rg8wrdt3")
class_name PlayerState
extends State

const STATE_DEFAULT: StringName = "Default"
const STATE_HAUNTED: StringName = "Haunted"
const STATE_HAUNTING: StringName = "Haunting"

# Data dictionary keys
const HAUNTED: StringName = "haunted_character_controller"
const HAUNTING: StringName = "haunting_character_controller"

var player: Player
