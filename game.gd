extends Node2D

#@onready var rot := get_node("Rotateing")
#@onready var player := get_node("Player")

# game flow
var startable = true
var score = 0			## increase score on enemy death

# enemies
@onready var spawnTimer := %enemySpawnTimer
@onready var enemies := $Enemies


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	startable = false
	# enemy spawns
	spawnTimer.start()
	for n in 4:
		spawn_enemy()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func reset_scene():
	get_tree().reload_current_scene()

## spawn 1 enemy somewhere on the SpawnLine
func spawn_enemy(type="res://enemies/enemy_melee.tscn") -> void:
	var randValue := randf()
	#print("enemy spawn: ", type, ", ", randValue)
	var enemy = load(type).instantiate()
	%PathFollow2D.progress_ratio = randValue
	enemy.global_position = %PathFollow2D.global_position
	enemy.death.connect(_on_enemy_death)
	enemies.add_child(enemy)

func _on_enemy_death(entity, _position) -> void:
	if 'score' in entity:
		score += entity.score
	elif 'max_health' in entity:
		score += entity.max_health
	else:
		push_warning("_on_enemy_death: entity has no 'score' or 'max_health'")
		score += 1

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
	%Score.text = str(score)
	%GameOver.visible = true
	get_tree().paused = true
	%RestartDelay.start()

func _on_restart_delay_timeout() -> void:
	startable = true
