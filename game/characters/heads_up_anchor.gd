@tool
@icon("uid://duyge1d76pols")
class_name HeadsUpAnchor
extends Marker3D

const HUD_PLACEHOLDER_SCENE: PackedScene = preload("uid://c3ggesrya61ic")

@export var root_node: Node3D
## If false, display placeholder gizmo only when the scene is opened
@export var global_placeholder: bool = false

var _hud_placeholder: Sprite3D

func _ready() -> void:
	if not Engine.is_editor_hint(): return
	if not global_placeholder and EditorInterface.get_edited_scene_root() != root_node: return
	_hud_placeholder = HUD_PLACEHOLDER_SCENE.instantiate()
	add_child(_hud_placeholder, false, Node.INTERNAL_MODE_FRONT)
