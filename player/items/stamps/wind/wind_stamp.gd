class_name WindStamp
extends Stamp

const WIND = preload("res://player/items/stamps/wind/wind.tscn")
var gerado: Node3D

func use(target:Variant = null):
	if !(target is Vector3):
		print("Target não é um Vector3")
	gerado = WIND.instantiate()
	gerado.position = target
	
	
