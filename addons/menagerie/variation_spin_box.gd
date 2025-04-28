@tool
extends SpinBox

signal variation_changed(new_variation: int)

func _on_value_changed(new_value: int) -> void:
	set_value_no_signal(int(new_value + (max_value + 1)) % int(max_value + 1))
	variation_changed.emit(value)

func _on_profile_tree_profile_changed(new_profile: Profile) -> void:
	value = new_profile.get_random_variation()
	max_value = new_profile._model_variations.size() - 1
	editable = max_value > 0
