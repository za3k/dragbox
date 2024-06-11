class_name PlayingField extends Node2D

@export var singleplayer_claim_color : Color
var hidden_mine := preload("res://hidden_mine.tscn")
var goal_percent_claimed = 0.9
var leaderboard_format : Array[String] = []
var mines_remaining : int = 0
var mines_discovered : int = 0
var start_time : float
var time_running := false
var time_taken : float

func new_game():
	get_tree().reload_current_scene()

func format_time(sec):
	var h : int = floor(sec/3600)
	var m : int = floor(sec/60) - h*60
	var s : int = floor(sec) - m*60
	if h > 0:
		return "%02d:%02d:%02d" % [h, m, s]
	else:
		return "%02d:%02d" % [m, s]

func update_leaderboard():
	if time_running:
		var now = Time.get_ticks_msec() / 1000
		time_taken = now - start_time
	var dict = {
		"percent_claimed": percent_claimed,
		"goal_percent_claimed": goal_percent_claimed,
		"turns_taken": turns,
		"turns_remaining": Options.turn_limit - turns,
		"mines_remaining": mines_remaining,
		"mines_total": Options.mines,
		"time_remaining": Options.game_time_limit - time_taken,
		"time_taken": time_taken,
	}
	for x in ["percent_claimed", "goal_percent_claimed"]:
		dict[x] = "%02d" % [floor(dict[x]*100)]
	for x in ["time_taken", "time_remaining"]:
		dict[x] = format_time(dict[x])
	
	for i in range(len(leaderboard_format)):
		var tc = $leaderboard.get_child(i)
		var fmt = leaderboard_format[i]
		tc.text = fmt.format(dict)

var percent_claimed : float = 0
var turns : int = 0

## The player did something invalid
func warn():
	Sounds.play($illegal)

func claim_outcome(outcome : Options.OUTCOME, rect : Rect2, mines : Array[Mine]):
	match outcome:
		Options.OUTCOME.CLAIM:
			claim(rect, mines)
		Options.OUTCOME.FAIL_WITH_OUTLINE: # TODO
			warn()
		Options.OUTCOME.FAIL:
			warn()
		Options.OUTCOME.HIGHLIGHT:
			highlight(rect, mines)
		Options.OUTCOME.LOSE:
			lose_game_mines(rect, mines)

func turn(rect: Rect2):
	if turns == 0:
		start_time = Time.get_ticks_msec() / 1000
		time_running = true
	turns += 1
	
	# TODO: Adjust claim to remove intersecting stuff, check for intersecting stuff, etc
	
	var outcome : Options.OUTCOME
	var intersecting:Array[Mine] = []
	for mine in $playing_field/mines.get_children():
		if rect.has_point(mine.position):
			intersecting.append(mine)
	
	if intersecting.size() == 0:
		outcome = Options.no_mines
	elif intersecting.size() == 1:
		outcome = Options.one_mine		
	else:
		outcome = Options.multiple_mines
	claim_outcome(outcome, rect, intersecting)

func mine_revealed():
	mines_remaining -= 1
	mines_discovered += 1

func generate_mines(n):
	mines_remaining = n
	for i in n:
		var new_mine : Mine = hidden_mine.instantiate()
		%mines.add_child(new_mine)		
		new_mine.position = Vector2(randf_range(0, $playing_field.size.x), randf_range(0, $playing_field.size.y))
		new_mine.revealed.connect(mine_revealed)

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

func claim(rect: Rect2, mines: Array[Mine]):
	%dragbox.acknowledge()
	
	var c = _claim(rect, singleplayer_claim_color)
	percent_claimed += c.get_rect().get_area() / $playing_field.get_rect().get_area()
	
	if should_win():
		win_game()
	else:
		Sounds.play($claim_sound)
	
func fade_dragbox():
	%dragbox.disable()
	await %dragbox.fade()
	%dragbox.enable()
	%dragbox.acknowledge()
	
func highlight(rect: Rect2, mines: Array[Mine]):
	# Highlight the mine
	Sounds.play($danger)
	for mine in mines:
		mine.reveal()
	
	# Fade the box
	fade_dragbox()

func lose_game_mines(rect: Rect2, mines: Array[Mine]):
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
	time_running = false

func win_game():
	Sounds.play($level_win_sound)
	$won.show()
	$exit.hide()
	%dragbox.disable()
	time_running = false

func not_implemented():
	assert(false)

func fmt_score(score : Options.SCORE_TYPE):
	var fmt
	match score:
		Options.SCORE_TYPE.MINES_REVEALED:
			if Options.CONDITION.REVEAL_ALL_MINES in Options.win_condition + Options.end_condition:
				fmt = "Goal: {mines_remaining} mines undiscovered"
			else:
				fmt = "{mines_remaining} mines undiscovered"
		Options.SCORE_TYPE.TURNS:
			if Options.turn_limit:
				fmt = "Goal: {turns_remaining} turns left"
			else:
				fmt = "{turns_taken} turns taken"
		Options.SCORE_TYPE.NONE:
			fmt = ""
		Options.SCORE_TYPE.PERCENT_CLAIMED:
			if Options.CONDITION.CLAIM_90 in Options.win_condition + Options.end_condition:
				goal_percent_claimed = 0.9
			elif Options.CONDITION.CLAIM_50 in Options.win_condition + Options.end_condition:
				goal_percent_claimed = 0.51
			else:
				goal_percent_claimed = 0
			if goal_percent_claimed > 0:
				fmt = "Goal (map claimed): {percent_claimed}/{goal_percent_claimed}%"
			else:
				fmt = "Map claimed: {percent_claimed}%"
		Options.SCORE_TYPE.TIME:
			if Options.game_time_limit:
				fmt = "Time remaining: {time_remaining}"
			else:
				fmt = "Time taken: {time_taken}"
	#if score == Options.score and "Goal" not in fmt:
	#	fmt = "(Score) " + fmt
	return fmt

func _ready():
	# UI Stuff
	$"game name".text = Options.game_name
	if Options.mines in Options.DIFFICULTY.values():
		var diff_name : String = Options.DIFFICULTY.find_key(Options.mines)
		$settings.text = "Difficulty: {0} ({1} mines)".format([
			diff_name.capitalize(), str(Options.mines)])
	else:
		$settings.text = "Difficulty: {0} mines".format([Options.mines])
	
	var rules : String = "Rules:\n\n"
	if Options.players == 1 and Options.game_time_limit == 0:
		rules += "- You draw one box at a time\n"
	else:
		not_implemented()
	
	rules += "- If your box contains 2+ mines, {0}.\n".format([readable_outcome[Options.multiple_mines]])
	rules += "- If your box contains 1 mine, {0}.\n".format([readable_outcome[Options.one_mine]])
	rules += "- If your box contains 0 mines, {0}.\n".format([readable_outcome[Options.no_mines]])
	$rules.text = rules
	
	for score in Options.leaderboard:
		var fmt = fmt_score(score)
		leaderboard_format.append(fmt)
		var label = $score.duplicate()
		label.show()
		$leaderboard.add_child(label)
		
	# Game-affecting stuff
	match Options.mine_placement:
		Options.MINE_PLACEMENT.RANDOM:
			generate_mines(Options.mines)
		Options.MINE_PLACEMENT.MANUAL:
			not_implemented()

const readable_outcome = {
	Options.OUTCOME.FAIL_WITH_OUTLINE: "nothing happens (but the box is marked)",
	Options.OUTCOME.FAIL: "nothing happens",
	Options.OUTCOME.HIGHLIGHT: "you reveal the mine",
	Options.OUTCOME.CLAIM: "you claim the box",
	Options.OUTCOME.LOSE: "you lose",
}

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

func _process(delta):
	update_leaderboard()
