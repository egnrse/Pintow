## resource for a spawning instance
##
## used by [class WaveData]
extends Resource
class_name SpawnV1


@export var type: String=""		## what to spawn (one or more enemies, split by ',')
@export var time: int=10		## spawn time after previous entry (in deci-seconds)
@export var amount: int=1		## how many instances of type to spawn

func _init(typeI:String=type,timeI:int=time,amountI:=amount):
	# checks
	type=typeI
	time=timeI
	amount=amountI
	checks()

## some assertions if the data looks fine
func checks() -> bool:
	assert(time > -1, "'time' must be non negative (%s)" % time)
	assert(time < INF, "'time' must smaller than INF (%s)" % time)
	assert(get_types() is Array, "'type' is invalid (%s)" % type)
	assert(amount > -1, "'amount' must be non negative (%s)" % amount)
	return true

## returns an array of types (from [member type])
func get_types(t:=self.type) -> Array[String]:
	if t.contains(","):
		var arr := t.split(",")
		for i in arr.size():
			arr[i] = arr[i].strip_edges()
		return arr
	else: return [t]
