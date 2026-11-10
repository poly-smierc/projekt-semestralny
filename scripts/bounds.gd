@tool
extends Node2D
class_name Bounds

const MINIMUM_AREA = 1000

var _bounds_rect : Rect2

@export var bounds_rect : Rect2:
	set(x):
		_bounds_rect = x
		queue_redraw()
	get():
		return _bounds_rect
@export var player : PlayerController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	assert(player, "Why create bounds, if you don't want to assign a player camera?")
	assert(bounds_rect.get_area()>MINIMUM_AREA, "Bounds rect is too small")
	_set_camera_bounds()


func _set_camera_bounds() -> void:
	var camera = player.camera
	if not camera:
		return
		
	camera.limit_top = bounds_rect.position.y
	camera.limit_left = bounds_rect.position.x
	camera.limit_bottom = bounds_rect.position.y+bounds_rect.size.y
	camera.limit_right = bounds_rect.position.x+bounds_rect.size.x


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(bounds_rect, Color.from_hsv(.5, 1, 1, 0.2), false, 10.0)
