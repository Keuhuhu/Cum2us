class_name StatModifier
extends Resource
## Reusable stat adjustment. Runtime duration is tracked by CharacterInstance.

enum Operation { FLAT, PERCENT_ADD, PERCENT_MULTIPLY }

@export var modifier_id: StringName
@export var stat: StringName = &"attack"
@export var operation: Operation = Operation.FLAT
@export var amount: float = 0.0

func is_valid_definition() -> bool:
	return not stat.is_empty() and is_finite(amount)
