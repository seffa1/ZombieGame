extends CanvasLayer

var juggernaut = preload("res://assets/perks/items_0008_superpower.png")
var PERK_ALPHA_TOGGLE_VALUE = 50


func updateLog(message: String):
	# print("LOG: " + message)
	$notificationSound.play()
	$playerLog.text = message
	$logAnimation.play("showMessage")

func _on_log_show_message_finished():
	$playerLog.text = ""

func _on_update_hud_gun(clip_count, CLIP_SIZE, ammo):
#	print(str(clip_count) + ' / ' + str(CLIP_SIZE) + '          ' + str(ammo) + ' left')
	$debug/CLIP_SIZE.text = str(CLIP_SIZE)
	$debug/clip_count.text = str(clip_count)
	$debug/ammo.text = str(ammo)

func _on_Player_health_change(_health, _maxHealth):
	# 3 or 5
	#1 - 3 or 1 - 5
	$HealthBar.value = _health * 20  # 20-60 or 20-100

func _on_Player_money_change(_value):
	$money.text = str(_value)

func _on_Player_gun_change( _current_gun : String, _other_gun : String = ''):
	$debug/current_gun.text = _current_gun
	$debug/other_gun.text = _other_gun

func _on_Player_grenade_change(_value):
	$grenade_count.text = str(_value)
	
func _on_Player_jugernaut_change(_value : bool):
	# print("Player jug change")
	if _value:
		$HBoxContainer/juggernaut.showPerk(true)
	else:
		$HBoxContainer/juggernaut.showPerk(false)
	return
	
func _on_reload():
	print("Reloading")
	$reloadAnimation.play("reload")

func reload_animation_finished():
	GLOBALS.player.current_gun_instance.on_reload_animation_finished()
	
