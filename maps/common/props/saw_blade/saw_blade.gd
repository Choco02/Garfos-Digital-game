@tool
extends CharacterBody3D


@export var degree_per_frame: int = 30
@export var vertical_movement: float = 0
@export var horizontal_movement: float = 0
@export var time_speed: float = 1.0
@export var move: bool = true


# TODO: Ainda tem que implementar a colisao do player aqui


func _ready() -> void:
	$Timer.start()


func spin(delta: float):
	$Sprite3D.rotate_z(deg_to_rad(degree_per_frame) * delta)


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	spin(delta)


func start_move():
	if move:
		var tween = create_tween()
		tween.tween_property(
			self,
			"global_position:x",
			global_position.x - horizontal_movement * 2,
			time_speed,
		)
		tween.tween_property(
			self,
			"global_position:x",
			global_position.x + horizontal_movement * 2,
			time_speed,
		)
		tween.tween_property(
			self,
			"global_position:x",
			0,
			time_speed,
		)

	await get_tree().create_timer(time_speed * 3).timeout
	start_move()


func _on_timer_timeout() -> void:
	start_move()
