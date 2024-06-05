extends Node

signal rect_drawn(rect: Rect2)

enum Status { NONE, PREVIEW, COMPLETE }
var status := Status.NONE
@onready var preview : PreviewRect = $preview

var preview_color = Color.BLUE_VIOLET
var final_color = Color.CORAL

func start(pos):
	if status == Status.COMPLETE: return
	assert(status == Status.NONE)
	preview.p1 = pos
	preview.p2 = pos
	status = Status.PREVIEW
	updatePreview()

func update(pos):
	if status == Status.COMPLETE: return
	if status == Status.PREVIEW:
		preview.p2 = pos
		updatePreview()

func stop(pos):
	if status == Status.COMPLETE: return
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
	# (For debugging) Don't update the preview yet.
	
func is_visible():
	return status != Status.NONE
	
func is_preview():
	return status == Status.PREVIEW

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