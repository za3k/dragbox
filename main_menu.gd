extends Node2D

func _ready():
	play_minefield1()

func play_minefield1():
	get_tree().change_scene_to_file("res://play_game.tscn")
