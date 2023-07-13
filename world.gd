extends Node2D

var messagePopup = preload("res://messagePopup.tscn")
var damagePopup = preload("res://damagePopup.tscn")

# Constants
var ZOMBIES_PER_LEVEL = {
	"1": 5,
	"2": 15,
	"3": 20,
	"4": 40,
	"5": 80,
	"6": 140,
	"7": 250,
	"8": 500,
	"9": 750,
	"10": 1000
}

const SAVE_DIR = "user://highscore/"

# Zombie / player trackers
var zombie_ids = {}  # Dict of zombie id's that are currently spawned in
var zombies_left_to_spawn = 0  # Total zombies left to spawn
var zombies_on_map = 0  # Current zombies on the screen
var players = []

# High Score counters
var current_level = 1
var bulletsFired = 0
var bulletsHit = 0 
var kills = 0


func _ready():
	print("world readu, debug: " + str(GLOBALS.debugMode))
	for child in get_node("ZombieManager").get_children():
		if child.get_filename() == "res://Player.tscn":
			players.append(child)

	start_round(current_level)
	
func start_round(level):

	# play sound
	if level > 1:
		$startRound.play()
	kill_all_zombies()
	reset_player_repairs()
	give_players_grenades()
	zombies_left_to_spawn = ZOMBIES_PER_LEVEL[str(current_level)]
	$HUD/debug/zombies_left_to_spawn.text = str(zombies_left_to_spawn)
	
	# delay zombie spawning by timer wait time
	$newRoundStartTimer.start()

func _on_newRoundStartTimer_timeout():
	# start zombie spawning
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
	$HUD/debug/zombies_on_map.text = str(zombies_on_map)
	$HUD/debug/zombies_left_to_spawn.text = str(zombies_left_to_spawn)

func _on_zombie_death(id):
	# This id system is to prevent the issue where a zombie is killed by two
	# things at the same time and thus triggers the death signal twice
	if id in zombie_ids:
		zombie_ids.erase(id)
		kills += 1
		zombies_on_map -= 1 
		$SpawnManager.zombies_on_map = zombies_on_map
		$HUD/debug/zombies_on_map.text = str(zombies_on_map)
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
	bulletsFired += 1
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
	g.throw()
	
func _activate_spawners(spawner_names : Array):
	for name in spawner_names:
		for spawner in $SpawnManager.get_children():
			if spawner.name == name:
				spawner.active = true
				
func _on_max_ammo():
	for player in players:
		player.refill_ammo(true, true)
		_on_money_popup("Max Ammo", player.global_position)
		
func _on_pickup_spawn(_global_position):
	#print("Adding pickup to world")
	var pickup = GLOBALS.choose_drop()
	var p = pickup.instance()
	p.global_position = _global_position
	add_child(p)
	
func _on_Player_playerDeath():
	#print("player death - stopping zombies")
	# get all zombies and change their state
	for body in get_node("ZombieManager").get_children():
		if body and body.get_filename() != "res://Player.tscn":
			body.state = 'playerDeath'
	
func updateHighScore():
	"""
	Load the current high score data if it exsits. Compare it to the currect score. 
	If we got a new high score returns true, else, 
	"""
	var newHighScore = false
	
	var dataToSave
	
	# Load old data
	# This is the built in user directory at: Project -> Open User Data
	var save_path = SAVE_DIR + "highscore.dat"
	
	var oldSaveData
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open(save_path, File.READ)
		print("high score save file found")
		
		if error == OK:
			oldSaveData = file.get_var()
			file.close()
			print("high score game data loaded")
			
			# if we got a new highest level, save current game data
			if current_level > oldSaveData["current_level"]:
				newHighScore = true
		
			# if we got the save level but more kills, save current game data
			elif current_level == oldSaveData["current_level"] and kills > oldSaveData["kills"]:
				newHighScore = true
	else:
		# if there is no save file we'll assume its a new highscore
		newHighScore = true
		
	if newHighScore:
		print("New highscore, saving score...")
		# Save new high score data
		dataToSave = {
			"current_level": current_level,
			"bulletsFired": bulletsFired,
			"bulletsHit": bulletsHit,
			"kills": kills
		}
		var dir = Directory.new()
	
		if !dir.dir_exists(SAVE_DIR):
			dir.make_dir_recursive(SAVE_DIR)
		
		var fileWrite = File.new()
		var error = fileWrite.open(save_path, File.WRITE)
		assert(error == OK, "High score save file could not be opened")
		if error == OK:
			fileWrite.store_var(dataToSave)
			fileWrite.close()
			print("high score data saved")
		
	return newHighScore

func _on_Player_game_over():
	# kill all zombies and the players
	for body in get_node("ZombieManager").get_children():
		body.queue_free()
	
	# make sure the spawner doesnt try to spawn anything
	zombies_left_to_spawn = 0
	
	# updates high score and returns if we got a new high score
	var newHighScore = updateHighScore()
	
	# go to game over screen or high score screen
	if newHighScore:
		# TODO - high score scene
		get_tree().change_scene("res://GameOver.tscn")
	else:
		get_tree().change_scene("res://GameOver.tscn")

func _on_damage_popup(message, position):
	""" 
	Creates new instance of our money popup, sets its message, position, and attaches it to world
	"""
	if message == "":
		return
	var popUpMessage = damagePopup.instance()
	add_child(popUpMessage)
	popUpMessage.init(message, position)

func _on_money_popup(message, position):
	""" 
	Creates new instance of our money popup, sets its message, position, and attaches it to world
	"""
	if message == "":
		return
	var popUpMessage = messagePopup.instance()

	add_child(popUpMessage)
	popUpMessage.init(message, position)

func _on_zombie_bullet_hit():
	bulletsHit += 1

func _on_Player_playerStaminaChange(value):
	$HUD/healthBarContainer/StaminaBar.value = value

func _on_Player_interactablesUpdated(interactables: Array):
	# update interactable HUD
	if len(interactables) == 0:
		$HUD/debug/interactable.text = ""
	else:
		$HUD/debug/interactable.text = str(interactables[0].interactableName)

func _on_Player_playerLog(message: String):
	$HUD.updateLog(message)

func _on_camera_shake(intensity, duration):
	$screenShaker.shake(intensity, duration)


