## UI script, which ignores pause
## manages menu UI
## (eg. MainMenu, SettingsMenu, ...)
extends CanvasLayer

@onready var Game = get_parent()

# menu nodes (managed by UI)
@onready var mainMenu = $MainMenu
@onready var settingsMenu = $SettingsMenu
@onready var levelsMenu = $Levels_TODO
# screen nodes (managed by Game)
@onready var pauseScreen = $PauseScreen
@onready var gameOverScreen = $GameOverScreen

var settingsCaller: Node	## who called settings previously (to restore focus/visibility)

func _process(_delta):
	pass


func startGame(caller:Node = null, force:bool = false) -> void:
	if Game.gameStart(force):
		hideCaller(caller)

#region manageUI
func showMainMenu(caller:Node = null) -> void:
	mainMenu.visible = true
	hideCaller(caller)
func showLevels(caller:Node = null) -> void:
	push_error("levels menu not implemented")
	return
	levelsMenu.visible = true
	hideCaller(caller)
func showSettings(caller:Node = null) -> void:
	settingsMenu.visible = true
	hideCaller(caller)
	settingsCaller = caller
func prevFromSettings() -> void:
	settingsMenu.visible = false
	if settingsCaller: settingsCaller.visible = true

## hide all menus/screens (currently not in use)
func hideMenus() -> void:
	mainMenu.visible = false
	levelsMenu.visible = false
	settingsMenu.visible = false
	pauseScreen.visible = false
	gameOverScreen.visible = false

## set caller.visible to false (returns true if that worked)
func hideCaller(caller:Node = null) -> bool:
	if caller:
		caller.visible = false
		return true
	else:
		return false
#endregion manageUI
