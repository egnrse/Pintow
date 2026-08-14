extends LevelBase

@onready var enemyContainer := %EnemyContainer
@onready var spawnTimer := %enemySpawnTimer

func start(resetState := true) -> bool:
	if running:
		push_warning("start(): Level is already running")
	if resetState: reset()
	music.playing = true
	
	# enemy spawns
	spawnTimer.start()
	for n in 4:
		spawn_enemy()
	
	running = true
	get_tree().paused = false
	return true

func reset() -> void:
	%enemySpawnTimer.wait_time = 4.
	# free all enemies in EnemyContainer
	for e in enemyContainer.get_children():
		if e is EnemyBase:	# savety check
			# disable collisions / make invisible (just in case the queue_free takes a bit)
			e.collision_layer = 0
			e.visible = false
			e.queue_free()

## spawn an enemy somewhere on the SpawnLine
func spawn_enemy(type="res://Enemies/enemy_melee.tscn") -> void:
	var randValue := randf()
	#print("enemy spawn: ", type, ", ", randValue)
	%PathFollow2D.progress_ratio = randValue
	var enemy = spawn(type, %PathFollow2D.global_position)
	enemy.death.connect(_on_enemy_death)
	enemyContainer.add_child(enemy)

#region SIGNALS
## called on enemy death
func _on_enemy_death(entity, _position) -> void:
	updateScore_onDeath(entity)

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
#endregion SIGNALS
