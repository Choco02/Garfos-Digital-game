extends CharacterBody3D

const SPEED = 5.0
const DASH_SPEED = 10.0 # Arth: Adicionada constante para a força do dash
const DASH_DURATION = 0.25 # Arth: Adicionada constante para a duração do dash
const DASH_COOLDOWN = 0.8 # Arth: Adicionada constante para o tempo de recarga (delay) entre os dashs
const PUSH_FORCE = 10 # Arth: Adicionada constante para a força do empurrão na caixa

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
var dash_cooldown_timer := 0.0 # Arth: Variável para controlar o tempo de espera até o próximo dash
var dash_dir := Vector3.ZERO # Arth: Direção que será travada durante o dash
var last_look_dir := Vector3.BACK # Arth: Memória da última das 4 direções cardinais

func _physics_process(delta: float) -> void:
	# Arth: Diminui o tempo de recarga do dash a cada frame
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Arth: Se o dash estiver ativo, executa o movimento e ignora o restante da função
	if dash_timer > 0:
		dash_timer -= delta
		velocity.x = dash_dir.x * DASH_SPEED
		velocity.z = dash_dir.z * DASH_SPEED
		velocity.y = 0 
		move_and_slide()
		
		# Arth: Array para evitar empurrar a mesma caixa várias vezes no mesmo frame
		var pushed_boxes_dash = [] 
		
		# Arth: Adicionado loop de colisão durante o dash para empurrar objetos RigidBody3D
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Arth: Verifica se é RigidBody3D e se AINDA NÃO foi empurrado neste frame
			if collider is RigidBody3D and not collider in pushed_boxes_dash:
				pushed_boxes_dash.append(collider) # Arth: Marca que já empurrou essa caixa agora
				
				# Arth: Zerando o eixo Y para não empurrar a caixa para baixo/cima
				var push_dir = -collision.get_normal()
				push_dir.y = 0
				push_dir = push_dir.normalized()
				# Arth: Multiplicado por delta para estabilizar a física durante o dash
				collider.apply_central_impulse(push_dir * (PUSH_FORCE * 2.0) * delta * 10.0)
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
	# Arth: Adicionada a condição "and dash_cooldown_timer <= 0" para impedir o bug de voar/spam de dash
	if (Input.is_action_just_pressed("ui_select") or Input.is_joy_button_pressed(0, JOY_BUTTON_A)) and dash_cooldown_timer <= 0:
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN # Arth: Reseta o temporizador de recarga do dash
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
	
	# Arth: Array para rastrear as caixas já empurradas no estado de Walk/Idle e evitar o bug da caixa leve
	var pushed_boxes = []
	
	# Arth: Adicionado loop após o move_and_slide comum para empurrar caixas (RigidBody3D)
	# Arth: O uso do -collision.get_normal() garante que o empurrão seja na direção oposta ao impacto, evitando que o player "agarre" na caixa
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Arth: Condição atualizada para evitar múltiplos empurrões na mesma caixa no mesmo frame
		if collider is RigidBody3D and not collider in pushed_boxes:
			pushed_boxes.append(collider) # Arth: Salva a caixa na lista das já processadas
			
			# Arth: Zerando o eixo Y do impacto para a caixa não subir/descer e prender o jogador
			var push_dir = -collision.get_normal()
			push_dir.y = 0
			push_dir = push_dir.normalized()
			
			# Arth: Só empurra se o jogador estiver realmente andando (direction) na direção da caixa (dot > 0)
			if direction != Vector3.ZERO and push_dir.dot(direction) > 0:
				# Arth: Uso do delta para converter um pulso instantâneo em uma força contínua e suave
				collider.apply_central_impulse(push_dir * PUSH_FORCE * delta * 10.0)
