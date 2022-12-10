extends Node2D

var can_be_bought = true
var CAN_BE_BOUGHT_TIMER = 1
var COST = 2500

func interact(_player):
	if can_be_bought:
		can_be_bought = false
		$Timer.start(CAN_BE_BOUGHT_TIMER)
		if _player.money < COST:
			print("You dont have enough money to buy this perl.")
		else:
			_player.money -= COST
			give_perk(_player)

func give_perk(player):
	assert(false, 'give_perk method not declared!')

func _on_Timer_timeout():
	can_be_bought = true
