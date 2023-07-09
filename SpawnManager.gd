extends Node2D

export (bool) var DISABLED = true
export var MAX_ZOMBIES_AT_ONCE = 30

var round_started = false

var zombies_left_to_spawn = 0
var zombies_on_map = 0

func start_level(_zombies_left_to_spawn):
	zombies_left_to_spawn = _zombies_left_to_spawn
	round_started = true

func _process(delta):
	if not round_started or DISABLED:
		return
	
	for spawner in select_spawners():
		if zombies_on_map == MAX_ZOMBIES_AT_ONCE or zombies_left_to_spawn == 0:
			return
		if spawner.can_spawn_zombie and spawner.active:
			spawner.spawn_zombie()

func select_spawners():
	# This will select the 3 or 4 spawners which are the closest to the player and spawn zombies
	# from those spawners.
	return get_children()



