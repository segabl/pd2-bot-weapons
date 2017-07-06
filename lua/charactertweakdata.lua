dofile(ModPath .. "lua/botweapons.lua")

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(...)
  local presets = _presets_original(self, ...)
  
  BotWeapons:log("Creating gang presets")
  
  -- gang_member presets
  local gang_presets = presets.weapon.gang_member

  -- pistols
  gang_presets.is_pistol.spread = gang_presets.is_rifle.spread * 0.75
  BotWeapons:set_single_fire_mode(gang_presets.is_pistol, {0.2, 0.3})
  
  gang_presets.is_revolver = deep_clone(gang_presets.is_pistol)
  BotWeapons:set_single_fire_mode(gang_presets.is_revolver, {0.5, 0.75})

  -- rifles
  BotWeapons:set_single_fire_mode(gang_presets.is_rifle, {0.25, 0.45})
  gang_presets.is_bullpup = gang_presets.is_rifle
  
  gang_presets.is_burst = deep_clone(gang_presets.is_rifle)
  gang_presets.is_burst.spread = gang_presets.is_rifle.spread * 0.75
  gang_presets.is_burst.autofire_rounds = { 3, 4 }
  BotWeapons:set_single_fire_mode(gang_presets.is_burst, {0.75, 1})
  
  -- smgs
  gang_presets.is_smg = gang_presets.is_rifle
  
  -- lmgs
  --gang_presets.is_lmg = deep_clone(gang_presets.is_rifle)
  --gang_presets.lmg.autofire_rounds = { 15, 40 }
  --gang_presets.lmg.FALLOFF[#gang_presets.lmg.FALLOFF].acc = { 0.5, 0.5 }
  
  -- shotguns
  BotWeapons:set_single_fire_mode(gang_presets.is_shotgun_pump, {0.75, 1.125})
  gang_presets.is_shotgun_pump.spread = gang_presets.is_rifle.spread * 0.75

  gang_presets.is_shotgun = deep_clone(gang_presets.is_shotgun_pump)
  BotWeapons:set_single_fire_mode(gang_presets.mossberg, {0.4, 0.6})
  
  -- auto shotguns
  --gang_presets.saiga = deep_clone(gang_presets.mossberg)
  --gang_presets.saiga.autofire_rounds = { 2, 5 }
  
  -- akimbo
  gang_presets.akimbo_pistol = deep_clone(gang_presets.is_pistol)
  BotWeapons:set_single_fire_mode(gang_presets.akimbo_pistol, {0.1, 0.2})
  
  gang_presets.akimbo_deagle = deep_clone(gang_presets.is_pistol)
  BotWeapons:set_single_fire_mode(gang_presets.akimbo_deagle, {0.3, 0.5})
  
  gang_presets.akimbo_auto = deep_clone(gang_presets.is_rifle)
  gang_presets.akimbo_auto.autofire_rounds = { 10, 25 }
  gang_presets.akimbo_auto.FALLOFF[#gang_presets.akimbo_auto.FALLOFF].acc = { 0.8, 0.8 }
  
  -- snipers
  gang_presets.is_sniper.spread = gang_presets.is_rifle.spread * 0.75
  
  -- create better range interpolation
  BotWeapons:create_interpolated_falloff_data(gang_presets, 10)

  return presets
end