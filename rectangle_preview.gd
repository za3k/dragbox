class_name PreviewRect
extends ColorRect

var p1 : Vector2 :
	set(val):
		p1 = val
		update_rect()
var p2 : Vector2 :
	set(val):
		p2 = val
		update_rect()

func update_rect():
	var upperLeft = Vector2(
		min(p1.x, p2.x),
		min(p1.y, p2.y)
	)
	var lowerRight = Vector2(
		max(p1.x, p2.x),
		max(p1.y, p2.y)
	)
	position = upperLeft
	size = lowerRight - upperLeft

func clip_to(boundary : Rect2):
	boundary.position = Vector2.ZERO
	var rect = get_rect().intersection(boundary)
	
	size = rect.size
	position = rect.position
