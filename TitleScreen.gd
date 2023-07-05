extends Node2D

const SAVE_DIR = "user://saves/"

func _ready():
	# pause the game
	get_tree().paused = true
	# make sure the title menu is visable
	$CanvasLayer.visible = true
	# toggle the HUD
	get_parent().find_node("HUD").visible = false

## TODO: load the high score data

func _on_quit_pressed():
	get_tree().quit()
	
func _on_start_pressed():
	get_tree().paused = false
	$CanvasLayer.visible = false
	get_parent().find_node("HUD").visible = true

func _on_load_pressed():
	print('Loading game...')
	var save_path = SAVE_DIR + "save.dat"
	var file = File.new()

	if file.file_exists(save_path):
		var error = file.open(save_path, File.READ)
		print("save file found")
		
		if error == OK:
			var game_data = file.get_var()
			file.close()
			print("game data loaded")
			print(game_data)
		
	pass # Replace with function body.
