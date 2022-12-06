extends "res://Pickup.gd"

signal max_ammo

func _ready():
	# Connect this guns shoot method to the world
	var world = get_node('/root/World')
	self.connect("max_ammo", world, '_on_max_ammo')
	$Timer.start(TIME_INTERVAL_SECONDS)
	
# Unique effect depending on the pickup
func pickupEffect(player):
	emit_signal("max_ammo")
