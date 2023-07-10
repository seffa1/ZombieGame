extends Node

onready var maxAmmo = preload("res://pickups/MaxAmmo.tscn")
onready var money = preload("res://pickups/Money.tscn")

# holds a reference to the player and camera
var player = null
var camera = null
var debugMode = false

# Pickup drop chances
var CHANCE_TO_DROP_PICKUP = .25

var DROP_CHANCES = {
	'maxAmmo': .5,
	'money': .5
}

func choose_drop():
	var num = rand_range(0, 100)
	var sum = DROP_CHANCES['maxAmmo'] * 100
	
	if num <= sum:  # if num < 50
		return maxAmmo
		
	sum += DROP_CHANCES['money'] * 100

	if num <= sum:  # if num < 100
		return money
