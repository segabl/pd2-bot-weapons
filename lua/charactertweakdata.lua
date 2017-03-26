dofile(ModPath .. "lua/botweapons.lua")

local init_original = CharacterTweakData.init
function CharacterTweakData:init(...)
  init_original(self, ...)
  -- link new weapon presets to existing ones for characters that don't have them yet
  for _, v in pairs(self) do
    if type(v) == "table" and v.weapon then
      v.weapon.benelli = v.weapon.benelli or v.weapon.r870
      v.weapon.g36 = v.weapon.g36 or v.weapon.m4
      v.weapon.scar = v.weapon.scar or v.weapon.m4
      v.weapon.lmg = v.weapon.lmg or v.weapon.ak47
    end
  end
end

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(...)
  local presets = _presets_original(self, ...)
  -- gang_member presets
  local m4_dmg_mul = presets.weapon.gang_member.m4.FALLOFF[1].dmg_mul
  -- pistols
  presets.weapon.gang_member.beretta92.range = { close = 2000, optimal = 3500, far = 7000 }
  presets.weapon.gang_member.beretta92.spread = presets.weapon.gang_member.beretta92.spread * 0.5
  BotWeapons:copy_falloff(presets.weapon.gang_member.beretta92, presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.beretta92, m4_dmg_mul * 1.5)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.beretta92, 1.5)
  
  presets.weapon.gang_member.c45 = deep_clone(presets.weapon.gang_member.beretta92)
  
  presets.weapon.gang_member.raging_bull = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.raging_bull.RELOAD_SPEED = 0.6
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.raging_bull, m4_dmg_mul * 0.7)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.raging_bull, { { 0.5, 1 }, { 0.75, 2 } })
  
  -- rifles
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.m4, 1.25)
  
  presets.weapon.gang_member.ak47 = deep_clone(presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.ak47, m4_dmg_mul * 0.3)
  
  presets.weapon.gang_member.g36 = deep_clone(presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.g36, m4_dmg_mul * 0.3)
  
  presets.weapon.gang_member.scar = deep_clone(presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.scar, m4_dmg_mul * 0.5)
  
  presets.weapon.gang_member.m14 = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.m14.RELOAD_SPEED = 0.5
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.m14, 1.25)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.m14, m4_dmg_mul * 0.6)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.m14, { { 0.2, 0.3 }, { 0.5, 1 }, { 1, 2 } })
  
  -- smgs
  presets.weapon.gang_member.mp5 = deep_clone(presets.weapon.gang_member.m4)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.mp5, 1)
  
  presets.weapon.gang_member.mac11 = deep_clone(presets.weapon.gang_member.mp5)
  
  presets.weapon.gang_member.p90 = deep_clone(presets.weapon.gang_member.mp5)
  presets.weapon.gang_member.p90.RELOAD_SPEED = 0.6
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.p90, 0.9)
  
  -- lmgs
  presets.weapon.gang_member.lmg = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.lmg.autofire_rounds = { 15, 40 }
  presets.weapon.gang_member.lmg.RELOAD_SPEED = 0.5
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.lmg, m4_dmg_mul * 0.4)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.lmg, 0.6)
  BotWeapons:set_auto_fire_mode(presets.weapon.gang_member.lmg, { { 0, 0, 0, 1 }, { 0, 0, 0.5, 1 }, { 0, 0, 1, 0 } })
  
  -- shotguns
  presets.weapon.gang_member.r870.range = { close = 750, optimal = 1500, far = 4000 }
  BotWeapons:copy_falloff(presets.weapon.gang_member.r870, presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.r870, m4_dmg_mul * 0.6)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.r870, { { 0.75, 1 }, { 1, 2 } })
  
  presets.weapon.gang_member.benelli = deep_clone(presets.weapon.gang_member.r870)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.benelli, m4_dmg_mul * 0.4)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.benelli, { { 0.25, 0.5 }, { 0.25, 0.75 }, { 0.5, 1.5 } })

  presets.weapon.gang_member.mossberg = deep_clone(presets.weapon.gang_member.r870)
  presets.weapon.gang_member.mossberg.RELOAD_SPEED = 0.8
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.mossberg, m4_dmg_mul * 0.7)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.mossberg, { { 0.25, 0.5 }, { 0.5, 2 } })
  
  presets.weapon.gang_member.judge = deep_clone(presets.weapon.gang_member.benelli)
  presets.weapon.gang_member.judge.RELOAD_SPEED = 1
  
  -- auto shotguns
  presets.weapon.gang_member.saiga = deep_clone(presets.weapon.gang_member.benelli)
  presets.weapon.gang_member.saiga.RELOAD_SPEED = 0.5
  presets.weapon.gang_member.saiga.autofire_rounds = { 4, 7 }
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.saiga, m4_dmg_mul * 0.5)
  BotWeapons:set_auto_fire_mode(presets.weapon.gang_member.saiga, { { 0, 0.33, 0.66, 1 }, { 0.33, 0.66, 1, 0 }, { 0.66, 1, 0, 0 } })
  
  -- akimbo
  presets.weapon.gang_member.akimbo_pistol = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.akimbo_pistol.RELOAD_SPEED = 0.6
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.akimbo_pistol, 1)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.akimbo_pistol, m4_dmg_mul)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.akimbo_pistol, { { 0.1, 0.2 }, { 0.2, 0.4 }, { 0.4, 0.7 } })
  
  presets.weapon.gang_member.akimbo_auto = deep_clone(presets.weapon.gang_member.mp5)
  presets.weapon.gang_member.akimbo_auto.RELOAD_SPEED = 0.4
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.akimbo_auto, 0.8)
  
  -- snipers
  presets.weapon.gang_member.sniper = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.sniper.range = { close = 5000, optimal = 10000, far = 15000 }
  presets.weapon.gang_member.sniper.RELOAD_SPEED = 0.4
  presets.weapon.gang_member.sniper.spread = presets.weapon.gang_member.sniper.spread * 0.5
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.sniper, m4_dmg_mul * 4)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.sniper, 3)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.sniper, { { 2, 3 }, { 3, 4 }, { 4, 5 } })
  
  return presets
end