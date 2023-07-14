extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_playAgain_pressed():
	get_tree().change_scene("res://world.tscn")

func playButtonHoverSound():
	$buttonHover.play()


func _on_quit_pressed():
	get_tree().quit()

# Code for animating buttons

onready var quitButtonPosition = $CanvasLayer/quit.rect_position
onready var quitButtonPositionEnd = $CanvasLayer/quit.rect_position + Vector2(-10, -10)

func _on_quit_mouse_entered():
	playButtonHoverSound()
	$Tween.interpolate_property($CanvasLayer/quit, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/quit, "rect_position", quitButtonPosition, quitButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_quit_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/quit, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/quit, "rect_position",  quitButtonPositionEnd, quitButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
onready var playAgainButtonPosition = $CanvasLayer/playAgain.rect_position
onready var playAgainPositionEnd = $CanvasLayer/playAgain.rect_position + Vector2(-10, -10)

func _on_playAgain_mouse_entered():
	playButtonHoverSound()
	$Tween.interpolate_property($CanvasLayer/playAgain, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/playAgain, "rect_position", playAgainButtonPosition, playAgainPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_playAgain_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/playAgain, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/playAgain, "rect_position",  playAgainPositionEnd, playAgainButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


