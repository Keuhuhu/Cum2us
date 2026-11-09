

## PLAN

Project Structure
```
res://
│
├── assets/
│   ├── characters/
│   │   ├── player/
│   │   ├── enemies/
│   │   └── npcs/
│   ├── tilesets/
│   ├── maps/
│   ├── items/
│   ├── skills/
│   ├── ui/
│   ├── effects/
│   ├── audio/
│   │   ├── bgm/
│   │   └── sfx/
│   └── fonts/
│
├── scenes/
│   ├── main/
│   │   ├── main_menu.tscn
│   │   └── game.tscn
│   │
│   ├── world/
│   │   ├── world.tscn
│   │   ├── maps/
│   │   └── objects/
│   │
│   ├── characters/
│   │   ├── player.tscn
│   │   ├── enemy.tscn
│   │   └── npc.tscn
│   │
│   ├── battle/
│   │   ├── battle.tscn
│   │   ├── components/
│   │   └── effects/
│   │
│   └── ui/
│       ├── inventory/
│       ├── character/
│       ├── equipment/
│       ├── skills/
│       ├── quest/
│       ├── dialogue/
│       └── common/
│
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd
│   │   ├── scene_manager.gd
│   │   ├── save_manager.gd
│   │   ├── audio_manager.gd
│   │   └── time_manager.gd
│   │
│   ├── character/
│   │   ├── character.gd
│   │   ├── character_stats.gd
│   │   └── character_controller.gd
│   │
│   ├── battle/
│   │   ├── battle_manager.gd
│   │   ├── turn_manager.gd
│   │   ├── action_manager.gd
│   │   ├── damage_calculator.gd
│   │   └── battle_effect_manager.gd
│   │
│   ├── inventory/
│   │   ├── inventory_manager.gd
│   │   └── inventory_slot.gd
│   │
│   ├── equipment/
│   ├── skills/
│   ├── quest/
│   ├── dialogue/
│   └── world/
│
├── resources/
│   ├── characters/
│   ├── enemies/
│   ├── items/
│   ├── equipment/
│   ├── skills/
│   ├── classes/
│   ├── quests/
│   └── status_effects/
│
├── data/
│   ├── databases/
│   ├── localization/
│   └── configuration/
│
├── addons/
│
└── project.godot
```

Detailed Structure

Character
```
character/
├── character.gd
├── character_instance.gd
├── character_stats.gd
├── character_class.gd
├── character_data.gd
├── components/
│   ├── health_component.gd
│   ├── energy_component.gd
│   └── status_component.gd
└── resources/
    ├── player/
    ├── enemies/
    └── npcs/
```

Battle
```
battle/
├── battle_manager.gd
├── turn_manager.gd
├── action_manager.gd
├── damage_calculator.gd
├── target_selector.gd
├── battle_action.gd
├── battle_context.gd
├── components/
│   ├── battle_character.gd
│   └── battle_status.gd
└── resources/
    ├── battle_config.gd
    └── battle_rewards.gd
```

Inventory
```
inventory/
├── inventory_manager.gd
├── inventory_data.gd
├── inventory_slot.gd
├── item_data.gd
├── item_effect.gd
└── resources/
    ├── consumables/
    ├── materials/
    └── quest_items/
```

Equipment
```
equipment/
├── equipment_manager.gd
├── equipment_data.gd
├── equipment_slot.gd
└── resources/
    ├── weapons/
    ├── armors/
    ├── accessories/
    └── shields/
```

Skills
```
skills/
├── skill_manager.gd
├── skill_data.gd
├── skill_effect.gd
├── skill_executor.gd
└── resources/
    ├── physical/
    ├── magical/
    ├── healing/
    └── passive/
```

World and Quest
```
world/
├── world_manager.gd
├── map_manager.gd
├── interaction_manager.gd
├── transition_manager.gd
└── resources/
    ├── maps/
    └── encounters/

quest/
├── quest_manager.gd
├── quest_data.gd
├── quest_objective.gd
└── resources/
    ├── main_quests/
    └── side_quests/
```


# Sistem dan Tanggung Jawab
```
Sistem	        Tanggung jawab
Character	    Identitas dan status karakter
Stats	        HP, MP, ATK, DEF, AGI, dll.
Class	        Job dan perkembangan karakter
Battle	        Pertarungan turn-based
Skills	        Skill aktif dan pasif
Status          Effects	Poison, Burn, Stun, dll.
Inventory	    Penyimpanan item
Equipment	    Weapon, Armor, Accessory
Quest	        Main quest dan side quest
Dialogue	    Dialog NPC
World	        Eksplorasi dan interaksi
Save	        Save dan load progress
Time	        Sistem waktu dalam game
```

## Effect system

`EffectData` adalah definisi statis yang dapat dipakai ulang oleh item, skill, equipment, musuh, atau interaksi lingkungan. `EffectContext` membawa source, target, origin, dan data tambahan. `EffectExecutor` menjalankan satu atau banyak efek secara berurutan dan berhenti pada hasil gagal. `EffectResult` melaporkan keberhasilan dan jumlah yang diterapkan.

Efek instan yang tersedia: `HealEffect`, `DamageEffect`, `RestoreManaEffect`, `BuffEffect`, `DebuffEffect`, dan `RemoveStatusEffect`. Status tersedia sebagai definisi `PoisonEffect`, `BurnEffect`, `RegenerationEffect`, dan `StunEffect`. Status memiliki durasi serta aturan `REPLACE`, `REFRESH_DURATION`, atau `ADD_STACK`; `EffectExecutor.execute_status_turns(target)` menjalankan tick dan menghapus status setelah durasinya habis. Untuk pemrosesan status yang konsisten, panggil fungsi ini sekali pada titik tick turn yang ditentukan battle system.

Durasi buff/debuff `0` berarti perubahan permanen. Actor yang menerapkan `change_stat` menentukan cara menyimpan stat sementara dan mengembalikannya saat durasi habis.

`EffectTarget` adalah adapter bertipe antara effect dan actor. Implementasi actor harus menyediakan operasi HP, MP, stat, serta skip turn. Adapter dasar menyimpan status runtime per target; `EffectStatusInstance` menyimpan definisi, source, durasi tersisa, dan jumlah stack. Resource effect tidak menyimpan state runtime.

### Integrasi yang tersedia saat ini

Proyek belum memiliki `Character`, `CharacterInstance`, `CharacterStats`, battle loop, SkillData, EquipmentData, atau inventory runtime. `CharacterData` hanya mendeskripsikan stat awal dan tidak memiliki method untuk mengubah HP/MP. Karena itu belum ada actor konkret untuk menghubungkan ke `EffectTarget`; implementasi adapter harus memanggil method actor yang kelak dibuat. Data `ItemData.effects` sudah memakai typed array `EffectData`, tetapi pemakaian item belum mengeksekusi effect karena belum ada sistem inventory/runtime.

### Contoh pemakaian

Item menyimpan resource effect, lalu sistem pemanggil membentuk context dan memanggil executor:

```gdscript
var context := EffectContext.new(target_adapter, user, EffectContext.Origin.ITEM)
var results := EffectExecutor.new().execute_many(item.effects, context)
```

Skill atau equipment dapat menyimpan array `EffectData` yang sama dan memakai executor identik dengan origin masing-masing. Contoh `.tres` tersedia di `resources/effects/`; item potion saat ini mereferensikan Heal/RestoreMana resource yang sama.

Contoh payload skill yang menyembuhkan sekaligus menghapus Poison:

```gdscript
var skill_effects: Array[EffectData] = [
	load("res://resources/effects/healing/heal_50.tres"),
	load("res://resources/effects/healing/remove_poison.tres"),
]
var context := EffectContext.new(target_adapter, caster, EffectContext.Origin.SKILL)
var results := EffectExecutor.new().execute_many(skill_effects, context)
```

