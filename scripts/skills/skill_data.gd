class_name SkillData
extends Resource
## Static, reusable definition for an active or passive skill.

enum Category {
	MASTERY,
	SORCERY,
	PASSIVE,
}

enum Target {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	RANDOM_ENEMIES,
	SELF,
	SINGLE_ALLY,
	ALL_ALLIES,
}

enum Effect {
	DAMAGE,
	HEAL_HP,
	RESTORE_MP,
	REVIVE,
	BUFF,
	DEBUFF,
	CLEANSE,
	GUARD,
	EVASION,
}

@export_group("Identity")
@export var skill_id: StringName
@export var display_name: String = "Skill"
@export_multiline var description: String
@export var category: Category = Category.MASTERY
@export var icon: Texture2D

@export_group("Battle")
@export var target: Target = Target.SINGLE_ENEMY
@export var effects: Array[EffectData] = []
@export_range(0, 99999, 1) var mp_cost: int = 0
@export_range(0, 99, 1) var cooldown_turns: int = 0
@export_range(0, 99, 1) var hit_count: int = 1
@export_range(0.0, 100.0, 0.1) var power_multiplier: float = 1.0
@export var scaling_stat: StringName = &"attack"
@export var element: StringName = &"none"
@export_range(0, 99, 1) var duration_turns: int = 0


@export_group("Source")
@export var source_page: String
@export var source_note: String


func is_valid_definition() -> bool:
	if skill_id.is_empty() or display_name.strip_edges().is_empty():
		return false
	if hit_count < 1:
		return false

	return true
