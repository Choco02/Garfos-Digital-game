class_name ItensHUD
extends Control

@onready var v_container: VBoxContainer = $PanelContainer/VBoxContainer
var itens: Array[ItemHUD]
var current_index: int
var range_visible: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var node_itens = v_container.get_children()
	for i in node_itens:
		itens.push_back(i as ItemHUD)
	current_index = 0
	range_visible = 3
	update_itens()
	

#var base_size := 50.0
func update_itens():
	for i in range(itens.size()):
		if i < range_visible:
			itens[i].spawn()
		else:
			itens[i].un_spawn()
		if range_visible != 0 and i == current_index:
			itens[i].choose()
		else:
			itens[i].un_choose()


func _process(_delta: float) -> void:
	var has_change: bool
	var old_index := current_index
	var old_range := range_visible
	if Input.is_action_just_pressed("change_up_item"):
		current_index = clamp(current_index - 1, 0, range_visible - 1)
	if Input.is_action_just_pressed("change_down_item"):
		current_index = clamp(current_index + 1, 0, range_visible - 1)
	
	
	
	if current_index != old_index or range_visible != old_range:
		has_change = true
	
	if has_change:
		update_itens()

func push_item() -> void:
	range_visible = clamp(range_visible + 1, 0, itens.size())
	update_itens()

func pop_item() -> void:
	range_visible = clamp(range_visible - 1, 0, itens.size())
	if current_index >= range_visible:
		current_index = range_visible - 1
	update_itens()

enum ItemEnum {
	NONE,
	TESOURA,
	CARIMBO_TELEPORTE,
	CARIMBO_VENTO,
	CARIMBO_PSIQUICO,
}
# TODO: Transformar em um get?
func get_current_item() -> ItemEnum:
	match current_index:
		0:
			return ItemEnum.TESOURA
		1:
			return ItemEnum.CARIMBO_TELEPORTE
		2:
			return ItemEnum.CARIMBO_VENTO
		3:
			return ItemEnum.CARIMBO_PSIQUICO
		_:
			return ItemEnum.NONE
