extends CharacterBody2D

signal playerDeath	## called when the player dies

@export var DAMAGE_RATE := 12	## how fast to get damaged
@export var max_health := 10.	## max health
var health := max_health		## current health

@onready var healthBar = $HealthBar
@onready var healthBarTimer = $HealthBar/Timer


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	health = max_health
	healthBar.max_value = max_health
	healthBar.value = health
	healthShow()

func _physics_process(delta: float) -> void:
	# follow mouse
	var mouse := get_global_mouse_position()
	var motion := mouse - global_position
	move_and_collide(motion)
	
	# get damaged by enemies
	var enemies = %HurtArea.get_overlapping_bodies()
	if enemies.size() > 0:
		damage(DAMAGE_RATE * enemies.size() * delta)

## call to damage [member self] (decreases [member health])
func damage(amount: float = 1) -> void:
	self.health -=amount
	healthShow()
	
	if health <= 0:
		playerDeath.emit()

func healthShow() -> void:
	healthBar.visible = true
	healthBar.value = health
	healthBarTimer.start()

# hide the healthbar if nothing changes on it
func _on_timer_timeout() -> void:
	healthBar.visible = false
