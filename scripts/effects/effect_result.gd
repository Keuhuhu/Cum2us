class_name EffectResult
extends RefCounted
## Outcome of one effect execution.

var succeeded: bool = false
var amount_applied: int = 0
var message: String = ""

static func success(amount: int = 0) -> EffectResult:
	var result := EffectResult.new()
	result.succeeded = true
	result.amount_applied = amount
	return result

static func failure(reason: String) -> EffectResult:
	var result := EffectResult.new()
	result.message = reason
	return result
