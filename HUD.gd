extends CanvasLayer

var juggernaut = preload("res://assets/perks/items_0008_superpower.png")
var PERK_ALPHA_TOGGLE_VALUE = 50

onready var pistolImg = preload("res://assets/pistol/pistol_buy.png")
onready var riffleImg = preload("res://assets/riffle/riffle_buy.png")

func _ready():
	$seconday.texture = null
	$primary.texture = pistolImg

func updateLog(message: String):
	# print("LOG: " + message)
	$notificationSound.play()
	$playerLog.text = message
	$logAnimation.play("showMessage")

func _on_log_show_message_finished():
	$playerLog.text = ""

func setAmmoCount(count, target):
	"""
	Set ammo count for either $bulletsUnder or $bulletsOver
	"""
	var pixelsPerBullet = 6
	
	if count == 0:
		target.visible = false
	else:
		target.visible = true
		target.rect_size.x = count * pixelsPerBullet


func _on_update_hud_gun(clip_count, CLIP_SIZE, ammo):
#	print(str(clip_count) + ' / ' + str(CLIP_SIZE) + '          ' + str(ammo) + ' left')
	$debug/CLIP_SIZE.text = str(CLIP_SIZE)
	$debug/clip_count.text = str(clip_count)
	$debug/ammo.text = str(ammo)
	
	# set max bullet sprite and current bullet sprite progress bar
	setAmmoCount(CLIP_SIZE, $bulletsUnder)
	setAmmoCount(clip_count, $bulletsOver)

func _on_Player_health_change(_health, _maxHealth):
	# 3 or 5
	#1 - 3 or 1 - 5
	$healthBarContainer/HealthBar.value = _health * 20  # 20-60 or 20-100

func _on_Player_money_change(_value):
	$money.text = str(_value)

func _on_Player_gun_change( _current_gun : String, _other_gun : String = ''):
	$debug/current_gun.text = _current_gun
	$debug/other_gun.text = _other_gun
	
	print(_current_gun)
	print(_other_gun)
	
	match _current_gun:
		"PISTOL":
			print("Pistol as primary equipped")
			$primary.texture = pistolImg
		"RIFFLE":
			print("Riffle as primary equipped")
			$primary.texture = riffleImg

	match _other_gun:
		"PISTOL":
			print("Pistol as secondary equipped")
			$seconday.texture = pistolImg
		"RIFFLE":
			print("Riffle as secondary equipped")
			$seconday.texture = riffleImg

	

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
	$reloadAnimation.play("reload")

func reload_animation_finished():
	GLOBALS.player.current_gun_instance.on_reload_animation_finished()
	
