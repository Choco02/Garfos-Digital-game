@abstract class_name Stamp
extends Area3D

enum Types {
	ENTITY, ## Carimba NPCs
	GROUND, ## Carimba o chao
	ENTITY_AND_GROUND, ## Carimba NPCs e chao
}

## 0 = sem limite
var usage_limits: int
var type: Types

func use():
	push_warning("[%s] funcao nao implementada" % name)
