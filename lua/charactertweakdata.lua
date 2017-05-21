dofile(ModPath .. "lua/botweapons.lua")

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(...)
  local presets = _presets_original(self, ...)
  
  BotWeapons:log("Creating gang presets")
  
  -- gang_member presets
  local gang_presets = presets.weapon.gang_member
  
  -- pistols
  gang_presets.beretta92.spread = gang_presets.m4.spread * 0.75
  BotWeapons:set_single_fire_mode(gang_presets.beretta92, {0.2, 0.3})
  
  gang_presets.c45 = gang_presets.beretta92

  gang_presets.raging_bull = deep_clone(gang_presets.beretta92)
  BotWeapons:set_single_fire_mode(gang_presets.raging_bull, {0.5, 0.75})
  
  gang_presets.glock18 = gang_presets.m4
  
  -- rifles  
  gang_presets.ak47 = gang_presets.m4

  gang_presets.m14 = deep_clone(gang_presets.m4)
  gang_presets.m14.spread = gang_presets.m4.spread * 0.75
  gang_presets.m14.autofire_rounds = { 3, 4 }
  BotWeapons:set_single_fire_mode(gang_presets.m14, {0.5, 0.75})
  BotWeapons:set_auto_fire_mode(gang_presets.m14, {1, 0, 0, 0.25})
  
  -- smgs
  gang_presets.mp5 = gang_presets.m4
  
  -- lmgs
  gang_presets.lmg = deep_clone(gang_presets.m4)
  gang_presets.lmg.autofire_rounds = { 15, 40 }
  gang_presets.lmg.FALLOFF[#gang_presets.lmg.FALLOFF].acc = { 0.5, 0.5 }
  
  -- shotguns
  BotWeapons:set_single_fire_mode(gang_presets.r870, {0.75, 1.125})
  gang_presets.r870.spread = gang_presets.m4.spread * 0.75

  gang_presets.mossberg = deep_clone(gang_presets.r870)
  BotWeapons:set_single_fire_mode(gang_presets.mossberg, {0.4, 0.6})
  
  -- auto shotguns
  gang_presets.saiga = deep_clone(gang_presets.mossberg)
  gang_presets.saiga.autofire_rounds = { 2, 5 }
  
  -- akimbo
  gang_presets.akimbo_pistol = deep_clone(gang_presets.beretta92)
  BotWeapons:set_single_fire_mode(gang_presets.akimbo_pistol, {0.1, 0.2})
  
  gang_presets.akimbo_deagle = deep_clone(gang_presets.beretta92)
  BotWeapons:set_single_fire_mode(gang_presets.akimbo_deagle, {0.3, 0.5})
  
  gang_presets.akimbo_auto = deep_clone(gang_presets.m4)
  gang_presets.akimbo_auto.autofire_rounds = { 10, 25 }
  gang_presets.akimbo_auto.FALLOFF[#gang_presets.akimbo_auto.FALLOFF].acc = { 0.8, 0.8 }
  
  -- snipers
  gang_presets.rifle = deep_clone(gang_presets.raging_bull)
  BotWeapons:set_single_fire_mode(gang_presets.rifle, {1, 1.5})
  
  -- create better range interpolation
  BotWeapons:create_interpolated_falloff_data(gang_presets, 10)
  
  return presets
end