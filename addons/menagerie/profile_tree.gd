@tool
extends Tree

signal profile_changed(new_profile: Profile)

var data_path: StringName = "res://data/characters/"

var _group_items: Dictionary[StringName, TreeItem]

func _ready() -> void:
	var root: TreeItem = create_item()
	set_column_title(0, "Character")
	_list_profiles_in_directory(data_path, root)

func _list_profiles_in_directory(directory_path: String, parent_item: TreeItem) -> void:
	var file_names: PackedStringArray = DirAccess.get_files_at(directory_path)
	for file_name: String in file_names:
		if not file_name.get_extension() == "tres": continue
		var resource_path: String = directory_path.path_join(file_name)
		var resource: Resource = load(resource_path)
		if resource is Profile: _create_profile_item(resource, parent_item)
	var directory_names: PackedStringArray = DirAccess.get_directories_at(directory_path)
	for directory_name: String in directory_names:
		_list_profiles_in_directory(directory_path.path_join(directory_name), parent_item)

func _create_profile_item(profile: Profile, parent_item: TreeItem) -> TreeItem:
	var group_item: TreeItem = _group_items.get(profile.get_group_name())
	if not group_item: group_item = _create_group_item_for_profile(profile, parent_item)
	var profile_item: TreeItem = create_item(group_item)
	profile_item.set_text(0, profile.name)
	profile_item.set_metadata(0, profile.resource_path)
	if not get_selected(): set_selected(profile_item, 0)
	return profile_item

func _create_group_item_for_profile(profile: Profile, parent_item: TreeItem) -> TreeItem:
	var group_item: TreeItem = create_item(parent_item)
	var group_name: StringName = profile.get_group_name()
	group_item.set_text(0, group_name)
	_group_items[group_name] = group_item
	return group_item

func _change_profile(selected_item: TreeItem) -> void:
	if _group_items.values().has(selected_item): return
	var profile_path: String = selected_item.get_metadata(0)
	var profile: Profile = load(profile_path)
	EditorInterface.get_inspector().edit(profile)
	profile_changed.emit(profile)

func _on_item_activated() -> void:
	_change_profile(get_selected())

func _on_item_selected() -> void:
	_change_profile(get_selected())
