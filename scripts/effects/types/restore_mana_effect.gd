class_name RestoreManaEffect
extends EffectData

@export_range(1, 999999, 1) var amount: int = 1

func execute(context: EffectContext) -> EffectResult:
	return context.target.restore_mana(amount, context.source)
