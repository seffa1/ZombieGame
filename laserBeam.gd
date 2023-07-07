extends RayCast2D

var is_casting := false setget set_is_casting

func _ready():
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO
	
	self.is_casting = true

func fireLaser():
	self.is_casting= true

func _physics_process(delta):
	var cast_point := cast_to  # := is assigning but make sures types are the same (like static typing)
	
	# Updates the collision information for the ray. 
	# Use this method to update the collision information immediately instead of waiting for 
	# the next _physics_process call, for example if the ray or its parent has changed state.
	force_raycast_update()
	
	$CollisionParticles.emitting = is_colliding()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$CollisionParticles.global_rotation = get_collision_normal().angle()
		$CollisionParticles.position = cast_point
	
	# Point line at the ray's intersection
	$Line2D.points[1] = cast_point
	
	$BeamParticles.position = cast_point * 0.5
	$BeamParticles.process_material.emission_box_extents.x = cast_point.length() * 0.5

func set_is_casting(cast: bool):
	is_casting = cast
	
	$BeamParticles.emitting = is_casting
	$CastingParticles2.emitting = is_casting
	
	if is_casting:
		appear()
	else:
		$CollisionParticles.emitting = false
		disappear()
	
	set_physics_process(is_casting)

# Animation line with tweens
func appear():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 10.0, 0.2)
	$Tween.start()
	
func disappear():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 10.0, 0, 0.1)
	$Tween.start()
