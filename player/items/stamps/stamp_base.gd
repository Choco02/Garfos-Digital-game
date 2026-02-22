@abstract class_name Stamp
extends Item

enum Types {
	ENTITY, ## Carimba NPCs
	GROUND, ## Carimba o chao
	ENTITY_AND_GROUND, ## Carimba NPCs e chao
}

## 0 = sem limite
var usage_limits: int
var type: Types
var paint_cost: int

@abstract func use(target:Variant = null)
	#push_warning("[%s] funcao nao implementada" % name)
