extends CanvasLayer


func _on_update_hud_gun(clip_count, CLIP_SIZE, ammo):
#	print(str(clip_count) + ' / ' + str(CLIP_SIZE) + '          ' + str(ammo) + ' left')
	$CLIP_SIZE.text = str(CLIP_SIZE)
	$clip_count.text = str(clip_count)
	$ammo.text = str(ammo)

func _on_Player_health_change(_value):
	$HealthBar.value = _value

func _on_Player_money_change(_value):
	$money.text = str(_value)

func _on_Player_gun_change( _current_gun : String, _other_gun : String = ''):
	$current_gun.text = _current_gun
	$other_gun.text = _other_gun

func _on_Player_grenade_change(_value):
	$Grenades/grenade_count.text = str(_value)
