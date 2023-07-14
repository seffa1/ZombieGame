extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_playAgain_pressed():
	get_tree().change_scene("res://world.tscn")


func _on_quit_pressed():
	get_tree().quit()
