extends "res://interactables/PerkMachine.gd"


func interact(_player):
	print("Interacted with jugernaut")
	if can_be_bought and not _player.jugernaut:
		can_be_bought = false
		$Timer.start(CAN_BE_BOUGHT_TIMER)
		if _player.money < COST:
			print("You dont have enough money to buy this perk.")
		else:
			_player.money -= COST
			_player.jugernaut = true


	
