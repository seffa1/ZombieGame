extends Node2D

const SAVE_DIR = "user://highscore/"


func _ready():
	print('title screen is ready')
	# pause the game
	get_tree().paused = true
	
	# make sure the title menu is visable
	$CanvasLayer.visible = true
	
	# toggle the HUD
	get_parent().find_node("HUD").visible = false
	
	# load high score data
	var file = File.new()
	var save_path = SAVE_DIR + "highscore.dat"
	print("searching save file at" + save_path)
	if file.file_exists(save_path):
		var error = file.open(save_path, File.READ)
		print("title screen high score save file found")
		
		if error == OK:
			var oldSaveData = file.get_var()
			file.close()
			print("title screen high score game data loaded")
			# update title screen high scores
			$CanvasLayer/highestRoundVal.text = str(oldSaveData["current_level"])
			$CanvasLayer/mostKillsVal.text = str(oldSaveData["kills"])
			$CanvasLayer/roundsFiredVal.text = str(oldSaveData["bulletsFired"])
			$CanvasLayer/roundsHitVal.text = str(oldSaveData["bulletsHit"])
			var accuracy =  round((float(oldSaveData["bulletsHit"]) / float(oldSaveData["bulletsFired"])) * 100)
			print("Accuracy" + str(accuracy))
			$CanvasLayer/AccuracyVal.text = str(accuracy) + ' %'
			
			# dataToSave = {
			# 	"current_level": current_level,
			#	"bulletsFired": bulletsFired,
			#	"bulletsHit": bulletsHit,
			#	"kills": kills
			#}
			

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
