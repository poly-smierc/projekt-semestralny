extends Area2D


@export var max_health : int = 100
var health: int
var first_bracket : int 
var second_bracket : int
var last_bracket : int
var near_house : bool = false
var repair_count : int = 0 
var house_image : Sprite2D 
var label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	house_image = $Sprite2D
	label = $Label
	health = max_health
	first_bracket = floor(max_health * .75)
	second_bracket = floor(max_health * .5)
	last_bracket = floor(max_health * .25)
	
func take_dame(damage: int) -> void:
	health -= damage
	
	_visualize_damage()

func _visualize_damage() -> void:
	if health > first_bracket:
		house_image.rotation_degrees = 0
		return
	if health > second_bracket:
		house_image.rotation_degrees =90
		return
	if health > last_bracket:
		house_image.rotation_degrees =180
		return
	# shit is fucked
	visible = false
	label.text = ""

func materials_collected() -> void:
	repair_count += 1
	
func _input(ev):
	if ev is InputEventKey  and not ev.echo:
		if Input.is_key_pressed(KEY_K):
			take_dame(25)
			print("damage_test")
		if Input.is_key_pressed(KEY_R) and near_house and visible:
			repair_count -= 1
			take_dame(-25)
			if repair_count <= 0:
				label.text = ""

func _on_body_entered(body: Node2D) -> void:
	if health <=first_bracket:
		label.text = "Press R to fix"
	near_house = true

func _on_body_exited(body: Node2D) -> void:
	label.text = ""
	near_house = false
