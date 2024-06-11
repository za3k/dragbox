class_name Mine extends Area2D

@export var revealed_color : Color
@export var hidden_color : Color
var flashRemaining : float = 0
signal revealed

func _ready():
	hidden()

func hidden():
	self.hide()
	$CollisionShape2D/Polygon2D.color = hidden_color

## Show the mine for the rest of the game
func reveal():
	if not visible:
		revealed.emit()
	show()
	$CollisionShape2D/Polygon2D.color = revealed_color
	flash(2)

## Flash the mine as important. duration=0 means forever
func flash(duration):
	if duration == 0:
		flashRemaining = 1000000
	else:
		flashRemaining = duration

@export var flash_cycle_time : float = 0.3
var t : float = 0
func set_flash(on):
	if on:
		$CollisionShape2D/Polygon2D.color.a = 0.5
	else:
		$CollisionShape2D/Polygon2D.color.a = 1

func _process(delta):
	t += delta
	if (flashRemaining > 0) :
		flashRemaining -= delta
		var cycles : float = t / flash_cycle_time
		var cycle_percent = cycles - floor(cycles)
		if cycle_percent < 0.5:
			set_flash(true)
		else:
			set_flash(false)
	else:
		set_flash(false)

## Animate the mine exploding and make a sound
func explode():
	Sounds.play($Explosion)
	$ExplosionParticles.emitting = true
