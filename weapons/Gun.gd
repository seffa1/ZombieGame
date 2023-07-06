extends Node2D

signal shoot
signal updateHUD
export (PackedScene) var Bullet

# Declare member variables here. Examples:
export var CLIP_SIZE = 50
export var damage = 3
export var STARTING_AMMO = 4500
export var SINGLE_FIRE = false
export var GUN_NAME : String

# TODO: These will be controlled by player animations
export var RELOAD_SPEED = 1

onready var ammo = STARTING_AMMO setget set_ammo
onready var clip_count = CLIP_SIZE setget set_clip_count

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect this guns shoot method to the world
	var world = get_node('/root/World')
	self.connect("shoot", world, '_on_gun_shoot')
	
	# Connec the updateHUD signal to the HUD
	var hud = get_node('/root/World/HUD')
	self.connect('updateHUD', hud, '_on_update_hud_gun')
	updateHUD()

func set_ammo(_value):
	ammo = _value
	updateHUD()
	
func set_clip_count(_value):
	clip_count = _value
	updateHUD()

func shoot():	
	# create a bullet
	var dir = Vector2(1,0).rotated(global_rotation)

	# Emit bullet to the world with a reference to the player so the player can gain points if the bullet kills a zombie.
	var player_shooting = get_parent()
	emit_signal('shoot', Bullet, $Muzzle.global_position, dir, damage, player_shooting)
	
	# Update the clip count
	clip_count -= 1
	updateHUD()
		

func reload():
	if ammo == 0:
		# Tell the player there is no ammo left
		return 'No more ammo!'
	if clip_count == CLIP_SIZE:
		# Tell the player your ammo is full
		return 'Ammo is full'
	# TODO Play reload animation - On animation finish, do the rest of the logic below
	
	# reload the gun
	var amount_to_fill = CLIP_SIZE - clip_count
	if amount_to_fill > ammo:
		amount_to_fill = ammo
	ammo -= amount_to_fill
	clip_count += amount_to_fill
	updateHUD()
	return "Gun reloaded"

func updateHUD():
	emit_signal("updateHUD", clip_count, CLIP_SIZE, ammo)
