extends Light2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("flash")


func _on_animation_finished():
	return
