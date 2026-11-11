extends Area2D

signal material_get

func _on_body_entered(body: Node2D) -> void:
	if visible:
		visible = false
		material_get.emit()
	
