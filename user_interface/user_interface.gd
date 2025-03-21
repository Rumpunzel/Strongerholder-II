extends CanvasLayer

var menu: Menu

func _ready() -> void:
	menu = preload("uid://5sd2jgms4uso").instantiate()
	add_child(menu, true)
