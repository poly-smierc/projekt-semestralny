extends Control

var menu
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menu.visible = true
	$LevelSelect.visible = false
#func _process(delta: float) -> void:

func _on_select_level_button_pressed() -> void:
	$Menu.visible = false
	$LevelSelect.visible = true
	#get_parent().get_node("LevelSelect").visible = !get_parent().get_node("LevelSelect").visible


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	$Menu.visible = true
	$LevelSelect.visible = false


func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/player_test.tscn")
