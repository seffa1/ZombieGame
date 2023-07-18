extends Node2D

const SAVE_DIR = "user://saves/"

func _ready():
	$CanvasLayer.visible = false

func _input(event):
	# toggle pause on input if we are not at the title screen
	if event.is_action_pressed("pause") and not get_parent().find_node("TitleScreen").atTitleScreen:
		togglePauseScreen()

func togglePauseScreen():
	var new_pause_state = not get_tree().paused
	
	if new_pause_state:
		# toggle the mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# pause all processing on all tree nodes 
	# except those with "pause mode" set from STOP to Process
	# All nodes will be STOP except this one (so it doesnt stop when you pause)
	get_tree().paused = new_pause_state
	
	# toggle pause menu visability
	$CanvasLayer.visible = new_pause_state

	# toggle HUD display
	get_parent().find_node("HUD").visible = not new_pause_state

func _on_quit_pressed():
	get_tree().quit()

func _on_save_pressed():
	playButtonPressSound()
	print('Saving game...')
	save_game()

func _on_resume_pressed():
	playButtonPressSound()
	togglePauseScreen()
	# toggle the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_restart_pressed():
	get_tree().paused = false
	$CanvasLayer.visible = false
	get_tree().reload_current_scene()

func save_game():
	# This is the built in user directory at: Project -> Open User Data
	var save_path = SAVE_DIR + "save.dat"
	var data = {
		"testData": true
	}
	
	var dir = Directory.new()
	
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	var file = File.new()
	var error = file.open(save_path, File.WRITE)
	assert(error == OK, "Save file could not be opened")
	if error == OK:
		file.store_var(data)
		file.close()
		print("data saved")

func playButtonHoverSound():
	$buttonHover.play()

func playButtonPressSound():
	$buttonPress.play()

# Code for animating buttons

onready var resumeButtonPosition = $CanvasLayer/resume.rect_position
onready var resumeButtonPositionEnd = $CanvasLayer/resume.rect_position + Vector2(-10, -10)

func _on_resume_mouse_entered():
	playButtonHoverSound()
	$Tween.interpolate_property($CanvasLayer/resume, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/resume, "rect_position", resumeButtonPosition, resumeButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_resume_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/resume, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/resume, "rect_position",  resumeButtonPositionEnd, resumeButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

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
	
onready var saveButtonPosition = $CanvasLayer/save.rect_position
onready var saveButtonPositionEnd = $CanvasLayer/save.rect_position + Vector2(-10, -10)

func _on_save_mouse_entered():
	playButtonHoverSound()
	$Tween.interpolate_property($CanvasLayer/save, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/save, "rect_position", saveButtonPosition, saveButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_save_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/save, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/save, "rect_position",  saveButtonPositionEnd, saveButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
onready var restartButtonPosition = $CanvasLayer/restart.rect_position
onready var restartButtonPositionEnd = $CanvasLayer/restart.rect_position + Vector2(-10, -10)

func _on_restart_mouse_entered():
	playButtonHoverSound()
	$Tween.interpolate_property($CanvasLayer/restart, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/restart, "rect_position", restartButtonPosition, restartButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_restart_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/restart, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/restart, "rect_position",  restartButtonPositionEnd, restartButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
