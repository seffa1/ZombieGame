extends "res://Pickup.gd"

var MONEY_TO_DROP = 1000

# Unique effect depending on the pickup
func pickupEffect(player):
	player.money += MONEY_TO_DROP
