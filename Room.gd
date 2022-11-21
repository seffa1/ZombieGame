extends Area2D

"""
Rooms are simply an area that can be detected by the zombies and players used for navigation.
This lets zombies know if they are in the same room as the player, which will change how its
pathfinding behaves.

Rooms also know which navigation nodes are inside of them. The player uses this to find the closest 
navigation node to themselves.

Additionaly, a zombie entering a room for the first time will change its state from winding seeking,
to player seeking. 

TODO: Remove the state changing behavior so the outside is simply another room.
"""

export (String) var ROOM_NAME
export (bool) var OUTSIDE = false
var bodies = {}
var navigation_nodes = {}

func _ready():
	assert(ROOM_NAME, "No room name set!")

func _on_Room_body_entered(body):
	bodies[body.get_instance_id()] = body.name
#	print(ROOM_NAME)
#	print(bodies)
	# TODO: This feels disgusting
	# I think i eventually just make outside a room and so they head to the 
	# nav nodes at the windows anyways
	if body.get_filename() == "res://Zombie.tscn" and not OUTSIDE:
#		print("zombied entered a room")
		if body.state == "seek_window":
#			print("Changing zombie state")
			body.set_state("seek_player")
			body.current_rooms[self.name] = self
	


func _on_Room_body_exited(body):
	bodies.erase(body.get_instance_id())
#	print(ROOM_NAME)
#	print(bodies)


func _on_Room_area_entered(area):
	if area.get_filename() == "res://NavigationNode.tscn":
		navigation_nodes[area.name] = area
#		print(area)
#		print("Entered this room")
