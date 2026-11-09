class_name DamageEffect
extends EffectData

@export_range(1, 999999, 1) var amount: int = 1

func execute(context: EffectContext) -> EffectResult:
	return context.target.damage(amount, context.source)
