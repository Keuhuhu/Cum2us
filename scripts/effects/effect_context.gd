class_name EffectContext
extends RefCounted
## Runtime inputs for an effect. Origin is descriptive and has no system dependency.

enum Origin { OTHER, ITEM, SKILL, EQUIPMENT, ENVIRONMENT }

var source: Object
var target: EffectTarget
var origin: Origin = Origin.OTHER
var extra: Dictionary = {}

func _init(
		p_target: EffectTarget = null,
		p_source: Object = null,
		p_origin: Origin = Origin.OTHER,
		p_extra: Dictionary = {}) -> void:
	target = p_target
	source = p_source
	origin = p_origin
	extra = p_extra
