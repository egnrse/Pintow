## base class for levels
## 

@abstract
class_name LevelBase
extends Node2D

signal score(update:int)	## called on changes to the score

var running := false
var animate := true

# nodes
@export var music: AudioStreamPlayer ## the music player

func _ready() -> void:
	get_tree().paused = true

@abstract
## start the level (resetState: if the gamestate should be reset)
func start(resetState := true) -> bool

## called when the level should end (abort: just stop the level)
func end(_abort := false) -> void:
	running = false
	# stop music
	if music:
		music.playing = false
	get_tree().paused = true

@abstract
## reset the level state
func reset() -> void

## update animations (react to a change in the [member animate])
func animateUpdate() -> void:
	pass

## spawns unit of a certain type at position pos and returns it
func spawn(type:String, pos:Vector2) -> Node:
	var new = load(type).instantiate()
	new.global_position = pos
	if "animate" in new:
		new.animate = animate
	return new

## update the score depending on the entity given
func updateScore_onDeath(entity) -> void:
	var change = 0 # the score change
	if 'score' in entity:
		change += entity.score
	elif 'max_health' in entity:
		change += entity.max_health
	else:
		push_warning("_on_enemy_death: entity has no 'score' or 'max_health'")
		change += 1
	score.emit(change)
