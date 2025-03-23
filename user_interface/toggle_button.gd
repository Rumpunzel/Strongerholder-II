@tool
class_name ToggleButton
extends Button

@export_multiline var toggled_text: String
@export var toggled_icon: Texture

@onready var _untoggled_text: String = text
@onready var _untoggled_icon: Texture = icon

func _ready() -> void:
	toggle_mode = true
	toggled.connect(_on_toggled)

func _on_toggled(toggled_on: bool) -> void:
	text = toggled_text if toggled_on else _untoggled_text
	icon = toggled_icon if toggled_on else _untoggled_icon
