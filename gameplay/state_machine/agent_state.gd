@tool
@icon("uid://ne8n58y4wim8")
class_name AgentState
extends State

const DEFAULT_STATE: StringName = "Default"
const HAUNTED_STATE: StringName = "Haunted"

# Data dictionary keys
const HAUNTING: StringName = "haunting_character_controller"
const HAUNTED: StringName = "haunted_character_controller"

var agent: Agent
