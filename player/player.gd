extends CharacterBody3D


const SPEED = 5.0

enum State {
	NONE,
	IDLE,
	USING_ITEM,
	TALKING,
	WALK,
}

enum AnimationActive {
	NONE,
	UP_MOVE,
	DOWN_MOVE,
	SIDE_MOVE,
	STAMP_USE,
}

var state: State = State.NONE:
	set(value):
		if state == value: return
		#print_debug("%s mudou de estado %s para %s" % [name, State.find_key(state), State.find_key(value)])
		state = value

var itens: Array[Item]

var can_interact := false
var target_interactable:Node3D = null

@onready var itens_HUD: ItensHUD = $"../Itens"

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var frente_sprite_3D: Sprite3D = $Sprite3D
var current_animation: AnimationActive

@onready var carimbados: Node3D = $"../Carimbados"
@onready var canvas_dialogue: CanvasDialogue = $"../CanvasDialogue"

# TODO: Talvez mudar essa forma de ligar o vento
var on_wind := false

func _ready() -> void:
	itens.resize(7)
	itens[ItensHUD.ItemEnum.TESOURA] = null
	itens[ItensHUD.ItemEnum.CARIMBO_TELEPORTE] = null
	itens[ItensHUD.ItemEnum.CARIMBO_VENTO] = WindStamp.new()
	itens[ItensHUD.ItemEnum.CARIMBO_PSIQUICO] = null

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if (not is_on_floor()) or on_wind:
		velocity += get_gravity() * delta
		
	# Decide qual state esta agora
	var old_state: State = state
	match state:
		State.IDLE:
			if Input.is_action_just_pressed("attack"):
				state = State.USING_ITEM
			elif can_interact and Input.is_action_just_pressed("interact"):
				state = State.TALKING
			elif Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
				state = State.WALK
		State.USING_ITEM:
			if !animated_sprite_3d.is_playing():
				state = State.IDLE
			pass
		State.TALKING:
			if !canvas_dialogue.running:
				state = State.IDLE
			pass
		State.WALK:
			if Input.get_vector("move_left", "move_right", "move_up", "move_down") == Vector2.ZERO:
				state = State.IDLE
			if Input.is_action_just_pressed("attack"):
				state = State.USING_ITEM
		State.NONE:
			state = State.IDLE
	
	var mudou_state: bool = state != old_state
	# Processa state
	match state:
		State.IDLE:
			if mudou_state:
				frente_sprite_3D.show()
				animated_sprite_3d.hide()
				current_animation = AnimationActive.NONE
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		State.USING_ITEM:
			if mudou_state:
				frente_sprite_3D.hide()
				animated_sprite_3d.show()
				animated_sprite_3d.play("carimbando")
				current_animation = AnimationActive.STAMP_USE
				var c_item := itens_HUD.get_current_item()
				match c_item:
					ItensHUD.ItemEnum.TESOURA:
						print("tesourada")
						pass
					ItensHUD.ItemEnum.CARIMBO_TELEPORTE:
						print("Carimbo teleporte")
					ItensHUD.ItemEnum.CARIMBO_VENTO:
						if $StampTarget/RayCast3D.is_colliding():
							var point = $StampTarget/RayCast3D.get_collision_point()
							point.y += 0.01
							var stamp = (itens[c_item] as WindStamp)
							stamp.use(point)
							carimbados.add_child(stamp.gerado)
					_:
						pass
				
				
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
		State.TALKING:
			if mudou_state:
				# TODO: Melhorar essa logica pra passar a posicao para o player
				canvas_dialogue.init_dialogue(target_interactable.conversa, target_interactable.ponto_do_dialogo.global_position)
			pass
		State.WALK:
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			# TODO - separar a captura de input em um script separado
			var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
			#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			var direction := Vector3(input_dir.x, 0, input_dir.y)
			
			var target_basis = Basis.looking_at(direction, Vector3.UP)
			transform.basis = target_basis
			
			if input_dir.x == -1.0:
				frente_sprite_3D.flip_h = false
				animated_sprite_3d.flip_h = false
			elif input_dir.x == 1.0:
				frente_sprite_3D.flip_h = true
				animated_sprite_3d.flip_h = true
			
			if mudou_state:
				frente_sprite_3D.hide()
				animated_sprite_3d.show()
				if input_dir.x == -1 or input_dir.x == 1:
					animated_sprite_3d.play("side_move")
					current_animation = AnimationActive.SIDE_MOVE
				elif input_dir.y == 1:
					animated_sprite_3d.play("down_move")
					current_animation = AnimationActive.DOWN_MOVE
				elif input_dir.y == -1:
					animated_sprite_3d.play("up_move")
					current_animation = AnimationActive.UP_MOVE
			else:
				var target_animation: AnimationActive = AnimationActive.NONE
				if input_dir == Vector2(1, 0) or input_dir == Vector2(-1,0):
					target_animation = AnimationActive.SIDE_MOVE
				elif input_dir == Vector2(0, 1):
					target_animation = AnimationActive.DOWN_MOVE
				elif  input_dir == Vector2(0,-1):
					target_animation = AnimationActive.UP_MOVE

				if target_animation != AnimationActive.NONE:
					if target_animation != current_animation:
						match target_animation:
							AnimationActive.SIDE_MOVE:
								animated_sprite_3d.play("side_move")
								current_animation = AnimationActive.SIDE_MOVE
							AnimationActive.DOWN_MOVE:
								animated_sprite_3d.play("down_move")
								current_animation = AnimationActive.DOWN_MOVE
							AnimationActive.UP_MOVE:
								animated_sprite_3d.play("up_move")
								current_animation = AnimationActive.UP_MOVE
							_:
								pass
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			pass


	move_and_slide()
