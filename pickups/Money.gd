extends "res://pickups/Pickup.gd"
signal moneyPopup
var MONEY_TO_DROP = 1000

func _ready():
	var world = get_node('/root/World')
	self.connect("moneyPopup", world, '_on_money_popup')

# Unique effect depending on the pickup
func pickupEffect(player):
	player.money += MONEY_TO_DROP
	emit_signal("moneyPopup", "+ $" + str(MONEY_TO_DROP), global_position)
