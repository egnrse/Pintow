## WaveSpawning
##
## connect [signal waveSpawn] for enemy spawning, start autospawning waves with [method start]
class_name WaveSpawning extends Node2D


signal autoWaveFinish()				## emit when the last wave finishes (when auto spawning)
signal waveFinish(wave: WaveData)	## emit when a wave has finished
signal waveSpawn(type: String)		## emit when the waveSpawner wants to spawn an enemy ('type' is the resolved scene path string)


@export var spawnWaves: Array[WaveData] = []	## enemy waves spawning

# node
@onready var waveTimer: Timer = $waveTimer	## timer for spawning waves/spawns

# wave auto spawn
var waveAutoSpawning := false		## if to automatically spawn all waves (started with startWaveSpawning()
var currentWaveIdx := -1			## idx of current wave
# wave spawn
var currentWave: WaveData			## current wave instance
var currentSpawnIdx := -1			## idx of current spawn (in the current wave)

var enemyCache : Dictionary[String,String] = {}  ## cache (short_name -> scene path)
const timerMultiply := 0.1			## convertion multiplier for [SpawnV1.time] to time_sec

func _ready() -> void:
	if waveSpawn.get_connections().size() == 0:
		push_warning("signal 'waveSpawn' is not connected")

## begin spawning enemies after a WaveData array (automatically)
func start(startWave:=0) -> void:
	assert(startWave > -1 and startWave < spawnWaves.size(), "invalid startWave: %s" % startWave)
	waveAutoSpawning = true
	currentWaveIdx = startWave
	spawnWave(spawnWaves[currentWaveIdx])

## start the next wave (automatically)
func waveAutoSpawning_next(_wave: WaveData) -> void:
	if waveAutoSpawning:
		currentWaveIdx += 1
		if spawnWaves.size() <= currentWaveIdx:
			currentSpawnIdx = -1
			waveAutoSpawning = false
			autoWaveFinish.emit()
		else:
			spawnWave(spawnWaves[currentWaveIdx])


## spawn a wave
func spawnWave(wave:WaveData) -> void:
	currentWave = wave
	currentSpawnIdx = 0
	if currentWave.spawns[currentSpawnIdx].time > 0:
		waveTimer.start(currentWave.spawns[currentSpawnIdx].time *timerMultiply)
	else:
		# spawn the first spawn directly if time is 0
		spawnWaveTimer_timeout()

## spawn a SpawnV1 (and start the next timeout)
func spawnWaveTimer_timeout() -> void:
	var spawnInstance = currentWave.spawns[currentSpawnIdx]
	for i in spawnInstance.amount:
		for e in spawnInstance.get_types():
			var resolvedE := resolveEnemy(e)
			waveSpawn.emit(resolvedE) # spawn enemies
			#print(resolvedE)	#dev
	# prepare next spawn
	currentSpawnIdx += 1
	if currentWave.spawns.size() <= currentSpawnIdx:
		currentSpawnIdx = -1
		waveTimer.stop()
		waveAutoSpawning_next(currentWave)
		waveFinish.emit(currentWave)
	elif currentWave.spawns[currentSpawnIdx].time == 0:
		# spawn the next spawn directly if time is 0
		spawnWaveTimer_timeout()
	else:
		# start timer
		waveTimer.start(currentWave.spawns[currentSpawnIdx].time *timerMultiply)

## resolve enemy shortnames to scene paths (using [member enemyCache])
func resolveEnemy(input:String) -> String:
	# try cache first
	if enemyCache.has(input):
		return enemyCache[input]
	
	const enemyPath := "res://Enemies"
	var path := ""
	if input.begins_with(enemyPath):
		path = input
	elif input.begins_with("enemy_"):
		path = "%s/%s.tscn" % [enemyPath,input]
	else:
		path = "%s/enemy_%s.tscn" % [enemyPath,input]
	if not ResourceLoader.exists(path, "PackedScene"):
		push_error("Invalid enemy path: %s" % path)
	enemyCache[input] = path
	return path
