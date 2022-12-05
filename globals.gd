extends Node

onready var maxAmmo = preload("res://MaxAmmo.tscn")

# Pickup drop chances
var CHANCE_TO_DROP_PICKUP = 1

var DROP_CHANCES = {
	'maxAmmo': 1
}

func choose_drop():
	return maxAmmo

