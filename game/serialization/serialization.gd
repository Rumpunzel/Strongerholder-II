class_name Serialization
extends Node

static func encode_data(value: Variant, full_objects := false) -> String:
	return JSON.stringify(JSON.from_native(value, full_objects))

static func decode_data(string: String, allow_objects := false) -> Variant:
	return JSON.to_native(JSON.parse_string(string), allow_objects)
