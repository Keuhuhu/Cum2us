class_name StatEffect
extends EffectData

enum Stat { MAX_HP, MAX_MP, ATTACK, DEFENSE, MAGIC_ATTACK, MAGIC_DEFENSE, SPEED, LUCK }

@export var stat: Stat = Stat.ATTACK
@export_range(1, 999999, 1) var amount: int = 1
@export_range(0, 9999, 1) var duration_turns: int = 0

func apply_change(context: EffectContext, signed_amount: int) -> EffectResult:
	return context.target.change_stat(stat, signed_amount, duration_turns)
