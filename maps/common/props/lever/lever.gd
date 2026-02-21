@tool
extends StaticBody3D


func _check_method(node):
	return node.has_method("interact")


func _get_configuration_warnings() -> PackedStringArray:
		var children = get_children()
		var interactable_children = children.filter(_check_method)
		if interactable_children.size() > 0: return []

		return [
			"Esse node precisa ser parent de pelo menos um node que " +
			"tenha um metodo 'interact' como um portao ou ponte"
		]


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name != "Player": return
	var children = get_children()
	var interactable_children = children.filter(_check_method)
	if interactable_children.size() == 0:
		push_warning("Nenhum child de %s tem um metodo 'interact'" % [name])
		return

	interactable_children.all(func(child): return child.interact())
