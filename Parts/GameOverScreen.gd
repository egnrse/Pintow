## gameover death screen
extends Control

signal restart_button(caller:Node, force:bool)	## restart the level (force: force a level start)
signal settings_button(caller:Node)			## show the settings menu
signal menu_button(caller:Node)				## show the main menu

@export var deathScore := -1	## the score to display on the death screen
@onready var scoreLabel := %DeathScore
@onready var restartButton := %ButtonRestart

@export var force_wait := true	## if to enforce waiting, before the next button press
var wait_active := false		## only allow button presses if false (if [member force_wait] is true)

func _on_visibility_changed() -> void:
	if self.visible:
		restartButton.grab_focus()

## update all labels
func update() -> void:
	scoreLabel.text = str(self.score)

## call to show a gameover death screen
func death(score:int) -> void:
	wait_active = true
	self.deathScore = score
	scoreLabel.text = str(self.deathScore)
	self.visible = true
	%RestartDelay.start()

func _on_button_restart_pressed() -> void:
	if force_wait and wait_active: return
	restart_button.emit(self)
func _on_button_settings_pressed() -> void:
	if force_wait and wait_active: return
	settings_button.emit(self)
func _on_button_menu_pressed() -> void:
	if force_wait and wait_active: return
	menu_button.emit(self)


func _on_restart_delay_timeout() -> void:
	wait_active = false
