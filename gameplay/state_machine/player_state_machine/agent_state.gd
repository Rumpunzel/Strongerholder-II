@tool
@icon("uid://ne8n58y4wim8")
class_name AgentState
extends State

const STATE_DEFAULT: StringName = "Default"
const STATE_HAUNTED: StringName = "Haunted"

# Data dictionary keys
const HAUNTING: StringName = "haunting_character_controller"
const HAUNTED: StringName = "haunted_character_controller"

var agent: Agent
