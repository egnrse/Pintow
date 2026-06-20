extends CharacterBody2D


#const SPEED = 1000.0
@export var SPEED_MULTI := 100

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	pass

func _physics_process(_delta: float) -> void:
	# follow mouse
	var mouse := get_global_mouse_position()
	var motion := mouse - global_position
	move_and_collide(motion)
	
	
