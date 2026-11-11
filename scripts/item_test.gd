extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var house = get_node("House")
	for node in get_tree().get_nodes_in_group("Items"):
		node.connect("material_get",Callable(house, "materials_collected"))
