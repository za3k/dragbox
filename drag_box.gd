extends Node

signal rect_drawn(rect: Rect2)

enum Status { NONE, PREVIEW, COMPLETE }
var status := Status.NONE
@onready var preview : PreviewRect = $preview
@export var preview_color : Color
@export var final_color : Color
var enabled = true

func start(pos):
	if status == Status.COMPLETE or not enabled: return
	assert(status == Status.NONE)
	preview.p1 = pos
	preview.p2 = pos
	status = Status.PREVIEW
	updatePreview()

func update(pos):
	if status == Status.COMPLETE or status == Status.NONE or not enabled: return
	if status == Status.PREVIEW:
		preview.p2 = pos
		updatePreview()

func stop(pos):
	if status == Status.COMPLETE or status == Status.NONE or not enabled: return
	assert(status == Status.PREVIEW)
	preview.p2 = pos
	status = Status.COMPLETE
	updatePreview()
	rect_drawn.emit(preview.get_rect())
	
func clip_to_playing_field():
	preview.clip_to($"..".get_rect())
		
func acknowledge():
	assert(status == Status.COMPLETE)
	status = Status.NONE
	updatePreview()

func fade(duration=0.5):
	var step_dt = 0.01
	var num_steps = floor(duration / step_dt)
	var start_a = preview.color.a
	var end_a = 0.1
	var step_a = (end_a - start_a) / num_steps
	var endTime = Timer.new()
	for step in range(num_steps):
		await get_tree().create_timer(step_dt).timeout
		preview.color.a = start_a + step_a*step	

func is_visible():
	return status != Status.NONE
	
func is_preview():
	return status == Status.PREVIEW

func enable():
	enabled = true
func disable():
	enabled = false

func updatePreview():
	if is_visible():
		if is_preview():
			preview.color = preview_color
		else:
			preview.color = final_color
		clip_to_playing_field()
		preview.show()
	else:
		preview.hide()
