extends Node2D
class_name BoardData

const START: Array[int] = [
2,1,1,1,1,1,2,
4,4,4,0,4,4,4,
0,0,0,0,0,0,0,
0,0,5,0,0,0,0,
0,0,0,0,5,0,0,
0,0,0,0,0,0,0,
3,3,3,0,3,3,3,
2,1,1,1,1,1,2
]
#0=air, 1=end zone, 2=impassable zone, 3=red piece, 4=blue piece, 5=white piece

const WIDTH = 7
const HEIGHT = 8
const SQUARE_WIDTH = 50
const SQUARE_HEIGHT = 50
const P0_color = "#FF00FF"
const P1_color = "#FFFF00"
const Neutral_color = "#FFFFFF"

var board = START.duplicate()

var valid_move_grid = []

func _convert_value_coords_to_grid(x,y):
	return [floor(x/SQUARE_WIDTH-0.5), floor(y/SQUARE_HEIGHT-0.5)]

func _convert_coords_to_index(x: int,y: int):
	if x >= WIDTH or y >= HEIGHT or x < 0 or y < 0:
		return -1
	return y*WIDTH + x

func get_square(x,y):
	return board[_convert_coords_to_index(x,y)]

func set_square(x,y,value):
	var pos = _convert_coords_to_index(x,y)
	board[pos] = value
