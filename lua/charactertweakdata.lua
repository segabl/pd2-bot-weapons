dofile(ModPath .. "lua/botweapons.lua")

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(...)
  local presets = _presets_original(self, ...)
  -- gang_member presets
  -- pistols
  presets.weapon.gang_member.beretta92.spread = presets.weapon.gang_member.m4.spread * 0.5
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.beretta92, {0.2, 0.3})
  
  presets.weapon.gang_member.c45 = presets.weapon.gang_member.beretta92

  presets.weapon.gang_member.raging_bull = deep_clone(presets.weapon.gang_member.beretta92)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.raging_bull, {0.5, 1})
  
  presets.weapon.gang_member.glock18 = presets.weapon.gang_member.m4
  
  -- rifles  
  presets.weapon.gang_member.ak47 = presets.weapon.gang_member.m4

  presets.weapon.gang_member.m14 = deep_clone(presets.weapon.gang_member.beretta92)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.m14, {0.1, 0.25})
  
  -- smgs
  presets.weapon.gang_member.mp5 = presets.weapon.gang_member.m4
  
  -- lmgs
  presets.weapon.gang_member.lmg = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.lmg.autofire_rounds = { 15, 40 }
  
  -- shotguns
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.r870, {0.5, 1})
  
  presets.weapon.gang_member.benelli = deep_clone(presets.weapon.gang_member.r870)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.benelli, {0.25, 0.5})

  presets.weapon.gang_member.mossberg = deep_clone(presets.weapon.gang_member.r870)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.mossberg, {0.25, 0.5})
  
  -- auto shotguns
  presets.weapon.gang_member.saiga = deep_clone(presets.weapon.gang_member.benelli)
  presets.weapon.gang_member.saiga.autofire_rounds = { 1, 5 }
  
  -- akimbo
  presets.weapon.gang_member.akimbo_pistol = deep_clone(presets.weapon.gang_member.beretta92)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.akimbo_pistol, {0.1, 0.2}, {0.5, 1})
  
  presets.weapon.gang_member.akimbo_auto = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.akimbo_auto.autofire_rounds = { 10, 25 }
  
  -- snipers
  presets.weapon.gang_member.rifle = deep_clone(presets.weapon.gang_member.raging_bull)
  presets.weapon.gang_member.rifle.spread = presets.weapon.gang_member.m4.spread * 0.5
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.rifle, {1, 1})
  
  -- create better range interpolation
  BotWeapons:create_interpolated_falloff_data(presets.weapon.gang_member, 10)
  
  return presets
end