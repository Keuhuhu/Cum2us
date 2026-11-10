class_name CharacterInstance
extends EffectTarget
## Mutable runtime state and the single source of truth for a character.

signal level_changed(old_level: int, new_level: int)
signal health_changed(current: int, maximum: int)
signal mana_changed(current: int, maximum: int)
signal stats_changed(stats: Dictionary[StringName, int])

const STAT_NAMES: Array[StringName] = [&"max_hp", &"max_mp", &"attack", &"defense", &"magic_attack", &"magic_defense", &"speed", &"luck"]
const MAX_STAT_VALUE: int = 2147483647

var character_data: CharacterData
var level: int = 1
var experience: int = 0
var current_hp: int = 0:
	set(value):
		var next_value := clampi(value, 0, max_hp)
		if current_hp == next_value:
			return
		current_hp = next_value
		health_changed.emit(current_hp, max_hp)
var current_mp: int = 0:
	set(value):
		var next_value := clampi(value, 0, max_mp)
		if current_mp == next_value:
			return
		current_mp = next_value
		mana_changed.emit(current_mp, max_mp)

var _base_stats: Dictionary[StringName, int] = {}
var _modifiers: Array[Dictionary] = []
var _skills: Array[SkillData] = []
var skills: Array[SkillData]:
	get: return _skills
var equipment: Array[Resource] = []
var _equipment_modifiers: Dictionary[Resource, Array] = {}

var max_hp: int:
	get: return get_stat(&"max_hp")
	set(value): _set_base_stat(&"max_hp", value)
var max_mp: int:
	get: return get_stat(&"max_mp")
	set(value): _set_base_stat(&"max_mp", value)
var attack: int:
	get: return get_stat(&"attack")
	set(value): _set_base_stat(&"attack", value)
var defense: int:
	get: return get_stat(&"defense")
	set(value): _set_base_stat(&"defense", value)
var magic_attack: int:
	get: return get_stat(&"magic_attack")
	set(value): _set_base_stat(&"magic_attack", value)
var magic_defense: int:
	get: return get_stat(&"magic_defense")
	set(value): _set_base_stat(&"magic_defense", value)
var speed: int:
	get: return get_stat(&"speed")
	set(value): _set_base_stat(&"speed", value)
var luck: int:
	get: return get_stat(&"luck")
	set(value): _set_base_stat(&"luck", value)

func _init(data: CharacterData = null) -> void:
	character_data = data
	if data == null:
		return
	level = clampi(data.starting_level, 1, data.get_max_level())
	experience = maxi(0, data.starting_experience)
	for stat: StringName in STAT_NAMES:
		_base_stats[stat] = _template_stat(stat)
	if data.stat_growth != null:
		for _growth_level in range(maxi(0, level - data.starting_level)):
			for stat: StringName in STAT_NAMES:
				_base_stats[stat] = mini(MAX_STAT_VALUE, int(_base_stats[stat]) + int(data.stat_growth.get_growth(stat)))
	for skill: SkillData in data.starting_skills:
		if skill != null:
			_skills.append(skill)
	current_hp = max_hp
	current_mp = max_mp
	_sync_level_from_experience()

func get_stat(stat: StringName) -> int:
	if not STAT_NAMES.has(stat):
		return 0
	var value: float = float(_base_stats.get(stat, 0))
	var additive_percent: float = 0.0
	var multiplier: float = 1.0
	for entry: Dictionary in _modifiers:
		var modifier: StatModifier = entry.get("modifier")
		if modifier == null or modifier.stat != stat or not modifier.is_valid_definition():
			continue
		match modifier.operation:
			StatModifier.Operation.FLAT: value += modifier.amount
			StatModifier.Operation.PERCENT_ADD: additive_percent += modifier.amount
			StatModifier.Operation.PERCENT_MULTIPLY: multiplier *= 1.0 + modifier.amount
	value *= maxf(0.0, 1.0 + additive_percent) * maxf(0.0, multiplier)
	return maxi(1 if stat == &"max_hp" else 0, _bounded_stat(value))

func get_all() -> Dictionary[StringName, int]:
	var result: Dictionary[StringName, int] = {}
	for stat: StringName in STAT_NAMES:
		result[stat] = get_stat(stat)
	return result

func get_critical_chance() -> float:
	return clampf(0.05 + float(luck) * 0.005, 0.0, 0.75)

func get_critical_damage_multiplier() -> float:
	return 1.5 + float(luck) * 0.01

func get_hit_chance(target_evasion: int = 0) -> float:
	return clampf(0.95 + float(luck - target_evasion) * 0.002, 0.05, 1.0)

func get_evasion_rate() -> float:
	return clampf(float(speed) * 0.005 + float(luck) * 0.002, 0.0, 0.75)

func get_physical_damage_reduction() -> float:
	return clampf(float(defense) / (100.0 + float(defense)), 0.0, 0.9)

func get_magic_damage_reduction() -> float:
	return clampf(float(magic_defense) / (100.0 + float(magic_defense)), 0.0, 0.9)

func is_alive() -> bool:
	return current_hp > 0

func take_damage(amount: int) -> int:
	var applied: int = mini(current_hp, maxi(0, amount))
	current_hp -= applied
	return applied

func heal(amount: int, _source: Object = null) -> EffectResult:
	if amount < 0:
		return EffectResult.failure("Healing amount cannot be negative")
	var before: int = current_hp
	current_hp = mini(max_hp, current_hp + amount)
	return EffectResult.success(current_hp - before)

func damage(amount: int, _source: Object = null) -> EffectResult:
	if amount < 0:
		return EffectResult.failure("Damage amount cannot be negative")
	return EffectResult.success(take_damage(amount))

func restore_mana(amount: int, _source: Object = null) -> EffectResult:
	if amount < 0:
		return EffectResult.failure("Mana amount cannot be negative")
	var before: int = current_mp
	current_mp = mini(max_mp, current_mp + amount)
	return EffectResult.success(current_mp - before)

func spend_mana(amount: int) -> bool:
	if amount < 0 or current_mp < amount:
		return false
	current_mp -= amount
	return true

func change_stat(stat: int, amount: int, duration_turns: int) -> EffectResult:
	var stat_name: StringName = _effect_stat_name(stat)
	if stat_name.is_empty() or amount == 0:
		return EffectResult.failure("Invalid stat change")
	var modifier := StatModifier.new()
	modifier.modifier_id = StringName("effect_%s_%d" % [stat_name, Time.get_ticks_usec()])
	modifier.stat = stat_name
	modifier.operation = StatModifier.Operation.FLAT
	modifier.amount = float(amount)
	if not add_stat_modifier(modifier, duration_turns):
		return EffectResult.failure("Could not add stat modifier")
	return EffectResult.success()

func add_stat_modifier(modifier: StatModifier, duration_turns: int = 0) -> bool:
	if modifier == null or not modifier.is_valid_definition() or not STAT_NAMES.has(modifier.stat):
		return false
	var old_max_hp: int = max_hp
	var old_max_mp: int = max_mp
	_modifiers.append({"modifier": modifier, "turns": maxi(0, duration_turns)})
	_emit_stat_changes(old_max_hp, old_max_mp)
	return true

func remove_stat_modifier(modifier_id: StringName) -> void:
	var old_max_hp: int = max_hp
	var old_max_mp: int = max_mp
	_modifiers = _modifiers.filter(func(entry: Dictionary) -> bool:
		var modifier: StatModifier = entry.get("modifier")
		return modifier == null or modifier.modifier_id != modifier_id
	)
	_emit_stat_changes(old_max_hp, old_max_mp)

func equip(item: Resource, modifiers: Array[StatModifier]) -> bool:
	if item == null:
		return false
	unequip(item)
	equipment.append(item)
	var applied: Array[StatModifier] = []
	for modifier: StatModifier in modifiers:
		if add_stat_modifier(modifier):
			applied.append(modifier)
	_equipment_modifiers[item] = applied
	return true

func unequip(item: Resource) -> void:
	if not equipment.has(item):
		return
	equipment.erase(item)
	var applied: Array = _equipment_modifiers.get(item, [])
	for modifier: StatModifier in applied:
		_remove_modifier_instance(modifier)
	_equipment_modifiers.erase(item)

func add_experience(amount: int) -> int:
	if amount <= 0:
		return 0
	var old_level: int = level
	experience = mini(MAX_STAT_VALUE, experience + amount)
	_sync_level_from_experience()
	return level - old_level

func advance_effect_durations() -> void:
	var old_max_hp: int = max_hp
	var old_max_mp: int = max_mp
	var changed := false
	for i in range(_modifiers.size() - 1, -1, -1):
		var entry: Dictionary = _modifiers[i]
		if int(entry.get("turns", 0)) <= 0:
			continue
		entry["turns"] = int(entry["turns"]) - 1
		if int(entry["turns"]) <= 0:
			_modifiers.remove_at(i)
			changed = true
	if changed:
		_emit_stat_changes(old_max_hp, old_max_mp)

func save_state() -> Dictionary:
	return {"character_id": character_data.character_id if character_data != null else &"", "level": level,
		"experience": experience, "current_hp": current_hp, "current_mp": current_mp}

func load_state(state: Dictionary) -> bool:
	if character_data == null or StringName(state.get("character_id", &"")) != character_data.character_id:
		return false
	var old_level: int = level
	var old_max_hp: int = max_hp
	var old_max_mp: int = max_mp
	level = clampi(int(state.get("level", level)), 1, character_data.get_max_level())
	experience = maxi(0, int(state.get("experience", experience)))
	_set_level_base_stats()
	current_hp = clampi(int(state.get("current_hp", current_hp)), 0, max_hp)
	current_mp = clampi(int(state.get("current_mp", current_mp)), 0, max_mp)
	if old_level != level:
		level_changed.emit(old_level, level)
	_emit_stat_changes(old_max_hp, old_max_mp)
	return true

func _sync_level_from_experience() -> void:
	if character_data == null or character_data.stat_growth == null:
		return
	var previous: int = level
	while level < character_data.get_max_level():
		var threshold: int = character_data.stat_growth.experience_to_next_level(level)
		if threshold <= 0 or experience < threshold:
			break
		experience -= threshold
		level += 1
		_apply_level_growth()
	if level != previous:
		level_changed.emit(previous, level)

func _apply_level_growth() -> void:
	if character_data == null or character_data.stat_growth == null:
		return
	var old_max_hp: int = max_hp
	var old_max_mp: int = max_mp
	for stat: StringName in STAT_NAMES:
		_base_stats[stat] = mini(MAX_STAT_VALUE, int(_base_stats.get(stat, 0)) + int(character_data.stat_growth.get_growth(stat)))
	_emit_stat_changes(old_max_hp, old_max_mp)

func _set_level_base_stats() -> void:
	for stat: StringName in STAT_NAMES:
		_base_stats[stat] = _template_stat(stat)
	if character_data.stat_growth != null:
		for _growth_level in range(maxi(0, level - character_data.starting_level)):
			for stat: StringName in STAT_NAMES:
				_base_stats[stat] = mini(MAX_STAT_VALUE, int(_base_stats.get(stat, 0)) + int(character_data.stat_growth.get_growth(stat)))

func _set_base_stat(stat: StringName, value: int) -> void:
	if not STAT_NAMES.has(stat):
		return
	var old_max_hp: int = max_hp
	var old_max_mp: int = max_mp
	_base_stats[stat] = maxi(1 if stat == &"max_hp" else 0, mini(MAX_STAT_VALUE, value))
	_emit_stat_changes(old_max_hp, old_max_mp)

func _emit_stat_changes(old_max_hp: int, old_max_mp: int) -> void:
	current_hp = mini(current_hp, max_hp)
	current_mp = mini(current_mp, max_mp)
	stats_changed.emit(get_all())
	if old_max_hp != max_hp:
		health_changed.emit(current_hp, max_hp)
	if old_max_mp != max_mp:
		mana_changed.emit(current_mp, max_mp)

func _remove_modifier_instance(modifier: StatModifier) -> void:
	var old_max_hp: int = max_hp
	var old_max_mp: int = max_mp
	for i in range(_modifiers.size() - 1, -1, -1):
		if _modifiers[i].get("modifier") == modifier:
			_modifiers.remove_at(i)
			break
	_emit_stat_changes(old_max_hp, old_max_mp)

func _template_stat(stat: StringName) -> int:
	if character_data == null:
		return 0
	match stat:
		&"max_hp": return character_data.max_hp
		&"max_mp": return character_data.max_mp
		&"attack": return character_data.attack
		&"defense": return character_data.defense
		&"magic_attack": return character_data.magic_attack
		&"magic_defense": return character_data.magic_defense
		&"speed": return character_data.speed
		&"luck": return character_data.luck
	return 0

func _bounded_stat(value: float) -> int:
	return int(round(clampf(value, 0.0, float(MAX_STAT_VALUE))))

func _effect_stat_name(stat: int) -> StringName:
	match stat:
		StatEffect.Stat.MAX_HP: return &"max_hp"
		StatEffect.Stat.MAX_MP: return &"max_mp"
		StatEffect.Stat.ATTACK: return &"attack"
		StatEffect.Stat.DEFENSE: return &"defense"
		StatEffect.Stat.MAGIC_ATTACK: return &"magic_attack"
		StatEffect.Stat.MAGIC_DEFENSE: return &"magic_defense"
		StatEffect.Stat.SPEED: return &"speed"
		StatEffect.Stat.LUCK: return &"luck"
	return &""
