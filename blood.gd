extends CPUParticles2D

func startEmitting(type: String):
	var spreadValue
	var lifetimeValue
	match type:
		"bullet":
			spreadValue = 15 + rand_range(-5, 5)
			lifetimeValue = .6 + rand_range(-.3, .3)
		"grenade":
			lifetimeValue = .6 + rand_range(-.2, .6)
			spreadValue = 180
		"melee":
			# TODO - update these
			spreadValue = 85 + rand_range(-15, 5)
			lifetimeValue = .4 + rand_range(-.2, .2)
		_:
			assert(true, "no type giving to blood emmision!")
	
	spread = spreadValue
	lifetime = lifetimeValue
	assert(lifetimeValue - .1 > 0, "blood lifetime value too small")
	$Timer.start(lifetimeValue - .1)  # just before the particle effect ends, pause it so it stays on screen
	emitting = true

func _on_Timer_timeout():
	# Pause all processing after the blood effect it over
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)

