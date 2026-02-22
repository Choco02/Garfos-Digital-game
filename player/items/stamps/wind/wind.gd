extends Node3D

func _ready() -> void:
	#type = Types.GROUND
	var t = create_tween().set_loops()
	t.tween_property(ventos, "rotation_degrees:y", -360, 3)
	t.tween_callback(zera_rot_ventos)
	area_efeito.gravity_space_override = Area3D.SPACE_OVERRIDE_DISABLED

func zera_rot_ventos():
	ventos.rotation_degrees.y = 0

@onready var ventos: MeshInstance3D = $Ventos
@onready var duracao: Timer = $Timers/Duracao
@onready var intervalo_entre: Timer = $"Timers/Intervalo entre"

# Estritamente precisa ser um Vector3 de global_position para funcionar
func use(target: Variant = null):
	if !(target is Vector3):
		return




@onready var area_efeito: Area3D = $"Area Efeito"

func _on_intervalo_entre_timeout() -> void:
	var mat = ventos.get_active_material(0)
	if mat:
		var t_start_wind = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		t_start_wind.tween_property(mat, "shader_parameter/completude", 0.99, 0.5)
	duracao.start()
	area_efeito.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	


func _on_duracao_timeout() -> void:
	var mat = ventos.get_active_material(0)
	if mat:
		var t_start_wind = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		t_start_wind.tween_property(mat, "shader_parameter/completude", 0., 0.5)
	intervalo_entre.start()
	area_efeito.gravity_space_override = Area3D.SPACE_OVERRIDE_DISABLED


func _on_area_efeito_body_entered(body: Node3D) -> void:
	if "on_wind" in body:
		body.on_wind = true


func _on_area_efeito_body_exited(body: Node3D) -> void:
	if "on_wind" in body:
		body.on_wind = false
