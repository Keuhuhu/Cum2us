class_name BurnEffect
extends StatusEffect

@export_range(1, 999999, 1) var damage_per_turn: int = 1

func execute_turn(context: EffectContext) -> EffectResult:
	var stacks: int = context.extra.get("stacks", 1)
	return context.target.damage(damage_per_turn * stacks, context.source)
