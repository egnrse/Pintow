## simple meele enemy
extends "res://Enemies/_EnemyClass.gd"

@onready var player := get_node("/root/Game/Player")
#@onready var game := get_node("/root/Game/")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.init()
	self.initAudio()
	self.initAnim()
	#var pitchRange = 0.4
	#$AudioStreamPlayer2D.pitch_scale = randf_range(1-pitchRange,1+pitchRange)

func _physics_process(delta: float) -> void:
	if self.alive:
		move(delta)
	else:
		$AudioStreamPlayer2D.stop()

## moves [member self] to [member player] (called each physics_process)
func move(_delta: float) -> void:
	var direction = global_position.direction_to(self.player.global_position)
	velocity = direction * self.speed
	move_and_slide()
