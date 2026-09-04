## levels menu
##
## Select a level to play.
extends Control

signal menu_button(caller:Node)				## show the main menu
signal play_level(levelString:String)		## play a specific level

@onready var initialFocus := $ButtonBack

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if self.visible:
		if event.is_action_pressed("ui_close_dialog"):
			accept_event()
			menu_button.emit(self)

func _on_visibility_changed() -> void:
	if self.visible:
		if initialFocus:
			initialFocus.grab_focus()
		else:
			push_warning("'%s' cant be focused" % initialFocus)

func _on_button_back_pressed() -> void:
	menu_button.emit(self)


func _on_endless_retro_pressed() -> void:
	play_level.emit("res://Levels/endlessRetro.tscn")
func _on_test_enemies_pressed() -> void:
	play_level.emit("res://Levels/testEnemies.tscn")
