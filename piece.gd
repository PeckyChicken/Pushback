extends Sprite2D

const KEY_DIRECTION = {KEY_A:"<",KEY_LEFT:"<",KEY_W:"^",KEY_UP:"^",KEY_D:">",KEY_RIGHT:">",KEY_S:"V",KEY_DOWN:"V"}
var copy = false
var x: int
var y: int
var hover = false
var selected = false
var moving = false
var tween = null
var type = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.MouseClick.connect(_on_mouse_clicked)
	Events.TileSelected.connect(deselect)
	Events.ClearBoard.connect(func():if copy:queue_free())
	Events.KeyPress.connect(key_press)
	Events.Move.connect(func(a,b,c): push_pieces(a,b,c,true))
	deselect()

func delete_if_copy():
	if copy:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func direction_to_linear(direction):
	var dx
	var dy
	if direction == "<":
		dx = -1
		dy = 0
	elif direction == ">":
		dx = 1
		dy = 0
	elif direction == "^":
		dx = 0
		dy = -1
	elif direction == "V":
		dx = 0
		dy = 1
	else:
		print("direction_to_linear(): Invalid direction %s, must be < > ^ or V." % [direction])
		return
	return [dx,dy]

func move_piece(direction,distance):
	if State.state == State.states.player_moving:
		return false
	State.state = State.states.player_moving
	tween = get_tree().create_tween()
	var dx
	var dy
	dx = direction_to_linear(direction)[0] * Board.SQUARE_WIDTH
	dy = direction_to_linear(direction)[1] * Board.SQUARE_HEIGHT
	dx = dx - int(dx > 0) + int(dx < 0)
	dy = dy - int(dy > 0) + int(dy < 0)
	dx *= distance
	dy *= distance
	print(dx,"x",dy)
	tween.tween_property(self,"position",Vector2(position.x+dx,position.y+dy),0.25).set_trans(Tween.TRANS_CUBIC)

	await tween.finished
	selected = false
	State.state = State.states.player_waiting
	Events.Setup.emit()
	return true

func push_pieces(pos_x,pos_y,direction,pushing):
	if [x,y] != [pos_x,pos_y]:
		return
	var dx
	var dy
	if State.state == State.states.player_moving and not pushing:
		return
	move_piece(direction,1)
	
	dx = direction_to_linear(direction)[0]
	dy = direction_to_linear(direction)[1]
	
	Board.set_square(x,y,0)
	x += dx
	y += dy
	if Board.get_square(x,y) in [3,4,5]: #If there is already a tile at the new x and y
		Events.Move.emit(pos_x+dx,pos_y+dy,direction)
	
	Board.set_square(x,y,type)

func key_press(key):
	if selected:
		if key in KEY_DIRECTION:
			$"res://GameBoard.gd".push_pieces(x,y,KEY_DIRECTION[key],false)

func _on_mouse_clicked(button):
	if hover and button == MOUSE_BUTTON_LEFT:
		var deselect_tile = selected
		Events.TileSelected.emit()
		selected = not deselect_tile
		$selection.visible = selected

func deselect():
	selected = false
	$selection.visible = false

func set_color(color):
	modulate = color

func place(pos_x,pos_y):
	position = Vector2((pos_x+0.5)*(Board.SQUARE_WIDTH-1),(pos_y+0.5)*(Board.SQUARE_HEIGHT-1))
	#print("Converted grid coordinates X: %d and Y: %d into value coordinates of X: %d and Y: %d" % [x,y,(x+0.5)*Board.SQUARE_WIDTH,(y+0.5)*Board.SQUARE_HEIGHT])

func _on_mouse_entered():
	
	hover = true

func _on_mouse_exited():
	hover = false
