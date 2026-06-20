extends Node2D

@onready var rot := get_node("Rotateing")
@onready var player := get_node("Player")

# game flow
var startable = true

# enemies
@onready var spawnTimer := %enemySpawnTimer
@onready var enemies := $Enemies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startable = false
	for n in 5:
		spawn_enemy()
	spawnTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func reset_scene():
	get_tree().reload_current_scene()

## spawn 1 enemy somewhere on the SpawnLine
func spawn_enemy(type="res://enemies/enemy_meele.tscn") -> void:
	#print("enemy spawn: ", type)
	var enemy = load(type).instantiate()
	%PathFollow2D.progress_ratio = randf()
	enemy.global_position = %PathFollow2D.global_position
	enemies.add_child(enemy)


func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()


func _on_player_player_death() -> void:
	%GameOver.visible = true
	get_tree().paused = true
	%RestartDelay.start()


func _on_restart_delay_timeout() -> void:
	startable = true
