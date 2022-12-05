extends Node2D


# Constants
var ZOMBIES_PER_LEVEL = {
	"1": 5,
	"2": 15,
	"3": 20,
	"4": 40,
	"5": 80,
	"6": 1000
}

# Counters
var current_level = 1
var zombie_ids = {}  # Dict of zombie id's that are currently spawned in
var zombies_left_to_spawn = 0  # Total zombies left to spawn
var zombies_on_map = 0  # Current zombies on the screen

var players = []


func _ready():
	for child in get_node("ZombieManager").get_children():
		if child.get_filename() == "res://Player.tscn":
			players.append(child)

	start_round(current_level)
	
	
func start_round(level):
	kill_all_zombies()
	reset_player_repairs()
	give_players_grenades()
	zombies_left_to_spawn = ZOMBIES_PER_LEVEL[str(current_level)]
	$HUD/zombies_left_to_spawn.text = str(zombies_left_to_spawn)
	$SpawnManager.start_level(zombies_left_to_spawn)

func reset_player_repairs():
	for child in get_node("ZombieManager").get_children():
		if child.get_filename() == "res://Player.tscn":
			child.window_repairs_this_round = 0

func give_players_grenades():
	for player in players:
		player.grenade_count += 1

func _on_zombie_spawn(zombie, _position, _target):
	var z = zombie.instance()
	z.position = _position
#	print(_target)
	z.targetPosition = _target  # sets the zombie to target the window navigation node
#	print("Setting zombie state")
	z.state = "seek_window"
	get_node("ZombieManager").add_child(z)
	zombie_ids[z.get_instance_id()] = z.get_instance_id()
	zombies_on_map += 1
	zombies_left_to_spawn -= 1
	$SpawnManager.zombies_on_map = zombies_on_map
	$SpawnManager.zombies_left_to_spawn = zombies_left_to_spawn
	$HUD/zombies_on_map.text = str(zombies_on_map)
	$HUD/zombies_left_to_spawn.text = str(zombies_left_to_spawn)

func _on_zombie_death(id):
	# This id system is to prevent the issue where a zombie is killed by two
	# things at the same time and thus triggers the death signal twice
	if id in zombie_ids:
		zombie_ids.erase(id)
		zombies_on_map -= 1 
		$SpawnManager.zombies_on_map = zombies_on_map
		$HUD/zombies_on_map.text = str(zombies_on_map)
	if zombies_on_map == 0 and zombies_left_to_spawn == 0:
		current_level += 1
		$HUD/level_count.text = str(current_level)
		start_round(current_level)

func _on_spawner_ready(spawner, spawner_position):
	var selected_window_node
	var smallest_distance = INF
	for node in get_node("NavigationNodeManager").get_children():
		if node.WINDOW_NODE:
			var distance = (spawner.global_position - node.global_position).length()
			if distance < smallest_distance:
				smallest_distance = distance
				selected_window_node = node
	if not selected_window_node:
		assert(false, "There are no navigation nodes for zombie spawner to target.")
	spawner.target_window = selected_window_node
			
			
func kill_all_zombies():
	# Makes sure there arent any zombies left after the first round
	# the id system should have fixed this but this is just in case
	for body in get_node("ZombieManager").get_children():
		if body and body.get_filename() != "res://Player.tscn":
			body.queue_free()

func _on_gun_shoot(bullet, _position, _direction, _damage, _player_shooting):
	var b = bullet.instance()
	add_child(b)
	b.init(_damage, _player_shooting)
	b.start(_position, _direction)

func _on_Player_throw_grenade(grenade, _player):
	var player_position = _player.global_position
	var velocity = _player.grenade_throw_velocity
	
	var g = grenade.instance()
	g.player = _player
	add_child(g)
	g.global_transform.origin = player_position
	g.apply_impulse(player_position, _player.grenade_throw_velocity)
	
func _activate_spawners(spawner_names : Array):
	for name in spawner_names:
		for spawner in $SpawnManager.get_children():
			if spawner.name == name:
				spawner.active = true
				
func _on_max_ammo():
	for player in players:
		player.refill_ammo(true, true)
