@tool
extends Control

signal profile_changed(new_profile: Profile)

@export_dir var _data_path: String = "res://data/"

@export_group("Configuration")
@export var _profiles_tree: Tree

var _group_items: Dictionary[StringName, TreeItem]

func _ready() -> void:
	_clear_profiles()
	_list_profiles_in_directory()

func _list_profiles_in_directory(directory_path: String = _data_path, parent_item: TreeItem = _profiles_tree.create_item()) -> void:
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
	var profile_item: TreeItem = _profiles_tree.create_item(group_item)
	profile_item.set_text(0, profile.name)
	profile_item.set_metadata(0, profile.resource_path)
	if visible and not _profiles_tree.get_selected(): _profiles_tree.set_selected(profile_item, 0)
	return profile_item

func _create_group_item_for_profile(profile: Profile, parent_item: TreeItem) -> TreeItem:
	var group_item: TreeItem = _profiles_tree.create_item(parent_item)
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

func _clear_profiles() -> void:
	_profiles_tree.clear()
	_group_items.clear()

func _on_visibility_changed() -> void:
	if not visible: _clear_profiles()
	if visible:
		_clear_profiles()
		_list_profiles_in_directory()

func _on_item_activated() -> void:
	_change_profile(_profiles_tree.get_selected())

func _on_item_selected() -> void:
	_change_profile(_profiles_tree.get_selected())

func _on_rescan_button_pressed() -> void:
	_clear_profiles()
	_list_profiles_in_directory()
