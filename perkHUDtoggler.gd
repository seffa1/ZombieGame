extends Sprite


onready var animationPlayer = $AnimationPlayer

func showPerk(_value: bool):
	if _value:
		animationPlayer.play("showPerk")
	else:
		animationPlayer.play("hidePerk")
