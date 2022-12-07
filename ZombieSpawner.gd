extends Node2D

onready var zombie = preload("res://zombie/Zombie.tscn")
signal spawner_ready

export var active = false
var SPAWN_COOLDOWN = 1
var can_spawn_zombie = true
signal spawn_zombie
var target_window  # Gets set to a navigation node via the world

# Called when the node enters the scene tree for the first time.
func _ready():
	var world = get_node('/root/World')
	self.connect("spawn_zombie", world, '_on_zombie_spawn')
	$SpawnTimer.wait_time = SPAWN_COOLDOWN
	self.connect('spawner_ready', world, '_on_spawner_ready')
	emit_signal("spawner_ready", self, global_position)

func spawn_zombie():
	if not target_window or not active:
		return
	else:
#		print("targeting windows " + str(target_window.get_instance_id()) + ' ' + str(target_window.name))
	#	print(zombies_to_spawn)
		$SpawnTimer.start()
		can_spawn_zombie = false
		emit_signal("spawn_zombie", zombie, global_position, target_window.global_position)

func _on_SpawnTimer_timeout():
	can_spawn_zombie = true


	
