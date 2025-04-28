@tool
extends TabContainer

@export_group("Cofiguration")
@export var _all_tab: Control

func _ready() -> void:
	set_tab_button_icon(0, preload("uid://btd64iwc2p3sh"))
	set_tab_button_icon(1, preload("uid://bes0anop2dh5u"))
	set_tab_button_icon(2, preload("uid://c4udocqr7qeyj"))

func _on_tab_changed(tab: int) -> void:
	if tab < 0:
		size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		_all_tab.visible = true
	else:
		size_flags_vertical = Control.SIZE_EXPAND_FILL
		_all_tab.visible = false
