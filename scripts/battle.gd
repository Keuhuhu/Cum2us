extends Control

const BG := Color("17151d")
const PANEL := Color("26232d")
const GOLD := Color("e7bd78")
const MUTED := Color("b9b2bd")
const ATTACK_ICON: Texture2D = preload("res://assets/ui/battle_icons/attack_sword.png")
const MOONFIRE_ICON: Texture2D = preload("res://assets/ui/battle_icons/moonfire_orb.png")
const DEFEND_ICON: Texture2D = preload("res://assets/ui/battle_icons/defend_shield.png")

var hero := {"name":"Wanderer", "hp":120, "max_hp":120, "mp":30, "max_mp":30, "attack":18, "defense":8, "magic":16, "speed":12, "progress":0.0, "alive":true}
var foes: Array[Dictionary] = []
var xp := 0
var level := 1
var points := 0
var battle_over := false
var input_open := false
var defended := false
var battle_xp := 0
var log_lines: Array[String] = []
var turn_label: Label
var party_label: Label
var enemies_label: Label
var log_label: Label
var xp_label: Label
var action_box: HBoxContainer
var target_box: HBoxContainer
var stat_box: VBoxContainer
var timer: Timer
const PIXEL_SPRITE = preload("res://scripts/pixel_sprite.gd")

func _ready() -> void:
	_build_ui()
	_start_battle()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)
	var title := _label("THE HOLLOW WOOD", 28, GOLD)
	root.add_child(title)
	root.add_child(_label("A turn-based dark fairy tale", 14, MUTED))
	var bar := _panel()
	root.add_child(bar)
	turn_label = _label("TURN ORDER", 17, GOLD)
	bar.add_child(turn_label)
	var arena := HBoxContainer.new()
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.add_theme_constant_override("separation", 16)
	root.add_child(arena)
	var hero_panel := _panel()
	hero_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arena.add_child(hero_panel)
	hero_panel.add_child(_label("✦  HERO", 20, GOLD))
	var hero_sprite = PIXEL_SPRITE.new()
	hero_sprite.character = "hero"
	hero_panel.add_child(hero_sprite)
	party_label = _label("", 17, Color.WHITE)
	hero_panel.add_child(party_label)
	var foe_panel := _panel()
	foe_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arena.add_child(foe_panel)
	foe_panel.add_child(_label("THE HOLLOWED", 20, GOLD))
	var enemy_sprites := HBoxContainer.new()
	foe_panel.add_child(enemy_sprites)
	for kind in ["briarling", "goblin", "ogre"]:
		var sprite = PIXEL_SPRITE.new()
		sprite.character = kind
		sprite.custom_minimum_size = Vector2(78, 96)
		enemy_sprites.add_child(sprite)
	enemies_label = _label("", 17, Color.WHITE)
	foe_panel.add_child(enemies_label)
	var progression := _panel()
	root.add_child(progression)
	xp_label = _label("", 15, GOLD)
	progression.add_child(xp_label)
	stat_box = VBoxContainer.new()
	progression.add_child(stat_box)
	var actions := _panel()
	root.add_child(actions)
	actions.add_child(_label("CHOOSE YOUR ACTION", 16, GOLD))
	action_box = HBoxContainer.new()
	actions.add_child(action_box)
	target_box = HBoxContainer.new()
	actions.add_child(target_box)
	var battle_log := _panel()
	root.add_child(battle_log)
	battle_log.add_child(_label("BATTLE LOG", 15, GOLD))
	log_label = _label("The woods are quiet...", 14, MUTED)
	log_label.custom_minimum_size.y = 56
	battle_log.add_child(log_label)
	timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_advance_time)
	add_child(timer)

func _panel() -> VBoxContainer:
	var p := VBoxContainer.new()
	p.add_theme_stylebox_override("panel", _style(PANEL))
	p.add_theme_constant_override("separation", 8)
	return p

func _style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = Color("514653")
	s.set_border_width_all(1)
	s.set_corner_radius_all(5)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s

func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _button(text: String, callback: Callable, icon: Texture2D = null) -> Button:
	var b := Button.new()
	b.text = text
	b.icon = icon
	b.custom_minimum_size = Vector2(152, 42)
	b.pressed.connect(callback)
	return b

func _start_battle() -> void:
	foes = [
		{"name":"Briarling", "hp":42, "max_hp":42, "attack":9, "defense":3, "magic":2, "speed":15, "progress":0.0, "alive":true, "xp":18, "kind":"quick"},
		{"name":"Mire Goblin", "hp":58, "max_hp":58, "attack":12, "defense":5, "magic":4, "speed":8, "progress":0.0, "alive":true, "xp":24, "kind":"normal"},
		{"name":"Ogre of Ash", "hp":90, "max_hp":90, "attack":22, "defense":8, "magic":3, "speed":4, "progress":0.0, "alive":true, "xp":38, "kind":"heavy"}
	]
	battle_over = false
	input_open = false
	defended = false
	battle_xp = 0
	_add_log("Three shapes stir among the briars.")
	_refresh()
	timer.start()

func _advance_time() -> void:
	if battle_over or input_open:
		return
	var fighters: Array[Dictionary] = [hero]
	for e in foes:
		if e.alive:
			fighters.append(e)
	for f in fighters:
		f.progress += float(f.speed) * 0.8
	var ready: Dictionary = {}
	for f in fighters:
		if f.progress >= 100.0 and (ready.is_empty() or f.progress > ready.progress):
			ready = f
	_refresh()
	if ready.is_empty():
		return
	ready.progress -= 100.0
	if ready == hero:
		input_open = true
		_add_log("Your turn. Choose wisely.")
		_show_actions()
	else:
		_enemy_action(ready)
	_refresh()

func _show_actions() -> void:
	_clear(action_box)
	_clear(target_box)
	action_box.add_child(_button("Attack", _choose_attack, ATTACK_ICON))
	var skill := _button("Moonfire · 8 MP", _choose_skill, MOONFIRE_ICON)
	skill.disabled = hero.mp < 8
	action_box.add_child(skill)
	action_box.add_child(_button("Defend", _choose_defend, DEFEND_ICON))
	if points > 0:
		action_box.add_child(_button("Spend stat point", _show_stat_choices))

func _choose_attack() -> void:
	_show_targets("attack")

func _choose_skill() -> void:
	if hero.mp < 8: return
	_show_targets("skill")

func _show_targets(action: String) -> void:
	_clear(target_box)
	target_box.add_child(_label("Choose a target:", 14, MUTED))
	for i in range(foes.size()):
		if foes[i].alive:
			var index := i
			target_box.add_child(_button(foes[i].name, func(): _resolve_hero_action(action, index)))

func _resolve_hero_action(action: String, index: int) -> void:
	if battle_over or not input_open or index >= foes.size() or not foes[index].alive: return
	var target := foes[index]
	var damage: int
	if action == "skill":
		hero.mp -= 8
		damage = maxi(1, hero.magic * 2 - target.defense)
		_add_log("Moonfire strikes %s for %d. (-8 MP)" % [target.name, damage])
	else:
		damage = maxi(1, hero.attack - target.defense)
		_add_log("You strike %s for %d." % [target.name, damage])
	target.hp = maxi(0, target.hp - damage)
	if target.hp == 0:
		target.alive = false
		battle_xp += target.xp
		_add_log("%s falls. +%d XP." % [target.name, target.xp])
	_finish_hero_turn()

func _choose_defend() -> void:
	defended = true
	_add_log("You brace yourself. The next hit is reduced.")
	_finish_hero_turn()

func _finish_hero_turn() -> void:
	input_open = false
	_clear(action_box)
	_clear(target_box)
	_check_battle_end()
	_refresh()

func _enemy_action(enemy: Dictionary) -> void:
	var base := maxi(1, enemy.attack - hero.defense)
	var damage := int(ceil(float(base) * 0.5)) if defended else base
	hero.hp = maxi(0, hero.hp - damage)
	if defended:
		defended = false
	_add_log("%s hits you for %d%s." % [enemy.name, damage, " (guarded)" if damage < base else ""])
	_check_battle_end()

func _check_battle_end() -> void:
	if hero.hp <= 0:
		battle_over = true
		timer.stop()
		_add_log("You fall beneath the hollow boughs.")
		_clear(action_box)
		_clear(target_box)
		action_box.add_child(_button("Retry battle", _retry))
	elif foes.all(func(e): return not e.alive):
		battle_over = true
		timer.stop()
		xp += battle_xp
		_add_log("Victory. You gained %d XP." % battle_xp)
		_check_level_up()
		_clear(action_box)
		action_box.add_child(_button("Face them again", _retry))
		action_box.add_child(_button("Reset hero", _reset_hero))

func _check_level_up() -> void:
	while xp >= _xp_needed():
		xp -= _xp_needed()
		level += 1
		points += 2
		hero.max_hp += 12
		hero.max_mp += 4
		hero.hp = mini(hero.max_hp, hero.hp + 12)
		hero.mp = mini(hero.max_mp, hero.mp + 4)
		hero.attack += 2
		hero.defense += 1
		hero.magic += 2
		hero.speed += 1
		_add_log("Level %d! Stats rose; +2 points to assign." % level)

func _xp_needed() -> int:
	return 40 + (level - 1) * 30

func _show_stat_choices() -> void:
	_clear(target_box)
	target_box.add_child(_label("Assign 1 point:", 14, GOLD))
	for stat in ["attack", "defense", "magic", "speed", "max_hp"]:
		var label: String = "HP" if stat == "max_hp" else str(stat).capitalize()
		var key: String = str(stat)
		target_box.add_child(_button("+ " + label, func(): _assign_point(key)))

func _assign_point(stat: String) -> void:
	if points <= 0: return
	points -= 1
	if stat == "max_hp":
		hero.max_hp += 8
		hero.hp += 8
	else:
		hero[stat] += 1
	_add_log("Point assigned to %s." % stat)
	_clear(target_box)
	_show_actions()
	_refresh()

func _retry() -> void:
	_start_battle()

func _reset_hero() -> void:
	hero.hp = hero.max_hp
	hero.mp = hero.max_mp
	xp = 0
	level = 1
	points = 0
	hero.attack = 18
	hero.defense = 8
	hero.magic = 16
	hero.speed = 12
	hero.max_hp = 120
	hero.max_mp = 30
	_start_battle()

func _refresh() -> void:
	if not is_instance_valid(party_label): return
	party_label.text = "%s  Lv.%d\nHP  %d / %d\nMP  %d / %d\nATK %d  DEF %d\nMAG %d  SPD %d%s" % [hero.name, level, hero.hp, hero.max_hp, hero.mp, hero.max_mp, hero.attack, hero.defense, hero.magic, hero.speed, "\nGUARDING" if defended else ""]
	var enemy_text := ""
	for e in foes:
		var marker := "✦" if e.alive else "†"
		enemy_text += "%s %s  HP %d/%d  SPD %d\n" % [marker, e.name, e.hp, e.max_hp, e.speed]
	enemies_label.text = enemy_text
	var order: Array[Dictionary] = [hero]
	for e in foes:
		if e.alive: order.append(e)
	order.sort_custom(func(a, b): return a.progress > b.progress)
	var order_text := "TURN ORDER   "
	for f in order:
		order_text += "%s [%d%%]   " % ["YOU" if f == hero else f.name, clampi(int(f.progress), 0, 100)]
	turn_label.text = order_text
	xp_label.text = "Level %d   XP %d / %d   Stat points: %d" % [level, xp, _xp_needed(), points]
	_clear(stat_box)
	log_label.text = "\n".join(log_lines.slice(maxi(0, log_lines.size() - 3)))

func _add_log(line: String) -> void:
	log_lines.append(line)
	if log_lines.size() > 30: log_lines.pop_front()

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
