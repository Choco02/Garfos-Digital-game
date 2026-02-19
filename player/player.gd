extends CharacterBody3D

const SPEED = 5.0
const DASH_SPEED = 10.0 # Arth: Adicionada constante para a força do dash
const DASH_DURATION = 0.25 # Arth: Adicionada constante para a duração do dash

enum State {
	IDLE,
	ATTACK,
	WALK,
	DASH # Arth: Adicionado estado de DASH para a máquina de estados
}

var state: State = State.IDLE:
	set(value):
		if state == value: return
		#print_debug("%s mudou de estado %s para %s" % [name, State.find_key(state), State.find_key(value)])
		state = value

var dash_timer := 0.0 # Arth: Variável para controlar o tempo do dash
var dash_dir := Vector3.ZERO # Arth: Direção que será travada durante o dash
var last_look_dir := Vector3.BACK # Arth: Memória da última das 4 direções cardinais

func _physics_process(delta: float) -> void:
	# Arth: Se o dash estiver ativo, executa o movimento e ignora o restante da função
	if dash_timer > 0:
		dash_timer -= delta
		velocity.x = dash_dir.x * DASH_SPEED
		velocity.z = dash_dir.z * DASH_SPEED
		velocity.y = 0 
		move_and_slide()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# TODO - separar a captura de input em um script separado
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Arth: Lógica para identificar a última das 4 direções cardinais (ignorando diagonais)
	if direction != Vector3.ZERO:
		if abs(direction.x) > abs(direction.z):
			last_look_dir = Vector3(sign(direction.x), 0, 0)
		else:
			last_look_dir = Vector3(0, 0, sign(direction.z))

	# Arth: Alterado de == 1.0 para > 0 e < 0 para aceitar valores analógicos do joystick
	if direction.x < 0:
		$Sprite3D.flip_h = false
	elif direction.x > 0:
		$Sprite3D.flip_h = true
	
	# Arth: Verifica se Espaço ou Botão A (Joypad 0) foi pressionado para iniciar o dash
	if Input.is_action_just_pressed("ui_select") or Input.is_joy_button_pressed(0, JOY_BUTTON_A):
		dash_timer = DASH_DURATION
		dash_dir = last_look_dir
		state = State.DASH

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
