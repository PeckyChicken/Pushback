extends Node2D
class_name StateClass
enum states{
	title,
	player_moving,
	player_waiting
}
var state: states = states.player_waiting
var turn = 0
