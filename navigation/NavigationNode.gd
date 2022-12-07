extends Node2D

export var WINDOW_NODE = true
var neighbors  = {}  # node: distance

func add_neighbor(node):
#	print("Adding node " + str(node.name) + " to node" + str(self.name))
	var distance = (node.position - position).length()
	neighbors[node] = distance


