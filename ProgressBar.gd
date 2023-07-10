extends ProgressBar

signal reload_finished

func _on_reload_finished():
	visible = false

func reload():
	visible = true
	$AnimationPlayer.play("reload")
