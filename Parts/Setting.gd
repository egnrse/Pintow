## class for a (single) game setting
## 
## (used by settingsRegistry in SettingMenu.gd)
class_name Setting extends Resource

@export var string_key: String	## string key for export
@export var default: Variant	## default value
@export var get_ui: Callable	## function returning the current value shown in the ui
## function setting a new value in the ui (only visual) [br]
## try to use functions that dont trigger signal updates (eg. set_value_no_signal()/set_pressed_no_signal())
@export var set_ui: Callable
@export var apply: Callable		## function applying a new value in the game

func _init(p_string_key: String, p_default: Variant, p_get_ui: Callable, p_set_ui: Callable, p_apply: Callable) -> void:
	string_key = p_string_key
	default = p_default
	get_ui = p_get_ui
	set_ui = p_set_ui
	apply = p_apply
