extends CanvasLayer

@onready var Game = get_parent()

func _process(_delta):
	# (re)start game
	if Input.is_action_pressed("continue") and Game.startable:
		get_tree().paused = false
		Game.reset_scene()
	
	# (un)pause
	if not Game.startable:
		var justPaused = false
		if Input.is_action_just_pressed("pause") and get_tree().paused == false:
			%PauseMenu.visible = true
			get_tree().paused = true
			justPaused = true
		if Input.is_action_just_pressed("continue") and not justPaused and get_tree().paused == true:
			%PauseMenu.visible = false
			get_tree().paused = false
