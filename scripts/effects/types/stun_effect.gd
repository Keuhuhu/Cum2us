class_name StunEffect
extends StatusEffect

func execute_turn(context: EffectContext) -> EffectResult:
	return context.target.skip_turn()
