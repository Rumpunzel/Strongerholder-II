@tool
@icon("uid://c73t2rg8wrdt3")
class_name PlayerState
extends State

const DEFAULT_STATE: StringName = "Default"
const HAUNTED_STATE: StringName = "Haunted"
const HAUNTING_STATE: StringName = "Haunting"

# Data dictionary keys
const HAUNTED: StringName = "haunted_character_controller"
const HAUNTING: StringName = "haunting_character_controller"

var player: Player
