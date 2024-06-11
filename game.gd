class_name PlayingField extends Node2D

@export var singleplayer_claim_color : Color
var hidden_mine := preload("res://hidden_mine.tscn")
var goal_percent_claimed = 0.9

var percent_claimed : float = 0 :
	set(v):
		percent_claimed = v
		$goal.text = "Goal (map claimed): {0}% (needed: {1}%)".format([
			floor(percent_claimed*100),
			floor(goal_percent_claimed*100)
		])
var turns : int = 0 :
	set(v):
		turns = v
		$score.text = "Score (turns used): {0}".format([turns])

## The player did something invalid
func warn():
	pass

func turn(rect: Rect2):
	turns += 1
	var intersecting:Array[Mine] = []
	for mine in $playing_field/mines.get_children():
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
		%mines.add_child(new_mine)		
		new_mine.position = Vector2(randf_range(0, $playing_field.size.x), randf_range(0, $playing_field.size.y))

func new_game():
	get_tree().reload_current_scene()

func should_win():
	return percent_claimed > goal_percent_claimed

func _claim(rect: Rect2, color: Color):
	# Make a highlighted claim for what you claimed
	var c = ColorRect.new()
	c.position = rect.position
	c.size = rect.size
	c.color = color
	%claims.add_child(c)
	return c

func claim(rect: Rect2):
	%dragbox.acknowledge()
	
	var c = _claim(rect, singleplayer_claim_color)
	percent_claimed += c.get_rect().get_area() / $playing_field.get_rect().get_area()
	
	if should_win():
		win_game()
	else:
		Sounds.play($claim_sound)
	
func highlight(mine: Mine):
	# Highlight the mine
	Sounds.play($danger)
	mine.reveal()
	
	%dragbox.disable()
	print("Before fade ", Time.get_ticks_msec())
	await %dragbox.fade()
	print("After fade ", Time.get_ticks_msec())
	%dragbox.enable()
	%dragbox.acknowledge()

func lose_game_mines(mines: Array[Mine]):
	# Highlight mines you blew up
	# Play BOOM!!! explosion
	for mine in mines:
		mine.reveal() 
		mine.flash(0)
		mine.explode() 
	%dragbox.acknowledge()
	lose_game()

func lose_game():
	Sounds.play($level_lose_sound)
	$lost.show()
	$exit.hide()
	%dragbox.disable()

func win_game():
	Sounds.play($level_win_sound)
	$won.show()
	$exit.hide()
	%dragbox.disable()

func _ready():
	generate_mines(10)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			%dragbox.start(event.position)
		else:
			%dragbox.stop(event.position)
	elif event is InputEventMouseMotion and event.button_mask == 1:
		%dragbox.update(event.position)

func exit_to_menu():
	get_tree().change_scene_to_file.call_deferred("res://main_menu.tscn")
