class_name StatusEffect
extends EffectData
## Static status definition. The receiving actor owns stacking and duration state.

enum StackingPolicy { REPLACE, REFRESH_DURATION, ADD_STACK }

@export var status_id: StringName
@export_range(1, 999, 1) var duration_turns: int = 1
@export var stacking_policy: StackingPolicy = StackingPolicy.REFRESH_DURATION

func execute(context: EffectContext) -> EffectResult:
	if status_id.is_empty() or duration_turns <= 0:
		return EffectResult.failure("Invalid status definition")
	return context.target.add_status(self, context.source)

func execute_turn(context: EffectContext) -> EffectResult:
	return EffectResult.success()
