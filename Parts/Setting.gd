## class for a (single) game setting
## 
## (used by settingsRegistry in SettingMenu.gd)
class_name Setting extends Resource

@export var string_key: String	## string key for export
@export var default: Variant	## default value
@export var get_ui: Callable	## function returning the current value in the ui
@export var set_ui: Callable	## function setting a new value in the ui
@export var apply: Callable		## function setting setting a new value in the game

func _init(p_string_key: String, p_default: Variant, p_get_ui: Callable, p_set_ui: Callable, p_apply: Callable) -> void:
	string_key = p_string_key
	default = p_default
	get_ui = p_get_ui
	set_ui = p_set_ui
	apply = p_apply
