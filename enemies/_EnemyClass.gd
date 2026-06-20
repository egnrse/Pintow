## base class for enemies
## (handles health/damage/score/death)
class_name EnemyBase
extends CharacterBody2D

@onready var healthBar = get_node_or_null("HealthBar") ## the healthbar of [member self] (fails silently if none exist)

signal damaged(entity, amount:int)		## emited when [member self] is damaged
signal death(entity,position:Vector2)	## emited when [member self] dies

@export var max_health := 2			## max health of [member self]
@export var speed := 100			## movement speed of [member self]
@export var score := max_health		## score player gets on kill of [member self] (default: [member max_health])

@export_subgroup("more")
@export var INVUL_TIME := 0.1;		## invulnerability time between damage instances (see [member iTimer])

var health := max_health			## current health
var alive := true					## if [member self] is currently alive
var justDamaged := false			## [member self] can only take damage if false (is reset by [member iTimer])
var iTimer := Timer.new()			## invulnerability timer, gets started after taking damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.init()

## init some basic things
func init() -> void:
	# health
	health = max_health
	alive = true
	if healthBar: healthBar.update()
	# timer
	add_child(iTimer)
	iTimer.wait_time = INVUL_TIME
	iTimer.one_shot = true
	iTimer.timeout.connect(_on_iTimer_timeout)

## call to damage [member self] (decreases [member health])
func damage(amount: int = 1) -> void:
	# wait for the damage pause to run out
	if justDamaged:
		#print("justDamaged")
		return
	else:
		justDamaged = true # set a new damage pause
		iTimer.start()
	
	#print("damage: ", amount)	#dev
	self.health -=amount
	damaged.emit(self, amount)
	if healthBar: healthBar.update()
	
	if health <= 0:
		self.die()

## called when [member health] <= 0
func die() -> void:
	death.emit(self, self.global_position)
	alive = false
	queue_free()

## called when [member iTimer] runs our
func _on_iTimer_timeout() -> void:
	justDamaged = false
