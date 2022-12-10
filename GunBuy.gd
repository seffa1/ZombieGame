extends StaticBody2D


export (PackedScene) var gun
export (String) var gun_name
export (int) var cost
var can_be_bought = true
var CAN_BE_BOUGHT_TIMER = 1

func interact(_player):
	if can_be_bought:
		can_be_bought = false
		$InteractionTimer.start(CAN_BE_BOUGHT_TIMER)
		if _player.money < cost:
			print("You dont have enough money to buy this gun.")
		else:
			print("You bought a gun " + gun_name)
			var gun_scene : PackedScene = gun
			
			_player.equip_gun(gun_scene)
			_player.money -= cost



func _on_InteractionTimer_timeout():
	can_be_bought = true
