## a healthbar for its parent, call [member update()] on value changes
## (expects [member parent.health], [member parent.max_health], optional: [member parent.animate])
extends ProgressBar

@export var parent: Node2D		## the parent the healthbar is for (expects [member parent.health], [member parent.max_health] to exist)
@export var barColor := Color("777")	## the color of the healthbar
@export_group("more")
@export var autohideTime := 5.	## after how many seconds to hide the healthbar again
@export var animSpeed := 0.08	## how long the value change animation takes

var animTween: Tween


func _ready() -> void:
	var sb = StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)
	sb.bg_color = barColor
	
	$Timer.wait_time = autohideTime
	self.max_value = parent.max_health
	self.value = parent.health

## call this to update and show the bar (automatically fetches [member parent.health])
func update() -> void:
	if "animate" in parent and not parent.animate: 
		self.value = parent.health
	else:
		anim_update()
	self.visible = true
	$Timer.start()

## update the healthbar with an animation for value changes (speed: speed of the animation)
func anim_update(speed:float=animSpeed) -> void:
	if animTween: animTween.kill()
	animTween = create_tween()
	animTween.set_trans(Tween.TRANS_EXPO)
	animTween.set_ease(Tween.EASE_OUT)
	animTween.tween_property(self, "value", parent.health, speed)
	await animTween.finished

## hide the healthbar if nothing changes on it
func _on_timer_timeout() -> void:
	self.visible = false
