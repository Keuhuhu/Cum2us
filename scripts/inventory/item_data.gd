class_name ItemData
extends Resource
## Static item definition. Store quantities separately in an inventory.

enum Category {
	CONSUMABLE,
	MATERIAL,
	QUEST,
	EQUIPMENT,
	KEY_ITEM,
}

enum UseEffect {
	NONE,
	RESTORE_HP,
	RESTORE_MP,
	REVIVE,
}

@export_group("Identity")
@export var item_id: StringName
@export var display_name: String = "Item"
@export_multiline var description: String
@export var icon: Texture2D
@export var category: Category = Category.CONSUMABLE

@export_group("Inventory")
@export_range(0, 999999999, 1) var buy_price: int = 0
@export_range(0, 999999999, 1) var sell_price: int = 0
@export var stackable: bool = true
@export_range(1, 999, 1) var max_stack: int = 99

@export_group("Use effect")
@export var use_effect: UseEffect = UseEffect.NONE
@export_range(0, 999999, 1) var effect_amount: int = 0
@export var usable_in_battle: bool = false
@export var usable_outside_battle: bool = false


func is_valid_definition() -> bool:
	if item_id.is_empty() or display_name.strip_edges().is_empty():
		return false
	if not stackable and max_stack != 1:
		return false
	if use_effect != UseEffect.NONE and effect_amount <= 0:
		return false
	return true


func get_stack_limit() -> int:
	return max_stack if stackable else 1
