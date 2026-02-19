extends CharacterBody3D


const SPEED = 5.0

enum State {
	IDLE,
	ATTACK,
	WALK,
}


var state: State = State.IDLE:
	set(value):
		if state == value: return
		#print_debug("%s mudou de estado %s para %s" % [name, State.find_key(state), State.find_key(value)])
		state = value


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# TODO - separar a captura de input em um script separado
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction.x == -1.0:
		$Sprite3D.flip_h = false
	elif direction.x == 1.0:
		$Sprite3D.flip_h = true
	if direction:
		state = State.WALK
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		state = State.IDLE
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if Input.is_action_pressed("attack"):
		# TODO: implementar cooldown no ataque depois
		state = State.ATTACK

	move_and_slide()
