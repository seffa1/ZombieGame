extends Node2D

const SAVE_DIR = "user://saves/"

func _ready():
	$CanvasLayer.visible = false

func _input(event):
	# toggle pause on input
	if event.is_action_pressed("pause"):
		
		var new_pause_state = not get_tree().paused
		
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
	print('Saving game...')
	save_game()

func _on_resume_pressed():
	get_tree().paused = false
	$CanvasLayer.visible = false

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


