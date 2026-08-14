## main game script
extends Node2D

# game flow
var startable := true	## if the game can be started
var running := false	## if the game is running right now
var score := 0			## increase score on enemy death

# general nodes
@onready var rot := get_node("Rotateing")
@onready var player := get_node("Player")
@onready var camera := $Camera2D
@onready var scoreUI := %Score
@onready var pauseContainer := %PauseButtonContainer
@onready var UI := %UI		## manages all menu UI
@onready var pauseScreen := %PauseScreen
@onready var gameOverScreen := %GameOverScreen
@onready var currentLevel := %Level

# audio
var musicReverbIdx := 0	## effect index in the music bus
var musicLPIdx := 1
var musicHPIdx := 2
@onready var music := $Music	## game music AudioStreamPlayer
@onready var musicAudioBus := AudioServer.get_bus_index("Music")	## index of the music bus itself
@onready var sfxAudioBus := AudioServer.get_bus_index("SFX")
@onready var musicReverb := AudioServer.get_bus_effect(musicAudioBus, musicReverbIdx) as AudioEffectReverb	## effect instance
@onready var musicLP := AudioServer.get_bus_effect(musicAudioBus, musicLPIdx) as AudioEffectFilter
@onready var musicHP := AudioServer.get_bus_effect(musicAudioBus, musicHPIdx) as AudioEffectFilter

# animation
@export var animate := true		## if animations should be shown
var animTween: Tween			## tween obj for general animations
var pauseTween: Tween			## tween obj for game pauses

# extra
@export_group("dev cheats", "dev_")			## some only apply on game start
#@export var dev_disableEnemySpawn := false	## disable all enemy spawns
@export var dev_beefyPlayer := false		## give [member player] infinite health
@export var dev_ignoreReset := false		## dont reset things on game start
@export var dev_cheatKeys := false			## activate cheats shortcuts (see [method dev_cheats])
@export var dev_skipMenu := false			## directly start the game (dont show the main menu)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if dev_beefyPlayer:
		push_warning("dev_beefyPlayer: active")
		player.max_health = INF
	
	if dev_skipMenu:
		gameStart(true)
	else:
		UI.showMainMenu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.running:
		if dev_cheatKeys:
			dev_cheats()
	#print("AudioPeak: ", max(AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Master"), 0), AudioServer.get_bus_peak_volume_right_db(AudioServer.get_bus_index("Master"), 0)))
	pass

func _unhandled_input(event: InputEvent) -> void:
	if self.running:
		if event.is_action_pressed("pause"):
			pauseGame()
			get_viewport().set_input_as_handled()

#region HELPER
## reset and start the game (force: force a game start even if its in a bad state)
func gameStart(force:bool = false) -> bool:
	if not startable or running:
		push_warning("gameStart(): Game is not startable or is already running")
		if not force: return false
	startable = false
	
	# reset
	if dev_ignoreReset:
		push_warning("dev_ignoreReset: active")
	else:
		AudioServer.set_bus_effect_enabled(musicAudioBus, musicReverbIdx, false)
		player.reset()
		rot.reset()
	
	# prepare
	updateAnimate()
	updateScore(0)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	get_tree().paused = false
	running = currentLevel.start(not dev_ignoreReset)
	return running

## called when the game ends (abort: just stop the game, without endscreen)
func gameEnd(abort:=false) -> void:
	currentLevel.end(abort)
	running = false
	# stop music
	AudioServer.set_bus_effect_enabled(musicAudioBus, musicReverbIdx, true)
	# reset pause animations (in case we come from a pause)
	pauseAnim(false)
	if not abort:
		# show gameOverScreen
		gameOverScreen.death(score)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	startable = true

## this is just a helper, DONT rely on it being called!
func pauseGame() -> void:
	pauseScreen.pause(true)

## called right before/after a pause
func pauseAnim(start:bool = true) -> void:
	# audio
	if start:
		AudioServer.set_bus_effect_enabled(musicAudioBus, musicHPIdx, true)
		AudioServer.set_bus_effect_enabled(musicAudioBus, musicLPIdx, true)
		musicHP.cutoff_hz = 350
		musicLP.cutoff_hz = 2000	
	else:
		if pauseTween:	# dont double tween
			pauseTween.kill()
		pauseTween = create_tween()
		pauseTween.set_trans(Tween.TRANS_SINE)
		pauseTween.set_ease(Tween.EASE_OUT)
		pauseTween.parallel().tween_property(musicHP, "cutoff_hz", 20.0, 0.2)
		pauseTween.parallel().tween_property(musicLP, "cutoff_hz", 20500.0, 0.4)
		pauseTween.finished.connect(func():
			AudioServer.set_bus_effect_enabled(musicAudioBus, musicHPIdx, false)
			AudioServer.set_bus_effect_enabled(musicAudioBus, musicLPIdx, false)
		)

func loadLevel() -> bool:
	# TODO
	# - instanciate
	# - set currentLevel
	# - connect Score
	return false

## @deprecated: game restart (use [method gameEnd]/[method gameStart] instead)
func reset_scene():
	push_warning("reset_scene(): is deprecated, use gameEnd()/gameStart()")
	get_tree().reload_current_scene()

## update the score visuals
func updateScore(newScore:int=score) -> void:
	score = newScore
	scoreUI.text = str(score)
#endregion HELPER

#region DEV (development helpers)
## enable some cheats with keyboard shortcuts
## L_CTR + ?: D: damage, H: health 
func dev_cheats() -> void:
	if not Input.is_action_pressed("dev_cheats"): return
	if Input.is_key_pressed(KEY_D):
		print("dev_cheats: damage player")
		player.damage(player.max_health/100)
	if Input.is_key_pressed(KEY_H):
		print("dev_cheats: player max_health")
		player.health = player.max_health
		player.damage(0, true)
#endregion DEV

#region SIGNALS (gameplay related)
## called on score updates by the level
func _on_level_score(update: int) -> void:
	updateScore(score + update)

## called on enemy death
func _on_enemy_death(entity, _position) -> void:
	if 'score' in entity:
		score += entity.score
	elif 'max_health' in entity:
		score += entity.max_health
	else:
		push_warning("_on_enemy_death: entity has no 'score' or 'max_health'")
		score += 1
	scoreUI.text = str(score)

func _on_player_player_death() -> void:
	anim_death()
	gameEnd()

## pause button got pressed
func _on_pause_button_container_pause() -> void:
	pauseGame()
#endregion SIGNALS

#region SETTINGS (setting signals/functions)
func _on_settings_menu_animate(toggle: bool) -> void:
	self.animate = toggle
	updateAnimate()
func _on_settings_menu_pause_option(option: int) -> void:
	pauseContainer.setPauseOption(option)
#endregion SETTINGS

#region ANIMATE (handles animations)
## update the animate value of some children
func updateAnimate() -> void:
	player.animate = animate
	rot.animate = animate
	currentLevel.animate = animate
	player.animateUpdate()
	rot.animateUpdate()
	currentLevel.animateUpdate()

func anim_death() -> void:
	if animTween:
		animTween.kill()
	animTween = create_tween()
	animTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	animTween.set_trans(Tween.TRANS_EXPO)
	animTween.set_ease(Tween.EASE_OUT)
	var o = camera.zoom
	var val = o + Vector2(0.03, 0.03)
	animTween.tween_property(camera, "zoom", val, 0.01)
	animTween.tween_property(camera, "zoom", o, 0.1)
	pass
#endregion ANIMATE
