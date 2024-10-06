extends Sprite2D
class_name Tile

const KEY_DIRECTION = {KEY_A:"<",KEY_LEFT:"<",KEY_W:"^",KEY_UP:"^",KEY_D:">",KEY_RIGHT:">",KEY_S:"V",KEY_DOWN:"V"}
@onready var GAME_BOARD = $".."
var copy = false
var x: int
var y: int
var hover = false
var selected = false
var moving = false
var tween: Tween
var type = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.MouseClick.connect(_on_mouse_clicked)
	Events.TileSelected.connect(deselect)
	Events.ClearBoard.connect(func():if copy:queue_free())
	Events.KeyPress.connect(key_press)
	
	if not copy: $"../../tile".modulate = Board.P0_color

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

func move(direction,distance):
	
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
	tween.tween_property(self,"position",Vector2(position.x+dx,position.y+dy),0.25).set_trans(Tween.TRANS_CUBIC)
	x += direction_to_linear(direction)[0] * distance
	y += direction_to_linear(direction)[1] * distance
	if y in [0,7]:
		$TileFall.play()
	else:
		$TileMove.play()
	await tween.finished
	selected = false
	State.state = State.states.player_waiting
	Events.Setup.emit()
	return true
	
func animate_invalid_move(tiles,direction):
	var dcoords = direction_to_linear(direction)
	var dx = dcoords[0] * Board.SQUARE_WIDTH/4
	var dy = dcoords[1] * Board.SQUARE_HEIGHT/4
	tween = get_tree().create_tween().set_parallel(true)
	for tile in tiles:
		tween.tween_property(tile,"position",Vector2(tile.position.x+dx,tile.position.y+dy),0.25).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	tween = get_tree().create_tween().set_parallel(true)
	for tile in tiles:
		tween.tween_property(tile,"position",Vector2(tile.position.x-dx,tile.position.y-dy),0.25).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

func play_move(pos_x,pos_y,direction):
	Board.game_moves.append(position)
	var tiles: Array = GAME_BOARD.find_line(pos_x,pos_y,direction)
	
	if not GAME_BOARD.is_valid_move(tiles,direction):
		if State.state == State.states.player_waiting:
			State.state = State.states.player_moving
			$TileInvalidMove.play()
			await animate_invalid_move(tiles,direction)
			State.state = State.states.player_waiting
		return
	
	tiles.reverse()
	GAME_BOARD.push_tiles(tiles,direction,1)
	
	Board.game_moves.append([pos_x,pos_y,direction])
	
	State.turn += 1
	State.turn %= 2
	if State.turn == 0:
		$"../../tile".modulate = Board.P0_color
	elif State.turn == 1:
		$"../../tile".modulate = Board.P1_color
	
func key_press(key):
	if selected:
		if key in KEY_DIRECTION:
			play_move(x,y,KEY_DIRECTION[key])

func _on_mouse_clicked(button):
	if hover and button == MOUSE_BUTTON_LEFT:
		if type == 0:
			print("Square X: %s Y: %s clicked." % [x,y])
			return
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

func _on_mouse_entered():
	
	hover = true

func _on_mouse_exited():
	hover = false
