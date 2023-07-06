extends StaticBody2D

var can_be_bought = true
var CAN_BE_BOUGHT_TIMER = 1
export var cost : int = 150
signal activate_spawners
onready var interactableName = "Open Door: " + str(cost)

var spawners_to_activate_on_open = [
	"ZombieSpawner3",
	"ZombieSpawner4",
	"ZombieSpawner6",
]

func _ready():
	var world = get_node('/root/World')
	self.connect("activate_spawners", world, '_activate_spawners')

func interact(_player):
	if can_be_bought:
		can_be_bought = false
		$InteractionTimer.start(CAN_BE_BOUGHT_TIMER)
		if _player.money < cost:
			print("You dont have enough money to buy this door.")
		else:
			# Open Door
			_player.money -= cost
			$CollisionShape2D.disabled = true
			$AnimationPlayer.play("open_door")
			emit_signal("activate_spawners", spawners_to_activate_on_open)

func _on_InteractionTimer_timeout():
	can_be_bought = true
