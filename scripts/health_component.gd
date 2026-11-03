extends Node
class_name HealthComponent

@export var max_health := 100
@export var current_health := 100
@export var invulnerable := false

# Allow handling getting hit, healed and dying uniquely for each node
signal damage_taken(damage: int)
signal healed(amount: int)
signal died

# Don't allow overheal
func _ready() -> void:
	if current_health>max_health:
		current_health = max_health


# Purpose: Take damage
func take_damage(amount: int) -> void:
	if amount<0:
		push_warning("Negative value for damage found! Use heal() to increase health")
		return
	if invulnerable or amount==0:
		return
		
	current_health-=amount
	damage_taken.emit(amount)
	
	if current_health<=0:
		died.emit()


# Purpose: Heal
func heal(amount: int) -> void:
	if amount<0:
		push_warning("Negative value for heal found! Use take_damage instead.")
		return
	
	current_health+=amount
	if current_health>max_health:
		healed.emit(current_health-max_health)
		current_health = max_health
	else:
		healed.emit(amount)
	
	
