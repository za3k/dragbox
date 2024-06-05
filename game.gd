class_name PlayingField extends ColorRect
var hidden_mine := preload("res://hidden_mine.tscn")

## The player did something invalid
func warn():
	pass

func turn(rect: Rect2):
	var intersecting:Array[Mine] = []
	for mine in $mines.get_children():
		if rect.has_point(mine.position):
			intersecting.append(mine)
	
	if intersecting.size() == 0:
		claim(rect)
	elif intersecting.size() == 1:
		highlight(intersecting[0])
	else:
		lose_game_mines(intersecting)

func generate_mines(n):
	for i in n:
		var new_mine := hidden_mine.instantiate()
		$mines.add_child(new_mine)		
		new_mine.position = Vector2(randf_range(0, size.x), randf_range(0, size.y))
		
func _ready():
	generate_mines(20)

func claim(rect: Rect2):
	$dragbox.acknowledge()
	# Make a highlighted claim for what you claimed
	# Play a happy noise
	# Print score, goal progress, check for win
	
func highlight(mine: Area2D):
	# Highlight the mine
	# Play a danger ding
	# Print score, goal progress, check for win
	
	# Slowly fade the preview
	# Wait a second or two
	$dragbox.acknowledge()

func lose_game_mines(mines: Array[Mine]):
	# Play BOOM!!! explosion
	# Highlight mines you blew up
	# Add your rectangle as a claim, maybe in another color
	# Wait a second or two
	$dragbox.acknowledge()
	for mine in mines:
		mine.reveal()
		mine.flash(0)
		mine.explode()
	lose_game()

func lose_game():
	# Show "retry / exit" options
	pass

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			$dragbox.start(event.position)
		else:
			$dragbox.stop(event.position)
	elif event is InputEventMouseMotion and event.button_mask == 1:
		$dragbox.update(event.position)
