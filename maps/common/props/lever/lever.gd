@tool
extends StaticBody3D


func _get_configuration_warnings() -> PackedStringArray:
		if not get_parent().has_method("interact"):
			return ["Esse node precisa de um parent que tenha um metodo 'interact' como um portao ou ponte"]
		return []


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name != "Player": return
	var parent = get_parent()
	if not parent.has_method("interact"):
		push_warning("Parent de %s (%s) nao tem um metodo 'interact'" % [name, parent.name])
		return

	parent.interact()
