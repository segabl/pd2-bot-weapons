dofile(ModPath .. "lua/botweapons.lua")

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(...)
  local presets = _presets_original(self, ...)
  -- gang_member presets
  local m4_spread = presets.weapon.gang_member.m4.spread
  -- pistols
  presets.weapon.gang_member.beretta92.spread = m4_spread * 0.5
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.beretta92, {{0.2, 0.45}, {0.25, 1}, {1, 2}})
  
  presets.weapon.gang_member.c45 = presets.weapon.gang_member.beretta92

  presets.weapon.gang_member.raging_bull = deep_clone(presets.weapon.gang_member.beretta92)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.raging_bull, {{0.5, 1}, {0.75, 2}, {2, 3}})
  
  presets.weapon.gang_member.glock18 = presets.weapon.gang_member.m4
  
  -- rifles 
  presets.weapon.gang_member.ak47 = presets.weapon.gang_member.m4

  presets.weapon.gang_member.g36 = presets.weapon.gang_member.m4

  presets.weapon.gang_member.scar = presets.weapon.gang_member.m4

  presets.weapon.gang_member.m14 = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.m14.autofire_rounds = nil
  
  -- smgs
  presets.weapon.gang_member.mp5 = presets.weapon.gang_member.m4
  
  presets.weapon.gang_member.mac11 = presets.weapon.gang_member.mp4
  
  presets.weapon.gang_member.p90 = presets.weapon.gang_member.mp4
  
  -- lmgs
  presets.weapon.gang_member.lmg = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.lmg.autofire_rounds = { 15, 40 }
  BotWeapons:set_auto_fire_mode(presets.weapon.gang_member.lmg, {{0, 0, 0, 1}, {0, 0, 0.5, 1}, {0, 0, 1, 0}})
  
  -- shotguns
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.r870, {{0.75, 1}, {1, 2}})
  
  presets.weapon.gang_member.benelli = deep_clone(presets.weapon.gang_member.r870)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.benelli, {{0.25, 0.5}, {0.25, 0.75}, {0.5, 1.5}})

  presets.weapon.gang_member.mossberg = deep_clone(presets.weapon.gang_member.r870)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.mossberg, {{0.25, 0.5}, {0.5, 2}})
  
  -- auto shotguns
  presets.weapon.gang_member.saiga = deep_clone(presets.weapon.gang_member.benelli)
  presets.weapon.gang_member.saiga.autofire_rounds = { 3, 6 }
  BotWeapons:set_auto_fire_mode(presets.weapon.gang_member.saiga, {{0, 0.33, 0.66, 1}, {0.33, 0.66, 1, 0}, {0.66, 1, 0, 0}})
  
  -- akimbo
  presets.weapon.gang_member.akimbo_pistol = deep_clone(presets.weapon.gang_member.beretta92)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.akimbo_pistol, {{0.1, 0.2}, {0.2, 0.4}, {0.4, 0.7}})
  
  presets.weapon.gang_member.akimbo_auto = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.akimbo_auto.autofire_rounds = { 10, 25 }
  
  -- snipers
  presets.weapon.gang_member.rifle = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.rifle.spread = m4_spread * 0.25
  presets.weapon.gang_member.rifle.autofire_rounds = nil
  
  return presets
end