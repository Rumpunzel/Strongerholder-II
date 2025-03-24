class_name Kingdom
extends Node

const KINGDOM_SCENE: PackedScene = preload("uid://kquuu3wv8puv")

static func create() -> Kingdom:
	return KINGDOM_SCENE.instantiate()
