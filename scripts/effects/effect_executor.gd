class_name EffectExecutor
extends RefCounted
## Executes effect definitions without knowing which system supplied them.

func execute(effect: EffectData, context: EffectContext) -> EffectResult:
	if effect == null:
		return EffectResult.failure("Effect is missing")
	if context == null or context.target == null:
		return EffectResult.failure("Effect target is missing")
	return effect.execute(context)

func execute_many(effects: Array[EffectData], context: EffectContext) -> Array[EffectResult]:
	var results: Array[EffectResult] = []
	for effect in effects:
		var result := execute(effect, context)
		results.append(result)
		if not result.succeeded:
			break
	return results

func execute_status_turns(target: EffectTarget) -> Array[EffectResult]:
	var results: Array[EffectResult] = []
	if target == null:
		return results
	for status_id: StringName in target.active_statuses.keys():
		var instance: EffectStatusInstance = target.active_statuses.get(status_id)
		if instance == null or instance.definition == null:
			target.remove_status(status_id)
			continue
		var context := EffectContext.new(target, instance.source, EffectContext.Origin.OTHER, {"stacks": instance.stacks})
		var result := instance.definition.execute_turn(context)
		results.append(result)
		instance.turns_remaining -= 1
		if instance.turns_remaining <= 0:
			target.remove_status(status_id)
	return results
