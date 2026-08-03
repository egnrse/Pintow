## settings menu
##
## Sets values controlled by the settings UI screen and handles loading/saving user settings from/to disk.
## Initial values are often read from [member game]
extends Control

signal back_button()				## show the previous menu

# setting change signals
signal animate(yes:bool)			## turn animation on/off
signal pauseOption(option: Globals.PauseButtonOptions)	## a pause option has been selected


@onready var Game := get_node_or_null("/root/Game")	## the game root note

# settings ordered like they are in the UI
@onready var animateCheckBox := %AnimateCheckBox
@onready var musicSlider := %Music_HSlider		## slider controlling the volume of the music bus
@onready var sfxSlider := %SFX_HSlider
@onready var pauseOptionButton := %Pause_OptionButton

# audio stuff
@onready var musicAudioBus := AudioServer.get_bus_index("Music")	## index of the music bus itself
@onready var sfxAudioBus := AudioServer.get_bus_index("SFX")

# storage stuff
## runtime value storage for settings [br]
## - uses string_keys stored in settingsRegistry[example].string_key as keys [br]
## - loaded from a file by [method loadSettings] [br]
## - saved to a file by [method saveSettings]
var settingsConfig := ConfigFile.new()
var settingsCanSave := false						## if settings can be save (protection from overwriting)
const SETTINGS_FILE_PATH := "user://settings01.cfg"	## path to the settings file
const SECTION := "settings"							## the only used section rn
const OK_CONFIG_LOAD_ERR := [7]						## config load erros that can be ignored (7: file not found)
## keys for [member settingsRegistry], slightly ordered (look: 1-?, audio: 100-?)
enum SETTING_KEY { animate=1, pause_button_option=2, music_volume=100, sfx_volume=101}

## storage for 'Setting' objects using [Setting] (a class in this file) (string key, default, get_ui, set_ui, apply)
@onready var settingsRegistry : Dictionary[SETTING_KEY, Setting] = {
	SETTING_KEY.animate: Setting.new("animate", Game.animate,
		func(): return animateCheckBox.button_pressed,
		func(v): animateCheckBox.button_pressed = v,
		func(v): animate.emit(v)
	),
	SETTING_KEY.music_volume: Setting.new("music_volume", AudioServer.get_bus_volume_linear(musicAudioBus),
		func(): return musicSlider.value,
		func(v): musicSlider.value = v,
		func(v): AudioServer.set_bus_volume_linear(musicAudioBus, v)
	),
	SETTING_KEY.sfx_volume: Setting.new("sfx_volume", AudioServer.get_bus_volume_linear(sfxAudioBus),
		func(): return sfxSlider.value,
		func(v): sfxSlider.value = v,
		func(v): AudioServer.set_bus_volume_linear(sfxAudioBus, v)
	),
	SETTING_KEY.pause_button_option: Setting.new("pause_button_option", Globals.PauseButtonOptions.AUTO,
		func(): return pauseOptionButton.selected,
		func(v): pauseOptionButton.select(v),
		func(v): pauseOption.emit(v as Globals.PauseButtonOptions)
	)
}

## prepare and load settings
func _ready() -> void:
	if not Game:
		push_error("Game is not defined")
	
	# prepare
	pauseOptionButton.clear()
	for mode in Globals.PauseButtonOptions.keys():
		pauseOptionButton.add_item(mode.capitalize())
	
	# wait until everything is ready before loading settings
	await Game.ready
	loadSettings()

func _unhandled_input(event: InputEvent) -> void:
	if self.visible:
		if event.is_action_pressed("ui_close_dialog"):
			accept_event()
			previousMenu()

func _on_visibility_changed() -> void:
	if self.visible:
		if animateCheckBox:
			animateCheckBox.grab_focus()

## return to the previous screen/menu
func previousMenu():
	back_button.emit()
func _on_button_back_pressed() -> void:
	previousMenu()

#region store/load settings
## load settingsConfig from a file
## (sets [member settingsCanSave] to true if everything was fine)
func loadSettings() -> bool:
	var err := settingsConfig.load(SETTINGS_FILE_PATH)
	for key in settingsRegistry:
		var s = settingsRegistry[key]
		var val = s.default
		if err == OK:
			val = settingsConfig.get_value(SECTION, s.string_key, s.default)
		
		s.set_ui.call(val)
		s.apply.call(val)
	
	if err != OK and err not in OK_CONFIG_LOAD_ERR:
		push_error("failed to load settings from '%s' (err: %d)" % [SETTINGS_FILE_PATH, err])
		return false
	else: 
		settingsCanSave = true
	return true

## return the first [Setting] from [member settingsRegistry] with matching (string_)key
## (returns null on not found)
func findValue(string_key:String) -> Setting:
	for s in settingsRegistry.values():
		if s.string_key == string_key:
			return s
	return null

## saves a minimized version of settingsConfig to a file (only if [member settingsCanSave] is true)
func saveSettings(force := false) -> bool:
	# mimimize the stored config (only store non default values)
	var minConfig := ConfigFile.new()
	for sec in settingsConfig.get_sections():
		for sk in settingsConfig.get_section_keys(sec):
			var val = settingsConfig.get_value(sec,sk)
			var s := findValue(sk)
			if not s:
				push_warning("'settingsConfig' has an invalid string_key: '%s'" % sk)
			elif s.default != val:
				minConfig.set_value(sec, sk, val)
	if not settingsCanSave and not force:
		push_warning("'settingsCanSave' is false, will not save settings")
		return false
	var err := minConfig.save(SETTINGS_FILE_PATH)
	if err != OK:
		push_warning("failed to save to '%s' (err: %d)" % [SETTINGS_FILE_PATH, err])
		return false
	return true

## update a setting given a key for [member settingsRegistry] (optionally give a value)
func updateSetting(key: SETTING_KEY, value: Variant = null) -> bool:
	var s: Setting = settingsRegistry.get(key)
	if not s:	# s = null
		push_error("key '%s' not found in 'settingsRegistry'" % [key as SETTING_KEY])
		return false
	if not value:	# fetch a value if none was given
		value = s.get_ui.call()
	if typeof(value) != typeof(s.default):
		push_error("ignoring value with weird type (key: '%s', value: '%s', type: '%s', \
			should_type: '%s')" % [key as SETTING_KEY, value, typeof(value), typeof(s.default)])
		return false
	s.apply.call(value)
	settingsConfig.set_value(SECTION, s.string_key, value)
	return saveSettings()
#endregion save/load settings


#region handle setting changes
func _on_reset_settings_button_pressed() -> void:
	push_warning("!! reseting config file !!")
	settingsConfig = ConfigFile.new()
	saveSettings(true)
	loadSettings()

func _on_animate_check_box_toggled(toggled_on: bool) -> void:
	updateSetting(SETTING_KEY.animate, toggled_on)

func _on_music_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		updateSetting(SETTING_KEY.music_volume)
func _on_sfx_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		updateSetting(SETTING_KEY.sfx_volume)

func _on_pause_option_button_item_selected(index: int) -> void:
	updateSetting(SETTING_KEY.pause_button_option, index)


#endregion handle setting changes
