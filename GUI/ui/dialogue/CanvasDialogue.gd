class_name CanvasDialogue
extends CanvasLayer
@export var dialogue: Dialogue
var current_phrase_index: int

@onready var fala: Speech = $Screen/Speech
@onready var tela: Control = $Screen
@onready var answers: Respostas = $Screen/Answers
#HACK: Depende da estrutura da cena
@onready var camera: Camera3D = $"../Camera3D"


var running: bool = false

func _ready() -> void:
	fala.hide()
	answers.hide()


func init_dialogue(new_dialogue: Dialogue,position: Vector3):
	if running:
		return
	print("Conversa iniciou")
	current_phrase_index = 0
	dialogue = new_dialogue
	fala.init_dialogue(dialogue.phrases[current_phrase_index], dialogue.target_name)
	fala.position = camera.unproject_position(position)
	
	if dialogue.phrases[current_phrase_index].answers_options.size() != 0:
		update_answers()
		answers.show()
	
	running = true

func update_answers():
	var r_param: Array[String]
	for i in range(dialogue.phrases[current_phrase_index].answers_options.size()):
		r_param.push_back(dialogue.phrases[current_phrase_index].answers_options[i].text)
	answers.update_answers(r_param)
	#respostas.pivot_offset.x = respostas.size.x / 2.0
	answers.reset_size()
	answers.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	#respostas.position.x -= respostas.size.x / 2. 


func end_dialogue():
	fala.end_dialogue()
	answers.end_dialogue()
	running = false

func next_phrase(target_index: int):
	#print(target_index)
	current_phrase_index = target_index
	fala.next_phrase(dialogue.phrases[current_phrase_index])
	answers.hide()
	if dialogue.phrases[current_phrase_index].answers_options.size() != 0:
		#print("ALLLOO")
		update_answers()
		answers.show()
	


#func _on_balao_end_dialogue_signal() -> void:
	#running = false
	#fala.visible = false

func _process(_delta: float) -> void:
	if running:
		if Input.is_action_just_pressed("ui_accept"):
			var next_index: int
			if dialogue.phrases[current_phrase_index].answers_options.size() == 0:
				next_index = dialogue.phrases[current_phrase_index].next_index_phrase
			else:
				#print(dialogue.phrases[current_phrase_index])
				next_index = dialogue.phrases[current_phrase_index].answers_options[answers.current_index].target_index
			if next_index == -1:
				end_dialogue()
			else:
				next_phrase(next_index)
