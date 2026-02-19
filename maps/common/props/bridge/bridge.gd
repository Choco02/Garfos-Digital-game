extends StaticBody3D
class_name Bridge

var activated = false


func _input(event: InputEvent) -> void:
	interact()


# TODO: fornecer alguma forma de ativar essa funcao
# algum gatilho, um parent, um child, signal, chamada de funcao, event bus
func interact():
	if activated: return
	activated = true
	$AnimationPlayer.play("activate_bridge")
	$CollisionShape3D.disabled = true
