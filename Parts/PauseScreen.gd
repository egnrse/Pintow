## pause screen
## (handles game pause/resume)
extends Control

signal settings_button(caller:Node)			## show the settings menu
signal menu_button(caller:Node)				## show the main menu

@export var Game:Node					## the node to pause on pause(true)
var mouseMode = null					## remember the previous mouse mode
var justPaused := false					## if thegame was just paused
@onready var waitTimer := $waitTimer	## force wait before continuing
@onready var continueButton := %ButtonContinue

func _ready() -> void:
	if not Game:
		push_error("Game is not defined")

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if self.visible:
		if event.is_action_pressed("continuePause") and not justPaused:
			accept_event()
			pause(false)

func _on_visibility_changed() -> void:
	if self.visible:
		continueButton.grab_focus()

## pause/resume the game
func pause(start:=true) -> void:
	#print("pause: ", start)
	justPaused = true
	if start == get_tree().paused:
		push_error("already paused/resumed")
	self.visible = start
	if start:
		# pause game
		Game.pauseAnim(true)
		mouseMode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
	else:
		# resume game
		if mouseMode: Input.mouse_mode = mouseMode
		get_tree().paused = false
		Game.pauseAnim(false)
	waitTimer.start()

## exit a paused game savely
func saveExit() -> void:
	get_tree().paused = false
	Game.gameEnd(true)	# abort the game

func _on_button_continue_pressed() -> void:
	pause(false)
func _on_button_settings_pressed() -> void:
	settings_button.emit(self)
	# we return after (so we dont need to saveExit()
func _on_button_menu_pressed() -> void:
	menu_button.emit(self)
	saveExit()


func _on_wait_timer_timeout() -> void:
	justPaused = false
