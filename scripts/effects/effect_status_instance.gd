class_name EffectStatusInstance
extends RefCounted
## Mutable per-target runtime state for an immutable StatusEffect resource.

var definition: StatusEffect
var source: Object
var turns_remaining: int
var stacks: int = 1

func _init(p_definition: StatusEffect, p_source: Object) -> void:
	definition = p_definition
	source = p_source
	turns_remaining = p_definition.duration_turns
