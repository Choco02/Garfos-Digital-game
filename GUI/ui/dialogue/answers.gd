class_name Respostas
extends VBoxContainer

var answers_size: int = 0
const  color_base: Color = Color.WHITE
var styles: Array[StyleBoxFlat]
var current_index: int = 0

signal answer_choosed(index: int)

func update_answers(respostas: Array[String]):
	current_index = 0
	var childs := get_children()
	
	for child in childs:
		child.visible = true
	
	
	for i in range(respostas.size()):
		var label_dst = childs[i].get_child(0).get_child(0) as Label
		label_dst.text = respostas[i]
	
	if respostas.size() < childs.size():
		for i in range(childs.size() - respostas.size()):
			childs[i + respostas.size()].visible = false
	answers_size = respostas.size()
	styles.clear()
	styles.resize(answers_size)
	for i in range(answers_size):
		styles[i] = (childs[i] as PanelContainer).get_theme_stylebox("panel").duplicate()
		styles[i].border_color = color_base
		(childs[i] as PanelContainer).add_theme_stylebox_override("panel", styles[i])
	
	var tween = create_tween()
	tween.tween_property(styles[0], "border_color", Color.GREEN, 0.2)

func end_dialogue():
	current_index = 0
	
	hide()


func _physics_process(_delta: float) -> void:
	var old_index = current_index
	if Input.is_action_just_pressed("ui_up"):
		current_index = clamp(current_index - 1,0, answers_size - 1)
	if Input.is_action_just_pressed("ui_down"):
		current_index = clamp(current_index + 1, 0, answers_size - 1)
	
	#
	if old_index != current_index:
		var tween = create_tween()
		tween.tween_property(styles[old_index], "border_color", color_base, 0.2)
		var tween2 = create_tween()
		tween2.tween_property(styles[current_index], "border_color", Color.GREEN, 0.2)
	
	
