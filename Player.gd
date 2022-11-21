extends KinematicBody2D

signal health_change
signal money_change
signal gun_change
signal grenade_change
signal throw_grenade

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity  = Vector2()
var WALK_SPEED = 300
var RUN_SPEED = 1200
var movement_speed
var current_rooms = {}  # rooms the player is in. room_name: room
var closest_navigation_node
export (PackedScene) var STARTING_GUN
export (PackedScene) var STARTING_GRENADE

# Health stuff
onready var health = MAX_HEALTH
var MAX_HEALTH = 1000
var HEALTH_REGEN_AFTER_DAMAGE_RATE = 3  # how long you have to wait to start healing after taking damage
var HEALTH_REGENERATION_RATE = 1  # seconds / health you gain after the health regen after damage rate is over with
var can_heal = true

# Interactable Stuff
var interactables = []
var money = 100000 setget _set_money
var gun_slots = []
var window_repairs_this_round = 0
var MAX_WINDOW_REPAIRS_PER_ROUND = 8

# Guns
var SWITCH_WEAPON_TIMER = 3 # Replace this with an animation method call
onready var current_gun : PackedScene = STARTING_GUN  # Packed Scene
onready var other_gun : PackedScene
var current_gun_name : String
var can_switch_weapons = true

# Grenades
var MAX_GRENADE_COUNT = 1000
var MIN_GRENADE_CHARGE = 2
var MAX_GRENADE_CHARGE = 300  # frames
export onready var grenade : PackedScene = STARTING_GRENADE
var grenade_count = 1000 setget set_grenade

var charging_grenade = false
var can_add_grenade_charge = true
var grenade_charge_count = 0
var grenade_charge_velocity = Vector2.ZERO

func _draw():
	draw_line((grenade_charge_velocity * grenade_charge_count * 3).rotated(-rotation), Vector2(), Color(0,0,0), 1, true)

#	if charging_grenade:
#		print("Here")
#		draw_line(global_position, get_global_mouse_position(), Color(0,0,0), 1, true)
#	else:
#		print("Dont draw line")

func _ready():
	emit_signal("health_change", (float(health) / float(MAX_HEALTH) * 100))
	emit_signal("money_change", money)
	emit_signal("grenade_change", grenade_count)
	gun_slots.append(STARTING_GUN)
	var gun = STARTING_GUN.instance()
	current_gun_name = gun.name
	emit_signal("gun_change", gun.name, "empty")
	add_child(gun)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update()
	
	find_closest_navigation_node()
	if can_heal and health < MAX_HEALTH:
		heal()
		
	if Input.is_action_pressed("grenade"):
		charge_grenade()
		
	if Input.is_action_just_released("grenade"):
		throw_grenade(grenade_charge_count, grenade_charge_velocity)
		
	if Input.is_action_pressed("interact"):
		if len(interactables) > 0:
			if interactables[0].has_method("interact"):
				# All interactions should return the money gained or lost from the interaction
				interactables[0].interact(self)
				
	if Input.is_action_just_pressed("switch_weapons"):
		switch_weapons()
	
	if Input.is_action_pressed("run"):
		movement_speed = RUN_SPEED
	else:
		movement_speed = WALK_SPEED
		
		
	velocity = get_input_vector()
	look_at(get_global_mouse_position())
	velocity = move_and_slide(velocity.normalized() * movement_speed)

func charge_grenade():
	# On the first call, we create the grenade and attach it to ourselves
	if not charging_grenade:
		if grenade_count == 0:
			return
		charging_grenade = true
		grenade_count -=1
		emit_signal("grenade_change", grenade_count)
		var g = grenade.instance()
		g.player = self
		add_child(g)
		
	# On calls while we are charging the grenade
	else:
		update()  # For drawing
		# We need to manually move the grenade
		var g = get_node("Grenade")
		# If the grenade blew up in our hands
		if g == null:
			grenade_charge_count = 0
			grenade_charge_velocity = Vector2.ZERO
			return
			
		# Do we actually need this? 
		grenade_charge_count += 1
		grenade_charge_count = min(grenade_charge_count, MAX_GRENADE_CHARGE)
		grenade_charge_velocity = (get_global_mouse_position() - global_position).normalized()
		
	
func throw_grenade(grenade_charge_count : int, velocity : Vector2):
	# Launch the grenade in the given direction
	
	var g = get_node("Grenade")
	
	
	# If the grenade blew up in our hands
	if g == null:
		grenade_charge_count = 0
		grenade_charge_velocity = Vector2.ZERO
		return
	
	remove_child(g)

	emit_signal("throw_grenade", grenade, global_position, grenade_charge_velocity, grenade_charge_count, self)
	
	# clean up
	grenade_charge_count = 0
	grenade_charge_velocity = Vector2.ZERO
	update()  # Calls draw again so the charging line disappears
	charging_grenade = false
	

	
func equip_gun(_gun: PackedScene):
	""" 
	Adds an instance of the given gun and removes the old gun from the tree. 
	It also updates a reference of both guns we have available in an array.
	"""
	var gun1 = current_gun.instance()
	
	# We currently have a current gun but no other gun
	other_gun = current_gun
	
	# Make the current gun the other gune
	current_gun = _gun
	
	# Remove the old gun from the tree
	for _node in get_children():
		if _node.get_filename() == other_gun.get_path():
			remove_child(_node)
	
	# Add the new gun to the tree
	var gun2 = current_gun.instance()
	add_child(gun2)
	
	# Update the HUD
	emit_signal("gun_change", gun2.name, gun1.name)

func switch_weapons():
	if not can_switch_weapons:
		return
	
	if not other_gun:
		print("You dont have another gun. ")
		return
		
	can_switch_weapons = false
	$SwitchWeaponTimer.start(SWITCH_WEAPON_TIMER)
		
	var gun_to_equip = other_gun.instance()
	var temp = current_gun
	current_gun = other_gun
	other_gun = temp
	
	# Remove the old gun
	for _node in get_children():
		if _node.get_filename() == temp.get_path():
			remove_child(_node)
			
	# Add the old gun
	add_child(gun_to_equip)
	
	# Update the HUD
	emit_signal("gun_change", gun_to_equip.name, temp.instance().name)

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

func set_grenade(_value : int):
	grenade_count = _value
	if grenade_count > MAX_GRENADE_COUNT:
		grenade_count = MAX_GRENADE_COUNT
	if grenade_count < 0:
		grenade_count = 0
	emit_signal("grenade_change", grenade_count)

func _set_money(_amount):
	money = _amount
	emit_signal("money_change", money)

func get_input_vector():
	velocity = Vector2()
	if Input.is_action_pressed("left"):
		velocity += Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		velocity += Vector2(1, 0)
	if Input.is_action_pressed("up"):
		velocity += Vector2(0, -1)
	if Input.is_action_pressed("down"):
		velocity += Vector2(0, 1)
	return velocity
func heal():
	can_heal = false
	health += 1
	emit_signal("health_change", (float(health) / float(MAX_HEALTH) * 100))
	$HealTimer.start(HEALTH_REGENERATION_RATE)

func take_damage(amount):
	can_heal = false
	health -= amount
	if health <= 0:
		queue_free()
	emit_signal("health_change", (float(health) / float(MAX_HEALTH) * 100))
	$HealTimer.start(HEALTH_REGEN_AFTER_DAMAGE_RATE)
	$AnimationPlayer.play("take_damage")

func _on_RoomDetector_area_entered(area):
	current_rooms[area.name] = area


func _on_RoomDetector_area_exited(area):
	current_rooms.erase(area.name)


func _on_HealTimer_timeout():
	can_heal = true


func _on_InteractDetector_body_entered(body):
	interactables.append(body)


func _on_InteractDetector_body_exited(body):
	interactables.erase(body)


func _on_SwitchWeaponTimer_timeout():
	can_switch_weapons = true
