extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 4500
var velocity = Vector2()
var bullet_damage
var player_shooting

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(_damage, _player_shooting):
	bullet_damage = _damage
	player_shooting = _player_shooting
	
#	print(bullet_damage)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta

func start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed

func _on_Timer_timeout():
	queue_free()


func _on_Bullet_body_entered(body):
	# Damage an enemy
	if body.has_method('take_damage'):
		body.take_damage(bullet_damage, player_shooting, "bullet")
		
	queue_free()
