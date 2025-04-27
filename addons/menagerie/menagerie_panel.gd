@tool
@icon("uid://b0s3flceyjwl0")
class_name MenageriePanel
extends PanelContainer

@export var _preview: Node3D

func _on_visibility_changed() -> void:
	_preview.visible = visible
