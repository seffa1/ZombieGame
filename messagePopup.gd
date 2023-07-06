extends Control

# set by the world before the node is created and attached
onready var message = ""

func init(message, position):
	message = message
	set_global_position(position)
	assert(message != "", " message has no text!: " + str(message))
	$Label.text = message
	$AnimationPlayer.play("showMessage")


	

func showMessageComplete():
	queue_free()
