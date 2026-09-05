## resource for enemy wave spawning
##
## 

extends Resource
class_name WaveData

@export var name: String = "Wave"		## name of the spawn wave
@export var spawns: Array[SpawnV1] = []	## the spawn instances
@export var disabled: bool = false		## if the wave is active

func _init(nameI:=name, spawnsI:=spawns) -> void:
	name=nameI
	spawns=spawnsI
