class_name StatGrowthData
extends Resource
## Per-character or per-class progression configuration.

@export_range(1, 999, 1) var max_level: int = 99
@export_group("Per-level fixed growth")
@export_range(0, 999999, 0.1) var max_hp_per_level: float = 10.0
@export_range(0, 999999, 0.1) var max_mp_per_level: float = 2.0
@export_range(0, 999999, 0.1) var attack_per_level: float = 2.0
@export_range(0, 999999, 0.1) var defense_per_level: float = 1.0
@export_range(0, 999999, 0.1) var magic_attack_per_level: float = 2.0
@export_range(0, 999999, 0.1) var magic_defense_per_level: float = 1.0
@export_range(0, 999999, 0.1) var speed_per_level: float = 0.5
@export_range(0, 999999, 0.1) var luck_per_level: float = 0.2
@export_group("EXP curve")
@export_range(0, 999999999, 1) var base_experience: int = 100
@export_range(1.0, 10.0, 0.01) var experience_factor: float = 1.5

func get_growth(stat: StringName) -> float:
	match stat:
		&"max_hp": return max_hp_per_level
		&"max_mp": return max_mp_per_level
		&"attack": return attack_per_level
		&"defense": return defense_per_level
		&"magic_attack": return magic_attack_per_level
		&"magic_defense": return magic_defense_per_level
		&"speed": return speed_per_level
		&"luck": return luck_per_level
	return 0.0

func experience_to_next_level(level: int) -> int:
	if level >= max_level or base_experience <= 0:
		return 0
	var value: float = float(base_experience) * pow(float(maxi(1, level)), experience_factor)
	return mini(2147483647, maxi(1, int(round(value))))

func is_valid_definition() -> bool:
	return max_level >= 1 and base_experience >= 0 and experience_factor >= 1.0 \
		and max_hp_per_level >= 0 and max_mp_per_level >= 0 and attack_per_level >= 0 \
		and defense_per_level >= 0 and magic_attack_per_level >= 0 \
		and magic_defense_per_level >= 0 and speed_per_level >= 0 and luck_per_level >= 0
