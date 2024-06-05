class_name Mine extends Area2D

## Show the mine for the rest of the game
func reveal():
	pass

## Flash the mine as important. duration=0 means forever
func flash(duration):
	pass

## Animate the mine exploding and make a sound
func explode():
	Sounds.play($Explosion)
	$ExplosionParticles.emitting = true
