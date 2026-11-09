class_name EffectTarget
extends RefCounted
## Typed adapter contract between effects and a character or other target.
## Runtime character code should provide a concrete adapter; no game actor is
## present in this project yet. A concrete adapter supplies stat/HP methods.

var active_statuses: Dictionary[StringName, EffectStatusInstance] = {}

func heal(_amount: int, _source: Object) -> EffectResult:
	return EffectResult.failure("EffectTarget.heal() is not implemented")

func damage(_amount: int, _source: Object) -> EffectResult:
	return EffectResult.failure("EffectTarget.damage() is not implemented")

func restore_mana(_amount: int, _source: Object) -> EffectResult:
	return EffectResult.failure("EffectTarget.restore_mana() is not implemented")

func change_stat(_stat: int, _amount: int, _duration_turns: int) -> EffectResult:
	return EffectResult.failure("EffectTarget.change_stat() is not implemented")

func add_status(effect: StatusEffect, source: Object) -> EffectResult:
	if effect == null or effect.status_id.is_empty() or effect.duration_turns <= 0:
		return EffectResult.failure("Invalid status definition")
	var status_id := effect.status_id
	var existing: EffectStatusInstance = active_statuses.get(status_id)
	if existing == null or effect.stacking_policy == StatusEffect.StackingPolicy.REPLACE:
		active_statuses[status_id] = EffectStatusInstance.new(effect, source)
		return EffectResult.success()
	match effect.stacking_policy:
		StatusEffect.StackingPolicy.REFRESH_DURATION:
			existing.definition = effect
			existing.source = source
			existing.turns_remaining = effect.duration_turns
		StatusEffect.StackingPolicy.ADD_STACK:
			existing.stacks += 1
			existing.turns_remaining = effect.duration_turns
	return EffectResult.success()

func remove_status(status_id: StringName) -> EffectResult:
	if not active_statuses.erase(status_id):
		return EffectResult.failure("Status is not active")
	return EffectResult.success()

func skip_turn() -> EffectResult:
	return EffectResult.failure("EffectTarget.skip_turn() is not implemented")
