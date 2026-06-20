extends RigidBody2D

@export var anker : Node2D			## where the object is attached to

@export var rope_length := 80.0		## when the rope starts pulling
@export var rope_strength := 70.0	## how strong the rope pulls if streched
@export var rope_max := 400.0		## max distance before clipping position (disable: -1)
@export var max_f := 60				## when to start limiting the force

var potents := 2	# increase force with distance**potents

func _physics_process(_delta: float) -> void:
	# connect self to anker
	var deltaX = 0.016	# internet said dont use delta, so we do this now
	var diff = anker.global_position - self.global_position
	
	# limit the max amount of rope length
	if rope_max > 0 and diff.length() > rope_max:
		#global_position = anker.global_position - diff.normalized() * rope_max	#deprecated, does not catch collisions
		var target = anker.global_position - diff.normalized() * rope_max
		# raycast to catch colisions when teleporting the obj
		# (does not fully work, try shape casting?)
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(self.global_position, target)
		query.exclude = [self, anker]
		var result = space_state.intersect_ray(query)
		if result:
			# do nothing on colision
			#print("Collision: ", result.position)
			pass
		else:
			global_position = target
	
	# usual rope pull
	if diff.length() > rope_length:
		var f = diff.normalized() * (diff.length() - rope_length)**potents * rope_strength
		# limit to high forces
		if f.length()*deltaX > diff.length()*max_f:
			#print("Limiting ", f*deltaX)
			f = diff*max_f**potents
		self.apply_central_force(
			f * deltaX
		)
		#print(f*delta)
	#print(diff.length())
	pass
