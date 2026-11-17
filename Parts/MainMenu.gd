## main menu
extends Control

signal play_button(caller:Node, force:bool)	## start the game (force: force a game start)
signal levels_button(caller:Node)			## show the level select menu
signal settings_button(caller:Node)			## show the settings menu

@onready var playButton := %ButtonPlay
@onready var quitButton := %ButtonQuit
@onready var closeDialog := %CloseDialog

@onready var aboutMenu := %AboutMenu
@onready var versionLabel := %LabelVersion

func _ready() -> void:
	# disable quit on web
	if OS.get_name() == "Web":
		quitButton.visible = true
		quitButton.disabled = true
	
	# set current version
	versionLabel.text = "v" + ProjectSettings.get_setting("application/config/version", "_err")

func _on_visibility_changed() -> void:
	if self.visible:
		if playButton:
			playButton.grab_focus()
		else:
			push_warning("'playButton' cant be focused")


func _on_button_play_pressed() -> void:
	play_button.emit(self, true)
func _on_button_level_pressed() -> void:
	levels_button.emit(self)
func _on_button_settings_pressed() -> void:
	settings_button.emit(self)
func _on_button_quit_pressed() -> void:
	closeDialog.show()

func _on_close_dialog_confirmed() -> void:
	get_tree().quit()


func _on_about_menu_back_button() -> void:
	aboutMenu.visible = false


func _on_about_version_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		accept_event()
		aboutMenu.visible = true
