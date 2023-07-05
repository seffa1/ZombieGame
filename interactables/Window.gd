extends StaticBody2D


var REPAIR_SPEED = 1
var MAX_BOARD_COUNT = 6
var MONEY_FOR_REPAIR = 30
onready var board_count = MAX_BOARD_COUNT
var can_be_repaired = true
var BREAK_ANIMATION_STEP = .1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if board_count == 0:
		# Let zombies pass through from the outside
		$CollisionShape2D.one_way_collision = true
	else:
		# Dont let the zombies pass through
		$CollisionShape2D.one_way_collision = false
		
	# update the board breaking animation manually, make sure it doesnt play
	# board count 6 = 0
	# ( MAX (6) - count (6) - 1 ) * step (.1) = 0
	# ( MAX (6) - count (0) - 1) * step (.1) = .6
	
	
func take_damage(amount):
	board_count -= 1
	if board_count < 0:
		board_count = 0
	$breakAnimation.play("break")
	$breakAnimation.seek( (MAX_BOARD_COUNT - board_count - 1) * BREAK_ANIMATION_STEP, true )
	$breakAnimation.stop(false)

# Repair the window
func interact(_player):
	
	if board_count < MAX_BOARD_COUNT and can_be_repaired:
		can_be_repaired = false
		
		if _player.window_repairs_this_round < _player.MAX_WINDOW_REPAIRS_PER_ROUND:
			_player.money += MONEY_FOR_REPAIR
		_player.window_repairs_this_round += 1
		
		$AnimationPlayer.play("repair")

func repair_board_animation_finished():
	board_count += 1
	can_be_repaired = true
	if board_count > MAX_BOARD_COUNT:
		board_count = MAX_BOARD_COUNT
	$breakAnimation.play("break")
	$breakAnimation.seek( (MAX_BOARD_COUNT - board_count - 1) * BREAK_ANIMATION_STEP, true )
	$breakAnimation.stop(false)
	


