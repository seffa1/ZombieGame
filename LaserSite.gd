# Casts a laser along a raycast, emitting particles on the impact point.
# Use `is_casting` to make the laser fire and stop.
# You can attach it to a weapon or a ship; the laser will rotate with its parent.
extends RayCast2D

# Speed at which the laser extends when first fired, in pixels per seconds.
export var cast_speed := 7000.0
# Maximum length of the laser in pixels.
export var max_length := 1400.0
# Base duration of the tween animation in seconds for light and line
export var growth_time := 0.1

# If `true`, the laser is firing.
# It plays appearing and disappearing animations when it's not animating.
# See `appear()` and `disappear()` for more information.
var is_casting := false setget set_is_casting

onready var fillLine := $FillLine2D
onready var tweenLine := $TweenLine
onready var tweenLight := $TweenLight
onready var light := $Light2D

onready var line_width: float = fillLine.width

var LIGHT_ENERGY = 0.8

func _ready() -> void:
	set_physics_process(false)
	fillLine.points[1] = Vector2.ZERO

func set_is_casting(cast: bool) -> void:
	"""
	Turns the laser on and off
	"""
	is_casting = cast

	if is_casting:
		cast_to = Vector2.ZERO # laser doesnt appear instantly, starts at zero and moves out
		fillLine.points[1] = cast_to
		appear()  # animation of width to go along with the casting
	else:
		disappear()  # animation of width to go along with the casting

	set_physics_process(is_casting) # what actually gets the laser to start casting

func _physics_process(delta: float) -> void:
	"""
	physics process off by default. Only on when set_casting to true.
	cast_to is also set to (0,0) initially and increasing by the cast speed.
	"""
	# increase cast to until we hit the max length
	cast_to = (cast_to + Vector2.RIGHT * cast_speed * delta).clamped(max_length)
	
	# checks if we collided with something, and makes that the cast point instead
	# updates any effects' length to be the cast point if applicable
	cast_beam()

func cast_beam() -> void:
	"""
	Controls the emission of particles and extends the Line2D to `cast_to` or the ray's 
	collision point, whichever is closest.
	"""
	var cast_point := cast_to

	force_raycast_update()

	if is_colliding():
		# Our new collision point if we are colliding
		cast_point = to_local(get_collision_point())
		print("collisions!")
		
		# Set the effect's length to the cast point
		# $Light2D.global_rotation = get_collision_normal().angle()

		# Set collision particles to the collision point
		# $collision_particles.position = cast_point

	# with our new cast_point, update the lengths/position of everything
	fillLine.points[1] = cast_point  # set fill line vector
	#$Light2D.global_rotation = get_collision_normal().angle() # set light rotation
	
	# $collisionParticles.position = cast_point * 0.5
	# $collisionParticles.process_material.emission_box_extents.x = cast_point.length() * 0.5


func appear() -> void:
	# Tween the line
	if tweenLine.is_active():
		tweenLine.stop_all()
	tweenLine.interpolate_property(fillLine, "width", 0, line_width, growth_time * 2)
	tweenLine.start()
	
	# Tween the light
	if tweenLight.is_active():
		tweenLight.stop_all()
	tweenLight.interpolate_property(light, "energy", 0, LIGHT_ENERGY, growth_time * 2)
	tweenLight.start()


func disappear() -> void:
	# Tween the line
	print("disappear")
	if tweenLine.is_active():
		tweenLine.stop_all()
	tweenLine.interpolate_property(fillLine, "width", fillLine.width, 0, growth_time)
	tweenLine.start()
	
	# Tween the light
	if tweenLight.is_active():
		tweenLight.stop_all()
	tweenLight.interpolate_property(light, "energy", light.energy, 0, growth_time * 2)
	tweenLight.start()
