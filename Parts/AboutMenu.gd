## about menu
extends Control

signal back_button()				## show the previous menu

@onready var backButton := $ButtonBack

func _on_visibility_changed() -> void:
	if self.visible:
		if backButton:
			backButton.grab_focus()
		else:
			push_warning("'backButton' cant be focused")

func _on_button_back_pressed() -> void:
	back_button.emit()
