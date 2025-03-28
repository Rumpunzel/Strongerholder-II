class_name Synchronizer
extends MultiplayerSynchronizer

## @returns a [Dictionary] with the parameter as [NodePath] to the value as a [Variant]
func collect_properties() -> Dictionary[NodePath, Variant]:
	var properties_to_serialize: Array[NodePath] = replication_config.get_properties()
	var properties_dict: Dictionary[NodePath, Variant] = { }
	for property_path: NodePath in properties_to_serialize:
		var node_path: NodePath = NodePath(property_path.get_concatenated_names())
		var node: Node = get_node(node_path)
		var property_node_path: NodePath = NodePath(property_path.get_concatenated_subnames())
		var property_value: Variant = node.get_indexed(property_node_path)
		properties_dict[property_path] = property_value
	return properties_dict
