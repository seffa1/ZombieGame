extends Node
	
"""
This manager tracks the position of the player, which rooms they are in, and the
closest navigation node to the player and gives that information to each zombie. 
"""
	
onready var player	

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		if node.name == "Player":
			player = node

	assert(player, "A Player needs to be a child of the Zombie Manager!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for node in get_children():
		if node.get_filename() == "res://Zombie.tscn":
			# Should i just give each zombie a reference to the player?
			node.player_position = player.global_position
			node.player_rooms = player.current_rooms
			node.player_navigation_node = player.closest_navigation_node
			
#			print("giving zombie the player's position")
			# give zombie players locations
		# We need to inform each zombie which room the player is in
		# The zombie should then be able to figure out how to get to the player

