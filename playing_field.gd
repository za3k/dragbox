class_name PlayingField extends ColorRect
var hidden_mine := preload("res://hidden_mine.tscn")

class DragBox:
	enum Status { NONE, PREVIEW, COMPLETE }
	var status := Status.NONE
	var _start = null
	var _current = null
	var _end = null
	var preview = ColorRect.new()
	var preview_color = Color.BLUE_VIOLET
	var final_color = Color.CORAL
	var parent : PlayingField
	func set_parent(par):
		self.parent = par
	func start(pos):
		if status == Status.COMPLETE: return
		assert(status == Status.NONE)
		_start = pos
		_current = pos
		status = Status.PREVIEW
		updatePreview()
	func stop(pos):
		if status == Status.COMPLETE: return
		assert(status == Status.PREVIEW)
		_end = pos
		status = Status.COMPLETE
		updatePreview()
		parent.rect_drawn(self, preview.get_rect())
	func update(pos):
		if status == Status.COMPLETE: return
		if status == Status.PREVIEW:
			_current = pos
			updatePreview()
	func acknowledge():
		assert(status == Status.COMPLETE)
		_start = null
		_current = null
		_end = null
		status = Status.NONE
		# Don't update the preview yet.
	func is_visible():
		return status != Status.NONE
	func is_preview():
		return status == 1
	func get_rect():
		var corners
		if status == 2:
			corners = [_start, _end]
		else:
			corners = [_start, _current]
		var upperLeft = Vector2(
			min(corners[0].x, corners[1].x),
			min(corners[0].y, corners[1].y)
		)
		var lowerRight = Vector2(
			max(corners[0].x, corners[1].x),
			max(corners[0].y, corners[1].y)
		)
		var size = lowerRight - upperLeft
		return [upperLeft, size]
	func updatePreview():
		if is_visible():
			if is_preview():
				preview.color = preview_color
			else:
				preview.color = final_color
			var r = get_rect()
			preview.position = r[0]
			preview.size = r[1]
			preview.show()
		else:
			preview.hide()

var dragbox := DragBox.new()

func rect_drawn(db: DragBox, rect: Rect2):
	turn(clip_to_playing_field(rect))
func clip_to_playing_field(rect: Rect2) -> Rect2: 
	var me = get_rect()
	me.position = Vector2.ZERO
	rect = rect.intersection(me)
	dragbox.preview.set_size(rect.size)
	dragbox.preview.position = rect.position
	return rect
	
func turn(rect: Rect2):
	var intersecting:Array[Area2D] = []
	for mine:Area2D in $mines.get_children():
		if rect.has_point(mine.position):
			intersecting.append(mine)
	
	if intersecting.size() == 0:
		claim(rect)
	elif intersecting.size() == 1:
		highlight(intersecting[0])
	else:
		lose_game_mines(intersecting)

func generate_mines(n):
	for i in n:
		var new_mine := hidden_mine.instantiate()
		$mines.add_child(new_mine)		
		new_mine.position = Vector2(randf_range(0, size.x), randf_range(0, size.y))
func _ready():
	generate_mines(20)
	dragbox.set_parent(self)
	add_child(dragbox.preview)

func claim(rect: Rect2):
	dragbox.acknowledge()
	# Make a highlighted claim for what you claimed
	# Play a happy noise
	# Print score, goal progress, check for win
	
func highlight(mine: Area2D):
	# Highlight the mine
	# Play a danger ding
	# Print score, goal progress, check for win
	
	# Slowly fade the preview
	# Wait a second or two
	dragbox.acknowledge()

func lose_game_mines(mines: Array[Area2D]):
	# Play BOOM!!! explosion
	# Highlight mines you blew up
	# Add your rectangle as a claim, maybe in another color
	# Wait a second or two
	dragbox.acknowledge()
	lose_game()

func lose_game():
	# Show "retry / exit" options
	pass

func _process(delta):
	pass

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			dragbox.start(event.position)
		else:
			dragbox.stop(event.position)
	elif event is InputEventMouseMotion and event.button_mask == 1:
		dragbox.update(event.position)
