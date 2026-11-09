class_name EffectData
extends Resource
## Static reusable effect definition. Runtime state belongs to the target.

@export var effect_name: String = "Effect"
@export_multiline var description: String

func execute(_context: EffectContext) -> EffectResult:
	return EffectResult.failure("EffectData.execute() must be overridden")
