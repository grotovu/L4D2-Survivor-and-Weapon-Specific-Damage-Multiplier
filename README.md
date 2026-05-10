# L4D2 Survivor and Weapon Specific Damage Multiplier
Vibe coded with Gemini.

I wanted other characters to be tankier or squishier than others.

With this you can set Coach to receive 0.8x damage, and Rochelle receive 1.2x damage.

Or something silly like 999x or 0.01x.

You can also set for weapons equipped. Best example is the riot shield. If you have it equipped, you receive 0.5x damage. There’s no functionality to make it work while it’s on your back, though. So you won’t have damage reduction for not having it equipped and getting hit in the back.

Another example is having damage penalty for using certain weapons, like Magnum. If you use that weapon, you take 1.2x damage.

This plugin is handy for those playing with survivor skins and weapons skins and want them to actually have benefits or penalties for using them.

# Based on and inspired by these plugins:

By little_froy:  [L4D2] Survivor Bot Damage Taken Reduce Without Delay v1.0:
https://forums.alliedmods.net/showthread.php?p=2843329

By BatoSaiX:  [L4D2] Melee Damage Resistance (v1.0.0):
https://forums.alliedmods.net/showthread.php?p=2844089

# The cvars
```
//Damage is multiplied by this amount for this survivor.
survivor_damage_multi_bill "1.0"
survivor_damage_multi_coach "1.0"
survivor_damage_multi_ellis "1.0"
survivor_damage_multi_francis "1.0"
survivor_damage_multi_louis "1.0"
survivor_damage_multi_nick "1.0"
survivor_damage_multi_rochelle "1.0"
survivor_damage_multi_zoey "1.0"

//For enabling or disabling damage multiplier for having any melee equipped.
survivor_damage_melee_enable "1"

//Damage is multiplied by this amount regardless of which melee weapon is equipped.
survivor_damage_melee_multi_bill "1.0"
survivor_damage_melee_multi_coach "1.0"
survivor_damage_melee_multi_ellis "1.0"
survivor_damage_melee_multi_francis "1.0"
survivor_damage_melee_multi_louis "1.0"
survivor_damage_melee_multi_nick "1.0"
survivor_damage_melee_multi_rochelle "1.0"
survivor_damage_melee_multi_zoey "1.0"

//For enabling or disabling damage multiplier for equipping specific weapons
survivor_damage_weapon_enable "1"

//Damage is multiplied by this amount when currently using this weapon
survivor_damage_wep_multi_autoshotgun "1.0"
survivor_damage_wep_multi_bat "1.0"
survivor_damage_wep_multi_chainsaw "1.0"
survivor_damage_wep_multi_cricket_bat "1.0"
survivor_damage_wep_multi_crowbar "1.0"
survivor_damage_wep_multi_fireaxe "1.0"
survivor_damage_wep_multi_golfclub "1.0"
survivor_damage_wep_multi_grenade_launcher "1.0"
survivor_damage_wep_multi_guitar "1.0"
survivor_damage_wep_multi_hunting_rifle "1.0"
survivor_damage_wep_multi_katana "1.0"
survivor_damage_wep_multi_knife "1.0"
survivor_damage_wep_multi_m60 "1.0"
survivor_damage_wep_multi_machete "1.0"
survivor_damage_wep_multi_magnum "1.0"
survivor_damage_wep_multi_pan "1.0"
survivor_damage_wep_multi_pistol "1.0"
survivor_damage_wep_multi_pitchfork "1.0"
survivor_damage_wep_multi_pumpshotgun "1.0"
survivor_damage_wep_multi_rifle "1.0"
survivor_damage_wep_multi_rifle_ak47 "1.0"
survivor_damage_wep_multi_rifle_desert "1.0"
survivor_damage_wep_multi_rifle_sg552 "1.0"
survivor_damage_wep_multi_riotshield "1.0"
survivor_damage_wep_multi_shotgun_chrome "1.0"
survivor_damage_wep_multi_shotgun_spas "1.0"
survivor_damage_wep_multi_shovel "1.0"
survivor_damage_wep_multi_smg "1.0"
survivor_damage_wep_multi_smg_mp5 "1.0"
survivor_damage_wep_multi_smg_silenced "1.0"
survivor_damage_wep_multi_sniper_awp "1.0"
survivor_damage_wep_multi_sniper_military "1.0"
survivor_damage_wep_multi_sniper_scout "1.0"
survivor_damage_wep_multi_tonfa "1.0"
```
