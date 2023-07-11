extends Node2D

const SAVE_DIR = "user://highscore/"
var save_path = SAVE_DIR + "highscore.dat"

func _ready():
	print('title screen is ready')
	# pause the game
	get_tree().paused = true
	
	# make sure the title menu is visable
	$CanvasLayer.visible = true
	
	# toggle the HUD
	get_parent().find_node("HUD").visible = false
	
	# play ambiance
	$titleAmbiance1.play()
	
	loadHighScoreData()

func _on_quit_pressed():
	get_tree().quit()
	
func _on_start_pressed():
	# start game normally
	GLOBALS.debugMode = false
	print("Starting game in normal mode")
	start_game()
	
func _on_debug_pressed():
	# start game in debug
	GLOBALS.debugMode = true
	print("Starting game in debug mode")
	start_game()
	
	
func start_game():
	# start the game
	$impact.play()
	get_tree().paused = false
	$CanvasLayer.visible = false
	$titleAmbiance1.volume_db = -30
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

func _on_clearScores_pressed():
	var dir = Directory.new()
	dir.remove(save_path)
	print("high scores deleted")
	loadHighScoreData()

func loadHighScoreData():
	# load high score data
	var file = File.new()
	
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
	else:
		$CanvasLayer/highestRoundVal.text = "0"
		$CanvasLayer/mostKillsVal.text = "0"
		$CanvasLayer/roundsFiredVal.text = "0"
		$CanvasLayer/roundsHitVal.text = "0"
		$CanvasLayer/AccuracyVal.text = "0"

# Code for animating buttons

onready var startButtonPosition = $CanvasLayer/start.rect_position
onready var startButtonPositionEnd = $CanvasLayer/start.rect_position + Vector2(-10, -10)

func _on_start_mouse_entered():
	$Tween.interpolate_property($CanvasLayer/start, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/start, "rect_position", startButtonPosition, startButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_start_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/start, "rect_scale", Vector2(1.1, 1.1), Vector2(1, 1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/start, "rect_position",  startButtonPositionEnd, startButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

onready var debugButtonPosition = $CanvasLayer/debug.rect_position
onready var debugButtonPositionEnd = $CanvasLayer/debug.rect_position + Vector2(-10, -10)

func _on_debug_mouse_entered():
	$Tween.interpolate_property($CanvasLayer/debug, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/debug, "rect_position", debugButtonPosition, debugButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
func _on_debug_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/debug, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/debug, "rect_position", debugButtonPositionEnd, debugButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

onready var loadButtonPosition = $CanvasLayer/load.rect_position
onready var loadButtonPositionEnd = $CanvasLayer/load.rect_position + Vector2(-10, -10)

func _on_load_mouse_entered():
	$Tween.interpolate_property($CanvasLayer/load, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/load, "rect_position", loadButtonPosition, loadButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
func _on_load_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/load, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/load, "rect_position", loadButtonPositionEnd, loadButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

onready var clearScoresButtonPosition = $CanvasLayer/clearScores.rect_position
onready var clearScoresButtonPositionEnd = $CanvasLayer/clearScores.rect_position + Vector2(-10, -10)

func _on_clearScores_mouse_entered():
	$Tween.interpolate_property($CanvasLayer/clearScores, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/clearScores, "rect_position", clearScoresButtonPosition, clearScoresButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
func _on_clearScores_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/clearScores, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/clearScores, "rect_position", clearScoresButtonPositionEnd, clearScoresButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

onready var quitScoresButtonPosition = $CanvasLayer/quit.rect_position
onready var quitScoresButtonPositionEnd = $CanvasLayer/quit.rect_position + Vector2(-10, -10)

func _on_quit_mouse_entered():
	$Tween.interpolate_property($CanvasLayer/quit, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/quit, "rect_position", quitScoresButtonPosition, quitScoresButtonPositionEnd, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
func _on_quit_mouse_exited():
	$Tween.interpolate_property($CanvasLayer/quit, "rect_scale", Vector2(1, 1), Vector2(1.1, 1.1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CanvasLayer/quit, "rect_position", quitScoresButtonPositionEnd, quitScoresButtonPosition, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
