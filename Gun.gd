extends Node2D

signal shoot
signal updateHUD
export (PackedScene) var Bullet

# Declare member variables here. Examples:
export var CLIP_SIZE = 50
export var RELOAD_SPEED = 1
export var damage = 3
export var fire_rate = .06  # seconds / bullet (.06 is an irl m16)
export var STARTING_AMMO = 4500
export var SINGLE_FIRE = false

var can_shoot = true

onready var ammo = STARTING_AMMO setget set_ammo
onready var clip_count = CLIP_SIZE setget set_clip_count

# Called when the node enters the scene tree for the first time.
func _ready():
	$GunTimer.wait_time = fire_rate
	
	# Connect this guns shoot method to the world
	var world = get_node('/root/World')
	self.connect("shoot", world, '_on_gun_shoot')
	
	# Connec the updateHUD signal to the HUD
	var hud = get_node('/root/World/HUD')
	self.connect('updateHUD', hud, '_on_update_hud_gun')
	emit_signal("updateHUD", clip_count, CLIP_SIZE, ammo)
	
	pass # Replace with function body.

func set_ammo(_value):
	ammo = _value
	emit_signal("updateHUD", clip_count, CLIP_SIZE, ammo)
	
func set_clip_count(_value):
	clip_count = _value
	emit_signal("updateHUD", clip_count, CLIP_SIZE, ammo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	# i could change this is "just_pressed" for a single shot gun
#	if SINGLE_FIRE:
#		if Input.is_action_just_pressed("click"):
#			shoot()
#	else:
#		if Input.is_action_pressed("click"):
#			shoot()
#
#	if Input.is_action_just_pressed("reload"):
#		reload()

	

func shoot():
	if can_shoot:
		if clip_count == 0:
			# tell player their gun is empty
			return
		
		# Automatic guns fire on a timer (fire rate)
		if not SINGLE_FIRE:
			can_shoot = false
			$GunTimer.start()
		
		
		# create a bullet
		var dir = Vector2(1,0).rotated(global_rotation)
#		print(dir)
		var player_shooting = get_parent()
		emit_signal('shoot', Bullet, global_position, dir, damage, player_shooting)
		clip_count -= 1
		emit_signal("updateHUD", clip_count, CLIP_SIZE, ammo)
		

func reload():
	if ammo == 0:
		# Tell the player there is no ammo left
		return
	if clip_count == CLIP_SIZE:
		# Tell the player your ammo is full
		return
	# Play reload animation
	# On animation finish, do the rest of the logic below
	var amount_to_fill = CLIP_SIZE - clip_count
	if amount_to_fill > ammo:
		amount_to_fill = ammo
	ammo -= amount_to_fill
	clip_count += amount_to_fill
	emit_signal("updateHUD", clip_count, CLIP_SIZE, ammo)


func _on_GunTimer_timeout():
	can_shoot = true
