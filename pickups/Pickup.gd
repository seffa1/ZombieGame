extends Node2D

var blinking = false
var blinkingFast = false
var TIME_INTERVAL_SECONDS = 3

# Unique effect depending on the pickup
func pickupEffect(player):
	push_error('No pickup effect set on child class.')

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
	queue_free()
