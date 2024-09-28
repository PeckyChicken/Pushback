extends Sprite2D

const COLORS = {3:Board.P0_color,4:Board.P1_color,5:Board.Neutral_color}

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.Setup.connect(setup)
	setup()

func setup():
	Events.ClearBoard.emit()
	for y in range(Board.HEIGHT):
		for x in range(Board.WIDTH):
			var square_type = Board.get_square(x,y)
			print(square_type)
			if square_type in [0,1,2]: #If square is empty or a board square.
				continue
			if square_type not in [3,4,5]: #It is an error call which shouldn't have happened.
				print("ERROR: square_type was value {}, which is an unrecognised value.".format(square_type))
				continue
			var new_piece = $Piece.duplicate()
			new_piece.copy = true
			new_piece.x = x
			new_piece.y = y
			new_piece.set_color(COLORS.get(square_type))
			new_piece.type = square_type
			new_piece.place(x,y)
			new_piece.show()
			add_child(new_piece)
	$Piece.hide()

func push_pieces(pos_x,pos_y,direction,pushing):
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
