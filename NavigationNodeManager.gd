extends Node2D

"""
This manager connects the nodes of the navigation network together.
"""

# In the future it would be cool to make a tool that does this automatically
var connections = {
	"Node1": ["Node8"],
	"Node2": ["Node3"],
	"Node3": ["Node5"],
	"Node4": ["Node3"],
	"Node5": ["Node3"],
	"Node6": ["Node5"],
	"Node7": ["Node6"],
	"Node8": ["Node9"],
	"Node9": ["Node10"],
	"Node10": ["Node4"],
	"Node11": ["Node5"]
}


# Connects all navigation nodes together based on the connections dict above
func _ready():
	# For each navigation node
	for node in get_children():
		if node.name in connections:
			# Go through the list of node names we need to connect to
			for node_name_to_connect in connections[node.name]:
				# Get the node cooresponding to that name
				var node_to_connect = get_node(node_name_to_connect)
				# Add the connection
				node.add_neighbor(node_to_connect)
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
