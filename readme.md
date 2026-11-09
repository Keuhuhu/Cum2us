

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

