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
const AIR = 0
const END = 1
const BLOCK = 2
const P0_TILE = 3
const P1_TILE = 4
const NEUTRAL_TILE = 5

const WIDTH = 7
const HEIGHT = 8
const SQUARE_WIDTH = 50
const SQUARE_HEIGHT = 50
const P0_color = "#FF00FF"
const P1_color = "#FFFF00"
const Neutral_color = "#FFFFFF"
const STATIC_TILES = [0,1,2]

var tiles = []
var board = START.duplicate()

var valid_move_grid = []
var game_moves = []
var game_positions = []

func _convert_coords_to_index(x: int,y: int):
	if x >= WIDTH or y >= HEIGHT or x < 0 or y < 0:
		return -1
	return y*WIDTH + x

func get_square_value(x,y):
	return board[_convert_coords_to_index(x,y)]

func get_square_object(x,y):
	return tiles[_convert_coords_to_index(x,y)]

func set_square_value(x,y,value):
	var pos = _convert_coords_to_index(x,y)
	board[pos] = value
