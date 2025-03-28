@icon("uid://bq2ao4pir5jfp")
class_name GameWorld
extends Node

@onready var _serializer: SerializerNode = Serializer

func _ready() -> void:
	_serializer.load_world_state()
