class_name RemoveStatusEffect
extends EffectData

@export var status_id: StringName

func execute(context: EffectContext) -> EffectResult:
	if status_id.is_empty():
		return EffectResult.failure("Status id is missing")
	return context.target.remove_status(status_id)
