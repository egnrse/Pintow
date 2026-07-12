## UI script, which ignores pause
extends CanvasLayer

@onready var Game = get_parent()

var mouseMode = null	## remember the previous mouse mode


func _process(_delta):
	# (re)start game
	if Input.is_action_pressed("continue") and Game.startable:
		if $Settings_PanelContainer.get_global_rect().has_point(get_viewport().get_mouse_position()):
			return # clicked inside settings panel, ignore
		get_tree().paused = false
		Game.pause(false)
		Game.gameStart()
	
	# (un)pause
	if not Game.startable and Game.running:
		var justPaused = false
		if Input.is_action_just_pressed("pause") and get_tree().paused == false:
			Game.pause(true)
			mouseMode = Input.mouse_mode
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
			justPaused = true
		if Input.is_action_just_pressed("continue") and not justPaused and get_tree().paused == true:
			if $Settings_PanelContainer.get_global_rect().has_point(get_viewport().get_mouse_position()):
				return # clicked inside settings panel, ignore
			if mouseMode: Input.mouse_mode = mouseMode
			get_tree().paused = false
			Game.pause(false)
