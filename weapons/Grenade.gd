extends RigidBody2D

signal shakeScreen

# Explode
var FUSE_TIMER = 3
var DAMAGE = 6
var RADIUS = 400
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	$FuseTimer.start(FUSE_TIMER)
	$hurt_box/CollisionShape2D.get_shape().radius = RADIUS
	
	# Connect signals to world
	var world = get_node('/root/World')
	self.connect("shakeScreen", world, '_on_camera_shake')

func _on_FuseTimer_timeout():
	print("Grenade exploding!")
	emit_signal("shakeScreen", 50, .5)
	$AnimationPlayer.play("explode")

func _on_explode_animation_finished():
	queue_free()

func _on_hurt_box_body_entered(body):
	assert(player, "Player not set for this grenade. ")
	if body.name != "player" and body.has_method("take_damage"):
		body.take_damage(DAMAGE, player, "grenade")

