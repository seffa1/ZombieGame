extends StaticBody2D

var can_be_bought = true
var CAN_BE_BOUGHT_TIMER = .1
export var cost : int = 1500

func interact(_player):
	if can_be_bought:
		can_be_bought = false
		$InteractionTimer.start(CAN_BE_BOUGHT_TIMER)
		if _player.money < cost:
			print("You dont have enough money to buy this door.")
		else:
			_player.money -= cost
			$CollisionShape2D.disabled = true
			$AnimationPlayer.play("open_door")







func _on_InteractionTimer_timeout():
	pass # Replace with function body.
