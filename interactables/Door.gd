extends StaticBody2D

var can_be_bought = true
var CAN_BE_BOUGHT_TIMER = 1
export var cost : int = 150
signal activate_spawners
signal playerLog
signal moneyPopup
onready var interactableName = "Open Door: " + str(cost)

var spawners_to_activate_on_open = [
	"ZombieSpawner3",
	"ZombieSpawner4",
	"ZombieSpawner6",
]

func _ready():
	var world = get_node('/root/World')
	self.connect("activate_spawners", world, '_activate_spawners')
	self.connect("playerLog", world, '_on_Player_playerLog')
	self.connect("moneyPopup", world, '_on_money_popup')

func interact(_player):
	if can_be_bought:
		can_be_bought = false
		$InteractionTimer.start(CAN_BE_BOUGHT_TIMER)
		if _player.money < cost:
			$notEnoughMoney.play()
			emit_signal("playerLog", "Not enough money")
		else:
			# Open Door
			_player.money -= cost
			var message = "- $" + str(cost)
			var messagePosition = global_position
			messagePosition.y += 200
			emit_signal("moneyPopup", message, messagePosition )
			emit_signal("playerLog", "Door open")
			$CollisionShape2D.disabled = true
			$AnimationPlayer.play("open_door")
			emit_signal("activate_spawners", spawners_to_activate_on_open)

func _on_InteractionTimer_timeout():
	can_be_bought = true
