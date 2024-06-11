extends Node

enum SCORE_TYPE { NONE, PERCENT_CLAIMED, TIME, TURNS, MINES_REVEALED }
enum MINE_PLACEMENT { RANDOM, MANUAL }
enum REVEAL { NONE, PUBLIC, PRIVATE }
enum OUTCOME { CLAIM, HIGHLIGHT, LOSE, FAIL, FAIL_WITH_OUTLINE }
enum PLAYER_MINE_PLACEMENT { OPTION, MANUAL, RANDOM }
enum DIFFICULTY { EASY=5, MEDIUM=10, HARD=20 }
enum OVERLAP_ALLOWED { ALLOWED, SUBTRACT, FAIL, NOT_ALLOWED, LOSE }
enum CONDITION { CLAIM_90, TIME_LIMIT, TURN_LIMIT, CLAIM_50, REVEAL_ALL_MINES, ALWAYS, NEVER }

var game_name : String
var players : int
var mines : int
var mine_placement : MINE_PLACEMENT
var game_time_limit : int # 0 means unlimited
var turn_limit : int # this may not be used. 0 has no special meaning.
var score : SCORE_TYPE
var leaderboard : Array[SCORE_TYPE]
var overlap_reveal : REVEAL
var mine_reveal : REVEAL
var claim_reveal : REVEAL
var your_mines_count : bool
var their_mines_count : bool
var player_placement : PLAYER_MINE_PLACEMENT
var no_mines : OUTCOME
var one_mine : OUTCOME
var multiple_mines : OUTCOME
var overlap : OVERLAP_ALLOWED
var end_condition : Array[CONDITION]
var win_condition : Array[CONDITION]
var lose_condition : Array[CONDITION]
var new_game_plus : CONDITION

func reset():	
	game_name = ""
	players = 0
	mines = 0
	game_time_limit = 0
	turn_limit = 0
	your_mines_count = false
	their_mines_count = false
	end_condition = []
	win_condition = []
	lose_condition = []
	leaderboard = []
	mine_placement = MINE_PLACEMENT.RANDOM
	score = SCORE_TYPE.NONE
	overlap_reveal = REVEAL.NONE
	mine_reveal = REVEAL.NONE
	claim_reveal = REVEAL.NONE
	player_placement = PLAYER_MINE_PLACEMENT.RANDOM
	no_mines = OUTCOME.LOSE
	one_mine = OUTCOME.LOSE
	multiple_mines = OUTCOME.LOSE
	overlap = OVERLAP_ALLOWED.ALLOWED
	new_game_plus = CONDITION.NEVER

func score_for(cond : CONDITION) -> SCORE_TYPE:
	return {
		CONDITION.CLAIM_90: SCORE_TYPE.PERCENT_CLAIMED,
		CONDITION.CLAIM_50: SCORE_TYPE.PERCENT_CLAIMED,
		CONDITION.TIME_LIMIT: SCORE_TYPE.TIME,
		CONDITION.TURN_LIMIT: SCORE_TYPE.TURNS,
		CONDITION.REVEAL_ALL_MINES: SCORE_TYPE.MINES_REVEALED,
		CONDITION.ALWAYS: null,
		CONDITION.NEVER: null,		
	}[cond]

func load_preset(preset_id):
	reset()
	var preset = PRESETS[preset_id]
	
	for option in preset:
		var v = preset[option]
		if typeof(self[option]) == Variant.Type.TYPE_ARRAY:
			v = Array(v, TYPE_INT, "", null) # A dumb hack
		self[option] = v			
					
	for cond in win_condition + lose_condition + end_condition:
		var goal_score = score_for(cond)
		if goal_score and not (goal_score in leaderboard):
			leaderboard.insert(0, goal_score)
	if not (score in leaderboard):
		leaderboard.append(score)

const PRESETS := {
	"minefield1": {
		"game_name": "Minefield",
		"players": 1,
		
		"mines": DIFFICULTY.MEDIUM,
		"mine_placement": MINE_PLACEMENT.RANDOM,
		"game_time_limit": 0,
		"turn_limit": 0,
		"score": SCORE_TYPE.TURNS,
		"leaderboard": [SCORE_TYPE.MINES_REVEALED],
		"mine_reveal": REVEAL.PRIVATE,
		"claim_reveal": REVEAL.NONE,
		"your_mines_count": false,
		"no_mines": OUTCOME.CLAIM,
		"one_mine": OUTCOME.HIGHLIGHT,
		"multiple_mines": OUTCOME.LOSE,
		"overlap": OVERLAP_ALLOWED.ALLOWED,
		"win_condition": [CONDITION.CLAIM_90],
		"end_condition": [],
		"lose_condition": [],
		"new_game_plus": CONDITION.ALWAYS,
		"overlap_reveal": REVEAL.NONE, # no single-player effect
		"their_mines_count": false, # no single-player effect
		"player_placement": PLAYER_MINE_PLACEMENT.RANDOM, # no effect because no mine placement
	}
}
