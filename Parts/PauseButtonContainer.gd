extends Control

signal pause()	## pause button got pressed

@export var pauseOption := Globals.PauseButtonOptions.AUTO	## the current option for the pause button (see settings)
@export var autoThemeIdx := 0	## the index of the theme to show in auto mode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setPauseOption()

## hide all pause themes
func hideAll() -> void:
	for child in self.get_children():
		child.visible = false

## select the pause button theme/visibility
func setPauseOption(idx: Globals.PauseButtonOptions = pauseOption) -> void:
	#print("pause option selected: ", idx)
	match idx:
		Globals.PauseButtonOptions.AUTO: # auto (show only on mobile)
			hideAll()
			if OS.has_feature("mobile") or DisplayServer.is_touchscreen_available() :
				self.get_child(autoThemeIdx).visible = true
		Globals.PauseButtonOptions.HIDDEN: # hidden
			hideAll()
		_ when idx in Globals.PauseButtonOptions.values(): # theme
			hideAll()
			self.get_child(idx-2).visible = true
		_: # all other values
			push_error("setPauseOption: invalid pause option selected: ", idx)
			return
	pauseOption = idx


func _on_pause_button_1_pressed() -> void:
	pause.emit()
func _on_pause_button_2_pressed() -> void:
	pause.emit()
