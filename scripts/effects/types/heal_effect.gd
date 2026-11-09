class_name HealEffect
extends EffectData

@export_range(1, 999999, 1) var amount: int = 1

func execute(context: EffectContext) -> EffectResult:
	return context.target.heal(amount, context.source)
