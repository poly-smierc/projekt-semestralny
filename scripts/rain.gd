extends Timer
class_name Rain

const DEFAULT_WAIT_TIME = 1.0

## Influences damage and simmilar things
@export var difficulty := 0
## Damage dealt every second by the rain
@export var damage := 1
## The timespan with rain damage
@export var rain_time := 30
## The timespan without rain damage
@export var calm_time := 60
## Increase in damage by every difficulty level
@export_range(1.0, 2.0, 0.01) var damage_increase := 1.0
## Increase in rain time by every difficulty level
@export_range(1.0, 2.0, 0.01) var rain_time_increase := 1.0
## Decrease in calm time by every difficulty level
@export_range(0.0, 1.0, 0.01) var calm_time_decrease := 1.0
## Debug option to start with rainy state (should be set to false)
@export var start_with_rain := false

enum RainState {
	CALM=0,
	RAINY=1
}

var time_to_state_switch : float
var current_state : RainState

signal tick_updated(time: int)
signal state_updated(new_state: RainState)

func _ready() -> void:
	# Ignore the wait time and one shot settings
	wait_time = DEFAULT_WAIT_TIME
	one_shot = false
	time_to_state_switch = rain_time if start_with_rain else calm_time
	current_state = RainState.RAINY if start_with_rain else RainState.CALM
	timeout.connect(_timer_tick)
	if start_with_rain:
		push_warning("start_with_rain is set to true!")
	

# Purpose: Process every tick of a timer
func _timer_tick() -> void:
	time_to_state_switch-=1
	tick_updated.emit(time_to_state_switch)
	
	if current_state==RainState.CALM:
		_calm_state()
	elif current_state==RainState.RAINY:
		_rainy_state()
		
	if time_to_state_switch<=0:
		_handle_state_switch()
		state_updated.emit(current_state)


# Purpose: Logic for calm state
func _calm_state() -> void:
	print("calm tick")
	

# Purpose: Logic for rainy state
func _rainy_state() -> void:
	var health_components := get_tree().get_nodes_in_group("health")
	for component : HealthComponent in health_components:
		component.take_damage(damage*(damage_increase**difficulty))
		

# Purpose: Handle state switches
func _handle_state_switch() -> void:
	if current_state==RainState.CALM:
		current_state = RainState.RAINY
		difficulty+=1
		time_to_state_switch = rain_time*(rain_time_increase**difficulty)
	elif current_state==RainState.RAINY:
		current_state = RainState.CALM
		time_to_state_switch = calm_time*(calm_time_decrease**difficulty)
