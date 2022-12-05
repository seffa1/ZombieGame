extends Node2D

var blinking = false
var blinkingFast = false
var TIME_INTERVAL_SECONDS = 10

signal max_ammo

func _ready():
	# Connect this guns shoot method to the world
	var world = get_node('/root/World')
	self.connect("max_ammo", world, '_on_max_ammo')

# Unique effect depending on the pickup
func pickupEffect(player):
	emit_signal("max_ammo")

func _on_Timer_timeout():
	if not blinking:
		blinking = true
		$AnimationPlayer.play("blinking")
		$Timer.start(TIME_INTERVAL_SECONDS)
	
	elif not blinkingFast:
		blinkingFast = true
		$AnimationPlayer.play()
		$Timer.start(TIME_INTERVAL_SECONDS)
		
	else:
		queue_free()


func _on_Area2D_body_entered(body):
	if body.get_filename() == "res://Player.tscn":
		pickupEffect(body)
