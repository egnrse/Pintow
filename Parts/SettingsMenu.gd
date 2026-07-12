## settings menu
## (sets values controlled by the settings menu)
extends Control

signal back_button()				## show the previous menu

@onready var Game := get_node_or_null("/root/Game")

# settings ordered like in the UI
@onready var animateCheckBox := %AnimateCheckBox
@onready var musicSlider := %Music_HSlider		## slider controlling the volume of the music bus
@onready var sfxSlider := %SFX_HSlider

# 
@onready var musicAudioBus := AudioServer.get_bus_index("Music")	## index of the music bus itself
@onready var sfxAudioBus := AudioServer.get_bus_index("SFX")


## set initial values (from game to UI)
func _ready() -> void:
	if not Game:
		push_error("Game is not defined")
	animateCheckBox.button_pressed = Game.animate
	musicSlider.value = AudioServer.get_bus_volume_linear(musicAudioBus)
	sfxSlider.value = AudioServer.get_bus_volume_linear(sfxAudioBus)

func _unhandled_input(event: InputEvent) -> void:
	if self.visible:
		if event.is_action_pressed("ui_close_dialog"):
			accept_event()
			previousMenu()

func _on_visibility_changed() -> void:
	if self.visible:
		animateCheckBox.grab_focus()

#region handle setting changes
func _on_animate_check_box_toggled(toggled_on: bool) -> void:
	Game.animate = toggled_on
	Game.updateAnimate()

func _on_music_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioServer.set_bus_volume_linear(musicAudioBus, musicSlider.value)
func _on_sfx_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioServer.set_bus_volume_linear(sfxAudioBus, sfxSlider.value)
#endregion handle setting changes

## return to the previous screen/menu
func previousMenu():
	back_button.emit()

func _on_button_back_pressed() -> void:
	previousMenu()
