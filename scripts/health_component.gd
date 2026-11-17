extends Node
class_name HealthComponent

## Max health of the component
@export var max_health := 100
## Current health of the component
@export var current_health := 100
## Is invulnerable to damage
@export var invulnerable := false

# Allow handling getting hit, healed and dying uniquely for each node
signal damage_taken(damage: int)
signal healed(amount: int)
signal died

var dead := false

# Don't allow overheal
func _ready() -> void:
	add_to_group("health")
	if current_health>max_health:
		current_health = max_health


# Purpose: Take damage
func take_damage(amount: int) -> void:
	if amount<0:
		push_warning("Negative value for damage found! Use heal() to increase health")
		return
	if invulnerable or amount==0 or dead:
		return
		
	current_health-=amount
	damage_taken.emit(amount)
	
	if current_health<=0:
		died.emit()
		dead = true


# Purpose: Heal
func heal(amount: int) -> void:
	if amount<0:
		push_warning("Negative value for heal found! Use take_damage instead.")
		return
	if dead:
		return
		
	current_health+=amount
	if current_health>max_health:
		healed.emit(current_health-max_health)
		current_health = max_health
	else:
		healed.emit(amount)
	

# Purpose: Set max health
func set_new_max_health(new_max_health: int) -> void:
	# Godot sucks at division...
	var health_percentage := float(current_health)/float(max_health)
	max_health = new_max_health
	current_health = ceili(new_max_health*health_percentage)
	
