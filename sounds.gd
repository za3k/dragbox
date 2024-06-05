extends Node

var being_played = {}

func play(sound : AudioStreamPlayer2D):
	var effect := sound.stream.resource_path
	if not being_played.get(effect, false):
		sound.finished.connect(func():
			being_played[effect] = false
		)
		being_played[effect] = true
		sound.play()
