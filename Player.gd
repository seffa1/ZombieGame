extends KinematicBody2D

signal health_change
signal money_change
signal gun_change
signal grenade_change
signal throw_grenade
signal game_over
signal jugernaut_change

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity  = Vector2()
var WALK_SPEED = 300
var RUN_SPEED = 1200
var movement_speed
var current_rooms = {}  # rooms the player is in. room_name: room
var closest_navigation_node

export (PackedScene) var STARTING_GRENADE

# Animation stuff
onready var animation_state_machine = $AnimationTree.get("parameters/playback")

# Health stuff
onready var health = max_health
var max_health = 3
var HEALTH_REGEN_AFTER_DAMAGE_RATE = 3  # how long you have to wait to start healing after taking damage
var HEALTH_REGENERATION_RATE = 1  # seconds / health you gain after the health regen after damage rate is over with
var can_heal = true

# Interactable Stuff
var interactables = []
var money = 100000 setget _set_money
var window_repairs_this_round = 0
var MAX_WINDOW_REPAIRS_PER_ROUND = 8

# Guns
export (PackedScene) var STARTING_GUN
var SWITCH_WEAPON_TIMER = .1 # Replace this with an animation method call
var single_fire : bool = true  # gets set during equip / switch weapons
var current_gun_instance : Node2D
var other_gun_instance : Node2D
var can_switch_weapons = true
var can_shoot = true  # Controller by gun shoot animations

# Grenades
var MAX_GRENADE_COUNT = 10
var MIN_GRENADE_CHARGE = 2
var MAX_GRENADE_CHARGE = 300  # frames
export onready var grenade : PackedScene = STARTING_GRENADE
export var grenade_count = 1000 setget set_grenade
var charging_grenade = false
var can_throw_grenade = true
var grenade_throw_velocity = Vector2.ZERO

# Melee
var meleeable_zombies = []
var can_melee = true
var melee_lunge = false
var melee_damage = 5
var chosen_zombie

# Perks
var jugernaut = false setget set_jugernaut
var double_tap = false
var stamina_up = false
var revive = false
var speed_cola = false

func set_jugernaut(_value : bool):
	jugernaut = _value
	if jugernaut:
		max_health = 5
	else:
		max_health = 3
	health = max_health
	emit_signal("health_change", health, max_health)
	emit_signal("jugernaut_change", _value)

func _draw():
	draw_line((grenade_throw_velocity).rotated(-rotation), Vector2(), Color(0,0,0), 1, true)

func _ready():
	emit_signal("health_change", health, max_health)
	emit_signal("money_change", money)
	emit_signal("grenade_change", grenade_count)
	current_gun_instance = STARTING_GUN.instance()
	add_child(current_gun_instance)
	emit_signal("gun_change", current_gun_instance.GUN_NAME)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update()
#	print(charging_grenade)
	
	find_closest_navigation_node()
	if can_heal and health < max_health:
		heal()
		
	# If we are not in the middle of a melee attack
	if can_melee:
		if Input.is_action_just_pressed("melee"):
			melee()
	
		if single_fire:
			if Input.is_action_just_pressed("click") and can_shoot:
				shoot()
		else:
			if Input.is_action_pressed("click") and can_shoot:
				shoot()

		if Input.is_action_just_pressed("reload"):
			reload()
		
	if Input.is_action_pressed("grenade") and can_throw_grenade:
		charge_grenade()
			
	if Input.is_action_just_released("grenade"):
		throw_grenade()

	if Input.is_action_pressed("interact"):
		if len(interactables) > 0:
			# Only interact with one thing at a time
			if interactables[0].has_method("interact"):
				interactables[0].interact(self)
				
	if Input.is_action_just_pressed("switch_weapons"):
		switch_weapons()
	
	if Input.is_action_pressed("run"):
		movement_speed = RUN_SPEED
	else:
		movement_speed = WALK_SPEED
	
	velocity = get_input_vector()
	
	# If we are not shooting or meleeing, choose an idle or walking animation
	if can_shoot and can_melee:
		if velocity.length() == 0:
			match current_gun_instance.GUN_NAME:
				"PISTOL":
					animation_state_machine.travel("pistol_idle")
				"RIFFLE":
					animation_state_machine.travel("riffle_idle")
		else:
			match current_gun_instance.GUN_NAME:
				"PISTOL":
					animation_state_machine.travel("pistol_walk")
				"RIFFLE":
					animation_state_machine.travel("riffle_walk")
		
	look_at(get_global_mouse_position())
	velocity = move_and_slide(velocity.normalized() * movement_speed)

func reload():
	current_gun_instance.reload()

func shoot():
	if current_gun_instance.clip_count > 0:
		can_shoot = false
		current_gun_instance.shoot()
		
		# TODO: decouple this
		match current_gun_instance.GUN_NAME:
			"PISTOL":
				animation_state_machine.travel("pistol_shoot")
			"RIFFLE":
				animation_state_machine.travel("riffle_shoot")

func refill_ammo(refillCurrentGun: bool, refillOtherGun: bool):
	if refillOtherGun and other_gun_instance:
		other_gun_instance.clip_count = other_gun_instance.CLIP_SIZE
		other_gun_instance.ammo = other_gun_instance.STARTING_AMMO
		
	if refillCurrentGun and current_gun_instance:
		print("Here")
		current_gun_instance.clip_count = current_gun_instance.CLIP_SIZE
		current_gun_instance.ammo = current_gun_instance.STARTING_AMMO
		current_gun_instance.updateHUD()

func equip_gun(_gun: PackedScene):
	# If we dont have a second gun, make the current gun our 'other gun' and equip the new one
	if other_gun_instance == null and current_gun_instance != null:
	
		# Remove the old gun from the tree
		remove_child(current_gun_instance)
		
		# Move current gun to the other gun
		other_gun_instance = current_gun_instance
	
		# Make the new gun the current gun
		current_gun_instance = _gun.instance()
	
		# Add the new gun to the tree
		single_fire = current_gun_instance.SINGLE_FIRE
		add_child(current_gun_instance)

		match current_gun_instance.GUN_NAME:
			"PISTOL":
				animation_state_machine.travel("pistol_idle")
			"RIFFLE":
				animation_state_machine.travel("riffle_idle")
		
		# Update the HUD
		emit_signal("gun_change", current_gun_instance.GUN_NAME, other_gun_instance.GUN_NAME)

	# If we already have an 'other gun' then the new gun will replace our current gun
	else:
		# Remove our current gun if we have one
		remove_child(current_gun_instance)
		
		# Equip the new gun and add it as a child
		current_gun_instance = _gun.instance()
		add_child(current_gun_instance)

		match current_gun_instance.GUN_NAME:
			"PISTOL":
				animation_state_machine.travel("pistol_idle")
			"RIFFLE":
				animation_state_machine.travel("riffle_idle")
		emit_signal("gun_change", current_gun_instance.GUN_NAME, other_gun_instance.GUN_NAME)

func switch_weapons():
	if not can_switch_weapons:
		return
	
	if not other_gun_instance:
		print("You dont have another gun. ")
		return
		
	can_switch_weapons = false
	$SwitchWeaponTimer.start(SWITCH_WEAPON_TIMER)
	
	# Remove the current gun from the tree
	remove_child(current_gun_instance)
	
	# Switch our gun references
	var temp = other_gun_instance
	other_gun_instance = current_gun_instance
	current_gun_instance = temp

	# Add the new gun to the tree and restore its state
	add_child(current_gun_instance)
	
	single_fire = current_gun_instance.SINGLE_FIRE
	
	match current_gun_instance.GUN_NAME:
		"PISTOL":
			animation_state_machine.travel("pistol_idle")
		"RIFFLE":
			animation_state_machine.travel("riffle_idle")

	emit_signal("gun_change", current_gun_instance.GUN_NAME, other_gun_instance.GUN_NAME)
	current_gun_instance.updateHUD()

func melee_do_damage():
	if chosen_zombie != null and is_instance_valid(chosen_zombie):
		chosen_zombie.take_damage(melee_damage, self)
	velocity = Vector2.ZERO

func melee():
	can_melee = false
	can_throw_grenade = false
	if len(meleeable_zombies) == 0:
		print("Melee miss")
		animation_state_machine.travel("melee_miss")
	else:
		var distance = INF
		for zombie in meleeable_zombies:
			var d = (zombie.global_position - global_position).length()
			if d < distance:
				distance = d
				chosen_zombie = zombie
		print("melee hit")
		animation_state_machine.travel("melee_hit")

func charge_grenade():
	# On the first call, we create the grenade and attach it to ourselves
	if not charging_grenade:
		charging_grenade = true
		can_melee = false
		if grenade_count == 0:
			return
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
			grenade_throw_velocity = Vector2.ZERO
			can_melee = true
			print('g is null')
			return
			
		# Do we actually need this? 
		grenade_throw_velocity = (get_global_mouse_position() - global_position)

func throw_grenade():
	# Launch the grenade in the given direction
	
	var g = get_node("Grenade")
	
	# If the grenade blew up in our hands
	if g == null:
		grenade_throw_velocity = Vector2.ZERO
		charging_grenade = false
		can_melee = true
		return
	
	remove_child(g)
	emit_signal("throw_grenade", grenade, self)
	
	# clean up
	grenade_throw_velocity = Vector2.ZERO
	update()  # Calls draw again so the charging line disappears
	charging_grenade = false
	can_melee = true

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
	emit_signal("health_change", health, max_health)
	$HealTimer.start(HEALTH_REGENERATION_RATE)

func take_damage(amount):
	can_heal = false
	health -= amount
	if health <= 0:
		gameOver()
	emit_signal("health_change", health, max_health)
	$HealTimer.start(HEALTH_REGEN_AFTER_DAMAGE_RATE)
	animation_state_machine.travel("take_damage")


func gameOver():
	# TODO: replace with death animation
	emit_signal("game_over")
	queue_free()
	

func _on_shootAnimation_finished():
	can_shoot = true


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

func _on_MeleeDetector_body_entered(body):
	meleeable_zombies.append(body)

func _on_MeleeDetector_body_exited(body):
	meleeable_zombies.erase(body)

func _on_meleeAnimation_finished():
	can_melee = true
	can_throw_grenade = true
