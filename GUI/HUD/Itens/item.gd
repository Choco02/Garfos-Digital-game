class_name ItemHUD
extends PanelContainer

var t_p_transicao: Tween
var t_f_transicao: Tween
var t_pulsar: Tween
@onready var aspect_ratio_container: AspectRatioContainer = $AspectRatioContainer
@export var sprite: Texture2D


const LIMIT_TOP_PULSAR := 1.2
const LIMIT_BOT_PULSAR := 1.0
const PULSAR_PERIOD := 2.0
func _ready() -> void:
	$AspectRatioContainer/TextureRect.texture = sprite
	hide()
	t_pulsar = create_tween().set_loops()#.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t_pulsar.tween_property(aspect_ratio_container, "scale", Vector2.ONE * LIMIT_TOP_PULSAR, PULSAR_PERIOD / 2.0)
	t_pulsar.tween_property(aspect_ratio_container, "scale", Vector2.ONE * LIMIT_BOT_PULSAR, PULSAR_PERIOD / 2.0)
	t_pulsar.stop()



const BASE_SIZE_CONATAINER := 100
const BASE_SIZE_TEXTURE := 50
const BASE_TRANS_TIME := 0.3
var is_spawned := false
func spawn() -> void:
	if is_spawned:
		return
	
	if t_p_transicao:
		t_p_transicao.kill()
	if t_f_transicao:
		t_f_transicao.kill()
	
	#size = Vector2.ZERO
	custom_minimum_size = Vector2.ZERO
	#aspect_ratio_container.custom_minimum_size = Vector2.ONE * 25
	show()
	t_p_transicao = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_p_transicao.tween_property(self,"custom_minimum_size", Vector2.ONE * BASE_SIZE_CONATAINER , BASE_TRANS_TIME)
	
	t_f_transicao = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_f_transicao.parallel().tween_property(aspect_ratio_container,"custom_minimum_size", Vector2.ONE * BASE_SIZE_TEXTURE , BASE_TRANS_TIME)

	is_spawned = true

func un_spawn() -> void:
	if !is_spawned:
		return
	
	if t_p_transicao:
		t_p_transicao.kill()
	aspect_ratio_container.custom_minimum_size = Vector2.ZERO
	t_p_transicao = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_p_transicao.tween_property(self,"custom_minimum_size", Vector2.ZERO, BASE_TRANS_TIME)
	t_p_transicao.tween_callback(hide)
	
	t_f_transicao = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_f_transicao.tween_property(aspect_ratio_container,"size", Vector2.ZERO, BASE_TRANS_TIME)
	
	is_spawned = false
	

const CHOOSE_SIZE_FACTOR := 1.5
var is_choosed := false
func choose() -> void:
	if is_choosed:
		return

	if t_f_transicao:
		t_f_transicao.kill()
	t_f_transicao = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_f_transicao.tween_property(aspect_ratio_container,"custom_minimum_size", Vector2.ONE * BASE_SIZE_TEXTURE * CHOOSE_SIZE_FACTOR, BASE_TRANS_TIME)
	#t_transicao.parallel().tween_property(self,"size", Vector2.ONE * BASE_SIZE_CONATAINER * CHOOSE_SIZE_FACTOR, BASE_TRANS_TIME)
	t_f_transicao.tween_callback(turn_on_pulsar)
	is_choosed = true

func un_choose() -> void:
	if !is_choosed:
		return
	
	turn_off_pulsar()
	if t_f_transicao:
		t_f_transicao.kill()
	#aspect_ratio_container.custom_minimum_size = Vector2.ONE * BASE_SIZE_TEXTURE
	t_f_transicao = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_f_transicao.tween_property(aspect_ratio_container,"custom_minimum_size", Vector2.ONE * BASE_SIZE_TEXTURE, BASE_TRANS_TIME)
	#t_transicao.tween_property(self,"size", Vector2.ONE * BASE_SIZE_CONATAINER, BASE_TRANS_TIME)
	
	is_choosed = false

# FIXME: Parece que o sprite treme, se mover o pivo para o centro treme mais
func turn_on_pulsar() -> void:
	if t_pulsar.is_valid():
		#aspect_ratio_container.pivot_offset.y = aspect_ratio_container.size.y / 2.0
		t_pulsar.play()
	return
	

func turn_off_pulsar() -> void:
	if t_pulsar.is_running():
		t_pulsar.stop()
	return
