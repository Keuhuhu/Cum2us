class_name CharacterData
extends Resource
## Static, reusable definition for a playable character or enemy.

@export_group("Identity")
@export var character_id: StringName
@export var display_name: String = "Character"
@export_multiline var description: String
@export var character_class: StringName
@export var portrait: Texture2D
@export var stat_growth: StatGrowthData

@export_group("Progression")
@export_range(1, 999, 1) var starting_level: int = 1
@export_range(0, 999999999, 1) var starting_experience: int = 0

@export_group("Base stats")
@export_range(1, 999999, 1) var max_hp: int = 100
@export_range(0, 999999, 1) var max_mp: int = 20
@export_range(0, 99999, 1) var attack: int = 10
@export_range(0, 99999, 1) var defense: int = 5
@export_range(0, 99999, 1) var magic_attack: int = 10
@export_range(0, 99999, 1) var magic_defense: int = 5
@export_range(0, 99999, 1) var speed: int = 10
@export_range(0, 99999, 1) var luck: int = 0

@export_group("Starting abilities")
@export var starting_skills: Array[SkillData] = []


func is_valid_definition() -> bool:
	return not character_id.is_empty() and not display_name.strip_edges().is_empty() \
		and max_hp > 0 and max_mp >= 0 \
		and attack >= 0 and defense >= 0 and magic_attack >= 0 \
		and magic_defense >= 0 and speed >= 0 and luck >= 0 \
		and starting_level >= 1 and starting_level <= get_max_level() \
		and starting_experience >= 0 \
		and (stat_growth == null or stat_growth.is_valid_definition())


func get_max_level() -> int:
	return stat_growth.max_level if stat_growth != null else 999
