extends Node2D
class_name EventClass
signal Setup
signal SquareClicked(x,y)
signal MouseClick(button)
signal MouseRelease(button)
signal KeyPress(key)
signal Move(x,y,direction)
signal EmptySquareClick(x,y)

signal TileSelected
signal ClearBoard

var mouse_clicked = false
var mouse_button = null
var mouse_x = 0
var mouse_y = 0

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if not mouse_clicked:
			MouseClick.emit(event.button_index)
		mouse_button = event.button_index
		mouse_clicked = true
	if event is InputEventMouseButton and not event.is_pressed():
		if mouse_clicked:
			MouseRelease.emit(event.button_index)
		mouse_button = null
		mouse_clicked = false
	
	if event is InputEventKey and event.is_pressed():
		KeyPress.emit(event.keycode)
		
	if event is InputEventMouseMotion:
		mouse_x = event.position[0]
		mouse_y = event.position[1]
