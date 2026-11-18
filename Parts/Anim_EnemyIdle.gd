## animates the position of itself with a random jitter (synced to _on_frame_changed)
extends Node2D

@export_category("Movement Animation")
@export var enableAnimation := true	## if to show the animation
@export var movementRange := 300	## how much the animation can move (multiplier of the max distance)
@export_range(0,0.5) var animationJitter := 0.01	## how quickly values can change (lerp amount)

var offset := Vector2.ZERO			## store the offset for the position

func _ready() -> void:
	# test if _on_frame_changed is connected
	var testConnected := false
	for c in get_incoming_connections():
		if c["callable"].get_method() == "_on_frame_changed":
			testConnected = true
	if not testConnected: push_warning("'_on_frame_changed()' is not connected, movement will not show")

func _on_frame_changed() -> void:
	# update the position
	if enableAnimation:
		var distanceOffset := (randf() -0.5)*movementRange
		var directionOffset := randf()-0.5
		var pos := Vector2(sin(directionOffset), cos(directionOffset))*distanceOffset
		offset = lerp(offset, pos, animationJitter)
		position = offset
