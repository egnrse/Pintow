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
@onready var UI := %UI		## manages all menu UI
@onready var pauseScreen := %PauseScreen
@onready var gameOverScreen := %GameOverScreen

# enemies
@onready var spawnTimer := %enemySpawnTimer
@onready var enemyContainer := %EnemyContainer

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
@export var dev_disableEnemySpawn := false	## disable all enemy spawns
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
		get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.running:
		#if Input.is_action_just_pressed("pause"):
		#	pauseScreen.pause(true)
		if dev_cheatKeys:
			dev_cheats()
	#print("AudioPeak: ", max(AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Master"), 0), AudioServer.get_bus_peak_volume_right_db(AudioServer.get_bus_index("Master"), 0)))
	pass

func _unhandled_input(event: InputEvent) -> void:
	if self.running:
		if event.is_action_pressed("pause"):
			pauseScreen.pause(true)
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
		%enemySpawnTimer.wait_time = 4.
		AudioServer.set_bus_effect_enabled(musicAudioBus, musicReverbIdx, false)
		music.playing = true
		# free all enemies in EnemyContainer
		for e in enemyContainer.get_children():	
			if e is EnemyBase:	# savety check
				# disable collisions / make invisible (just in case the queue_free takes a bit)
				e.collision_layer = 0
				e.visible = false
				e.queue_free()
		player.reset()
		rot.reset()
	
	# prepare
	updateAnimate()
	updateScore(0)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	# enemy spawns
	spawnTimer.start()
	for n in 4:
		spawn_enemy()
	
	get_tree().paused = false
	running = true
	return true

## called when the game ends (abort: just stop the game, without endscreen)
func gameEnd(abort:=false) -> void:
	running = false
	# stop music
	AudioServer.set_bus_effect_enabled(musicAudioBus, musicReverbIdx, true)
	music.playing = false
	# reset pause animations (in case we come from a pause)
	pauseAnim(false)
	if not abort:
		# show gameOverScreen
		gameOverScreen.death(score)
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	startable = true

## called right before/after a pause
func pauseAnim(start:bool = true) -> void:
	# menus
	#%Settings_PanelContainer.visible = start
	
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

## @deprecated game restart
func reset_scene():
	push_warning("reset_scene(): is deprecated, use gameEnd()/gameStart()")
	get_tree().reload_current_scene()

## spawn an enemy somewhere on the SpawnLine
func spawn_enemy(type="res://Enemies/enemy_melee.tscn") -> void:
	if dev_disableEnemySpawn:
		# enemy spawn kill switch
		push_warning("dev_disableEnemySpawn: active")
		return
	var randValue := randf()
	#print("enemy spawn: ", type, ", ", randValue)
	var enemy = load(type).instantiate()
	%PathFollow2D.progress_ratio = randValue
	enemy.global_position = %PathFollow2D.global_position
	enemy.death.connect(_on_enemy_death)
	if 'animate' in enemy: enemy.animate = animate
	enemyContainer.add_child(enemy)

## update the score visuals
func updateScore(newScore:int=score) -> void:
	score = newScore
	scoreUI.text = str(score)
#endregion HELPER

#region DEV
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

#region SIGNALS
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

## called by enemySpawnTimer
func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

## called by spawnTimeTimer
func _on_spawn_time_timer_timeout() -> void:
	# make the spawning of enemies faster
	var multi = 1.
	if spawnTimer.get_wait_time() > 1.0:
		multi = 0.8
	if spawnTimer.get_wait_time() > 0.6:
		multi = 0.9
	else:
		multi = 0.96
	spawnTimer.set_wait_time(spawnTimer.get_wait_time() * multi)
	#print(spawnTimer.get_wait_time())

func _on_player_player_death() -> void:
	anim_death()
	gameEnd()
#endregion SIGNALS


#region ANIMATE
## update the animate value of some children
func updateAnimate() -> void:
	player.animate = animate
	rot.animate = animate
	player.animateUpdate()
	rot.animateUpdate()
	for e in enemyContainer.get_children():
		if "animate" in e:
			e.animate = animate

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
