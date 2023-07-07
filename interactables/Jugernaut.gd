extends "res://interactables/PerkMachine.gd"
signal playerLog
signal moneyPopup

func _ready():
	var world = get_node('/root/World')
	self.connect("playerLog", world, '_on_Player_playerLog')
	self.connect("moneyPopup", world, '_on_money_popup')

func interact(_player):

	if can_be_bought and not _player.jugernaut:
		can_be_bought = false
		$Timer.start(CAN_BE_BOUGHT_TIMER)
		if _player.money < COST:
			var message = "You dont have enough money to buy this perk."
			if $playerLogTimer.is_stopped():
				emit_signal("playerLog", message)
				$playerLogTimer.start(1)
		else:
			# the player emits their own log when they get juggernaut
			# so well prevent our logger from going off
			$playerLogTimer.start(2)
			_player.money -= COST
			var message = "+ $" + str(COST)
			var messagePosition = global_position
			messagePosition.y += 50
			emit_signal("moneyPopup", message, position)
			
			_player.jugernaut = true

	# player already has juggernaut
	if _player.jugernaut:
		if $playerLogTimer.is_stopped():
			emit_signal("playerLog", "You already have jugernaut")
			$playerLogTimer.start(1)
	
func _on_Timer_timeout():
	can_be_bought = true
