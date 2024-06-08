extends Node

var being_played = {}

func play(sound : AudioStreamPlayer2D):
	var effect := sound.stream.resource_path
	if not being_played.get(effect, false):
		being_played[effect] = true
		sound.play()
		var done = func():
			being_played[effect] = false
		
		sound.finished.connect(done)
		sound.tree_exiting.connect(done)
