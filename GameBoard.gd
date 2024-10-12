extends Sprite2D

const COLORS = {0:"ffffff",3:Board.P0_color,4:Board.P1_color,5:Board.Neutral_color}

var tile_texture = load("res://Tiles/white.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.Setup.connect(setup)
	Events.EmptySquareClick.connect(square_click)
	setup()

func setup():
	setup_board_tiles()

func setup_board_tiles():
	Events.ClearBoard.emit()
	Board.tiles.clear()
	for y in range(Board.HEIGHT):
		for x in range(Board.WIDTH):
			var square_type = Board.get_square_value(x,y)
			if square_type in [1,2]: #If square is a board square.
				Board.tiles.append(0)
				continue
			if square_type not in [0,3,4,5]:
				print("ERROR: square_type was value %s, which is an unrecognised value." % [square_type])
				Board.tiles.append(0)
				continue
			var new_tile = $Tile.duplicate()
			Board.tiles.append(new_tile)
			new_tile.copy = true
			new_tile.x = x
			new_tile.y = y
			new_tile.set_color(COLORS.get(square_type))
			new_tile.type = square_type
			new_tile.place(x,y)
			if square_type == 0:
				new_tile.texture = null
			else:
				new_tile.texture = tile_texture
			new_tile.show()
			add_child(new_tile)
	$Tile.hide()

func setup_dead_tiles()

func is_valid_move(tiles: Array,direction):
	#Assuming first item in array is the tile pushing.
	#See "rules.txt" for an explaination of the rules in English.
	
	var dcoords = $Tile.direction_to_linear(direction)
	var dx = dcoords[0]
	var dy = dcoords[1]
	if len(tiles) == 0:
		return false
	var tail_tile = tiles[0]
	var head_tile = tiles[-1]
	
	var end_square = Board.get_square_value(head_tile.x+dx,head_tile.y+dy)
	
	if State.state == State.states.player_moving:
		return false
	
	if tail_tile.type - 3 != State.turn: #The player can only move their own tiles
		return false
	
	if end_square == Board.BLOCK:
		return false
	
	if end_square == Board.END and head_tile.type == Board.NEUTRAL_TILE:
		return false
	
	var strength = 0
	#Strength goes up by 1 for each tile of your own color pushing
	#And goes down by 1 for each tile of your opponent's color pushing.
	#You need a non-negative strength to be able to push.
	var prev_tile = null
	for tile in tiles:
		if tile.type == tail_tile.type:
			strength += 1
		else:
			strength -= 1
		if prev_tile and prev_tile.type != tail_tile.type and tile.type == tail_tile.type:
			return false
		prev_tile = tile
	if strength < 0:
		return false
	
	return true

func find_line(pos_x,pos_y,direction):
	var line = []
	while Board.get_square_value(pos_x,pos_y) not in Board.STATIC_TILES:
		line.append(Board.get_square_object(pos_x,pos_y))
		var dcoords = $Tile.direction_to_linear(direction)
		pos_x += dcoords[0]
		pos_y += dcoords[1]
	return line

func push_tiles(tiles: Array,direction,distance):
	if State.state == State.states.player_moving:
		return false
	for tile in tiles:
		Board.set_square_value(tile.x,tile.y,0)
		tile.move(direction,distance)
		if Board.get_square_value(tile.x,tile.y) != Board.END:
			Board.set_square_value(tile.x,tile.y,tile.type)

func square_click(pos_x,pos_y):
	if not Board.selected:
		return
	var dx = pos_x - Board.selected_x
	var dy = pos_y - Board.selected_y
	if abs(dx)+abs(dy) > 1:
		return
	var direction = $Tile.linear_to_direction(dx,dy)
	Board.get_square_object(Board.selected_x,Board.selected_y).play_move(Board.selected_x,Board.selected_y,direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
