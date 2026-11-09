class_name DebuffEffect
extends StatEffect

func execute(context: EffectContext) -> EffectResult:
	return apply_change(context, -amount)
