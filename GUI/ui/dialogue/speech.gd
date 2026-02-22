class_name Speech
extends Control

var target_name: String
var phrase: Phrase
var current_index: int
signal end_dialogue_signal

@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var rich_text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/RichTextLabel
@onready var panel_container: PanelContainer = $PanelContainer

func inicializar(nome: String, text: String):
	label.text = nome
	rich_text_label.text = text
	#panel_container.custom_minimum_size.x = 200
	panel_container.custom_minimum_size.x = get_viewport_rect().size.x * 0.3
	panel_container.pivot_offset.x = get_viewport_rect().size.x * 0.3 / 2.0
	reset_size()
	show()
	#print("abroba")

func init_dialogue(p: Phrase, target_n: String):
	#print("Init Speech")
	phrase = p
	inicializar(target_n, phrase .text)
	
	rich_text_label.visible_characters = 0
	var tween = create_tween()
	tween.tween_property(rich_text_label, "visible_characters", rich_text_label.text.length(), 1.0)
	current_index = 0

	
func next_phrase(new_phrase: Phrase):
		phrase = new_phrase
		rich_text_label.text = phrase.text
		rich_text_label.visible_characters = 0
		var tween = create_tween()
		tween.tween_property(rich_text_label, "visible_characters", rich_text_label.text.length(), 1.0)

func end_dialogue():
	current_index = 0
	end_dialogue_signal.emit()
	hide()
	

#
#
#func _on_respostas_answer_choosed(index: int) -> void:
	#if conversa.phrases[current_index].next_index_phrase == -1:
	##current_index = 
	##if current_index >= conversa.phrases.size():
		#end_dialogue()
	#else:
		#current_index = conversa.phrases[current_index].next_index_phrase
		#rich_text_label.text = conversa.phrases[current_index].text
		#rich_text_label.visible_characters = 0
		#var tween = create_tween()
		#tween.tween_property(rich_text_label, "visible_characters", rich_text_label.text.length(), 1.0)
