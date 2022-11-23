extends KinematicBody2D

signal die_signal

# Constants
var WANDER_DISTANCE = 100
var BASE_WALKING_SPEED = 150
var WANDER_TIMER_DURATION = 10
var CLOSE_TO_TARGET = 50
onready var START_POSITION = global_position
var WALL_BOUNCE_ENABLED = false
var WALL_BOUNCE_TIMER = 1
var DAMAGE = 1
var ZOMBIE_MONEY_REWARD = 125

var state
var walkingSpeed  # Is a random number. TODO make zombie types with inheritence with different properties

onready var health = 3
var current_rooms = {}  # rooms the zombie is in. room_name: room
var closest_navigation_node

# Info passed from the zombie manager, used for A*
var player_position
var player_rooms = {}
var player_navigation_node  # the closest navigation node to the player

# Info needed for context steering
var targetPosition
var steer_force = .1
var look_ahead = 150
var num_rays = 9  # Make this an odd number
var ray_directions = []
var interest = []
var danger = []
var chosen_dir = Vector2.ZERO
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var desired_velocity = Vector2.ZERO
var wallBounce = false

# Attack state
var can_attack = true
var attackable_players = []
var attackable_windows = []

# Wander state
onready var updateWander = true
onready var wanderTimer = $WanderTimer

# DEBUG
var clickToMove = false
var draw_lines = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_process(true)  # for drawing to happening every frame
	randomize()
	wanderTimer.wait_time = rand_range(0, WANDER_TIMER_DURATION)
	
	# Connect themselves to the world
	var world = get_node('/root/World')
	self.connect("die_signal", world, '_on_zombie_death')

	# Setup the context array
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	# creates and evenly rotates unit vectors and adds them to ray_directions
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
	walkingSpeed = rand_range(BASE_WALKING_SPEED * .7, BASE_WALKING_SPEED * 1.3)
#	print(walkingSpeed)

func die():
#	print("DIE " + str(get_instance_id()))
	emit_signal("die_signal", get_instance_id())
	queue_free()
	
func _draw():
#	print("Draw")
#	print(interest)
	# Draw the velocity vector
	
	if draw_lines:
		draw_line(Vector2.ZERO, chosen_dir.normalized()*200, Color(0,0,0), 1, true)
		
		# Draw the interest vectors
		for i in num_rays:
			if interest[i] == null:
				return
			if interest[i] > 0:
				draw_line(Vector2.ZERO, ray_directions[i].normalized()*look_ahead*interest[i] , Color(0,255,0), 3, true)
			elif interest[i] == 0:
				# Red vectors are not pointing forwards
				draw_line(Vector2.ZERO, ray_directions[i].normalized()*look_ahead*0.1 , Color(255,0,0), 3, true)
			elif interest[i] < 0:
	#			print(ray_directions[i].normalized()*200 * -interest[i])
				draw_line(Vector2.ZERO, ray_directions[i].normalized()*look_ahead *-interest[i], Color(0,0,255), 3, true)
		
func _input(event):
	""" Toggle between seeking a target and wandering randomly. """
	if not clickToMove:
		return
#	if event is InputEventMouseButton:
#		if event.button_index == 1:
#			targetPosition = event.position
#			state = "seek_player"
#		else:
#			state = "wander"
func set_state(_state):
#	print("Zombie's state set to " + str(state))
	state = _state
	

				
func _physics_process(delta):
	find_closest_navigation_node()
	
	# This is the default state and ends when the zombie enters a room
	if state == "seek_window":
		# Target position is set by the zombie spawner it spawned from
		seekTarget(targetPosition, delta)
		
		if len(attackable_windows) > 0 and attackable_windows[0].board_count > 0:
			if can_attack:
				can_attack = false
				$AnimationPlayer.play("attack")
	else:
		if len(attackable_players) > 0:
			set_state("attack")
		else:
			for room in current_rooms:
					if room in player_rooms:
						state = "seek_player"
					else:
						state = "seek_node"

	if state == "seek_player":
		targetPosition = player_position
		seekTarget(targetPosition, delta)
		
	if state == "seek_node":
		var targetNode = get_navigation_node()
		targetPosition = targetNode.global_position
		seekTarget(targetPosition, delta)
		
	if state == "wander":
		if updateWander:
			# Updates the target position
			targetPosition = updateWanderTarget()
		seekTarget(targetPosition, delta)
		
	if state == "attack":
		if can_attack:
			can_attack = false
			$AnimationPlayer.play("attack")

func attack_finished():
	can_attack = true

		
func get_navigation_node():
	""" 
	A* pathfinding code here.
	
	class NavigationNode:
		var neighbors  = {}  # node: distance

		func add_neighbor(node):
			var distance = (node.position - position).length()
			neighbors[node] = distance
	"""
	if not player_navigation_node or not closest_navigation_node:
		return position
		
	# A* pathfinding code here.
	var starting_node = closest_navigation_node
	var ending_node = player_navigation_node
	
	var current_node = starting_node
	var lowest_f_cost = INF
	

	
	for neighbor in starting_node.neighbors:
		# Distance from current node to the neighbor
		var g_cost = (neighbor.global_position - current_node.global_position).length()
#		print(g_cost)
		# Distance from the neighbor to the ending node
		var h_cost = (ending_node.global_position - neighbor.global_position).length()
#		print(h_cost)
		var f_cost = g_cost + h_cost
#		print(f_cost)
		if f_cost < lowest_f_cost:
			lowest_f_cost = f_cost
			current_node = neighbor
	
#	print(current_node.name)
#	print(ending_node.name + " ending")
	
	return current_node



func update_target(player_position):
	# Check if we are in the same room as the player
	return

func seekTarget(targetPosition, delta):
	""" Uses ray casts to navigate the zombie towards a target position more natually. """
	if not targetPosition:
		return
	if closeToTarget():
			return

			
	# Context based steering
	set_interest(targetPosition)
	set_danger()
	choose_direction()


	desired_velocity = chosen_dir.rotated(rotation) * walkingSpeed
#	velocity = velocity.linear_interpolate(desired_velocity, steer_force)
#	rotation = velocity.angle()

	velocity = desired_velocity

	# This feels wrong
	# Update the rotation of the children
	$Sprite.rotation = lerp_angle($Sprite.rotation, velocity.angle(), steer_force)
	$HurtBox.rotation = lerp_angle($HurtBox.rotation, velocity.angle(), steer_force)
	$PlayerDetector.rotation = lerp_angle($PlayerDetector.rotation, velocity.angle(), steer_force)
	$WindowDetector.rotation = lerp_angle($WindowDetector.rotation, velocity.angle(), steer_force)
	
	# I have no idea why i am not able to rotate the entire node
#	rotation = lerp_angle(rotation, velocity.angle(), steer_force)

	move_and_slide(velocity)

func set_interest(targetPosition):
	
	var path_direction = (targetPosition - global_position).normalized()
	# only use vectors with position dot products (in the same direction)
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(path_direction)
#		var d = ray_directions[i].dot(path_direction)
		# ignore vectors which are not pointing in the forward direction
		interest[i] = max(0, d)
#		interest[i] = d
	# used for drawing
	update()


func set_danger():
	
	# Cast rays to find danger directions
	# Gets access to the physics space
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(position,
			position + ray_directions[i].rotated(rotation) * look_ahead,
			[self])
# Levels of danger:
# When populating the danger array, don’t just use 0 or 1, but instead calculate a danger “score” 
# based on the distance of the object. 
# Then subtract that amount from the interest rather than removing it. 
# Far away objects will have a small impact while close ones will have more.
		if result:
			var dangerDistance = (result.position - global_position).length()
			# the closer something is, the larger the danger weight
			var dangerWeight =  1 - dangerDistance / look_ahead
#			print(dangerWeight)
			# This lessens the danger amount if its colliding with a zombie instead
			# of a wall
			if result["collider"].get_filename() == "res://Zombie.tscn":
				if state == "seek_window":
					dangerWeight *= 0.1  # trying to prevent wall bounces off eachother when they havent even got inside yet
				else:
					dangerWeight *= 0.5
					
			# If the danger ray is in the same direction as the target, lessen its effect
			if interest[i] > .7:
				dangerWeight = 0
			danger[i] = dangerWeight
		else:
			danger[i] = 0
func choose_direction():
	# Dont update the direction if we are doing a wall bounce
	if wallBounce:
		return
	# Eliminate interest in slots with danger
	# Avoidance
	# Rather than a danger item canceling the interest, it could add to the interest in the opposite direction.
	for i in num_rays:
		if danger[i] > 0.0:
#			interest[i] = 0.0
			# This number dictates how hard a danger vector "pushes" away from a wall
			var magicDangerNumber = 2
			interest[i] -= danger[i] * magicDangerNumber
	# Choose direction based on remaining interest
	chosen_dir = Vector2.ZERO.rotated(rotation)
	for i in num_rays:
		# negative values should effect the dir as much as positive numbers
		var magicDirectionNumber = 1
		if interest[i] < 0:
			chosen_dir += ray_directions[i] *  interest[i] * magicDirectionNumber
		else:
			chosen_dir += ray_directions[i] * interest[i]

	chosen_dir = chosen_dir.normalized()
	
	# This happens if our target is on the other side of a wall
	# so we 'push' him away from the wall for a second
	var targetVector = (targetPosition - global_position).normalized()
	if chosen_dir.dot(targetVector) < 0:
#		print("Chosen direction away from target")
#		print(ray_directions)
#		print(danger)
#		print(interest)
		chosen_dir = targetVector.rotated(90)
		if not wallBounce and WALL_BOUNCE_ENABLED:
			#print("wall bounce")
			wallBounce = true
			$WallBounceTimer.wait_time = WALL_BOUNCE_TIMER
			$WallBounceTimer.start()
		
func _on_WallBounceTimer_timeout():
	wallBounce = false

func find_closest_navigation_node():
	# For each room we are in, check the distance to each navigation node in that room
	var distance_to_node = INF
	for room in current_rooms.values():
		for navigation_node in room.navigation_nodes.values():
			# Find the distance to each node, set the node with the smallest distance
			var distance = (navigation_node.global_position - global_position).length()
			if distance < distance_to_node:
				distance_to_node = distance
				closest_navigation_node = navigation_node

func _on_WanderTimer_timeout():
	""" Allows the zombie to wander to a new position. """
	updateWander = true

func lookAround():
	""" Starts the timers of the look around 'state' """
	$LookAroundTimer.wait_time = rand_range(0, 3)
	$LookAroundTimer.start()

func _on_LookAroundTimer_timeout():
	""" Makes the zombie look around randomly if they are at their target position. """
	# Only rotate if we are at the target positon
	if closeToTarget():
		rotate(rand_range(10, 90))

func updateWanderTarget():
	""" Returns a random point to wander towards and resets the wander timer. """
	# Reset the timer
	updateWander = false
	wanderTimer.wait_time = rand_range(WANDER_TIMER_DURATION, WANDER_TIMER_DURATION)
	wanderTimer.start()
	
	# get current position
	var position = global_position
#	print('Current pos:')
#	print(position)
	
	# get a random point within the wander distanceaaaaaaaa
	var targetPositionX = rand_range(0, 500)
	var targetPositionY = rand_range(0, 250)
	var targetPosition = Vector2(targetPositionX, targetPositionY)
#	print('Target pos:')
#	print(targetPosition)
	return targetPosition

func closeToTarget():
	""" Prevent jittering when the target position is close enough"""
	if not targetPosition:
		return false
	
	return (targetPosition - global_position).length() < CLOSE_TO_TARGET

func take_damage(amount, player_shooting):
#	print(amount)
	health -= amount
	if health <= 0:
		player_shooting.money += ZOMBIE_MONEY_REWARD
		die()


func _on_RoomDetector_area_entered(area):
	current_rooms[area.name] = area


func _on_RoomDetector_area_exited(area):
	current_rooms.erase(area.name)

func _on_HurtBox_body_entered(body):
#	print("Body entered hurtbox")
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)

func _on_PlayerDetector_body_entered(body):
	attackable_players.append(body)
	
func _on_PlayerDetector_body_exited(body):
	attackable_players.erase(body)

func _on_WindowDetector_body_entered(body):
	attackable_windows.append(body)

func _on_WindowDetector_body_exited(body):
	attackable_windows.erase(body)
