extends Node2D

func play_minefield1():
	Options.load_preset("minefield1")
	get_tree().change_scene_to_file.call_deferred("res://play_game.tscn")

func quit():
	get_tree().quit()
