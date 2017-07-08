dofile(ModPath .. "lua/botweapons.lua")

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(...)
  local presets = _presets_original(self, ...)
  
  BotWeapons:log("Creating gang presets")
  
  -- gang_member presets
  local gang_presets = presets.weapon.gang_member

  -- pistols
  gang_presets.is_pistol.spread = gang_presets.is_rifle.spread * 0.75
  BotWeapons:set_recoil(gang_presets.is_pistol, {0.2, 0.3})
  
  gang_presets.is_revolver = deep_clone(gang_presets.is_pistol)
  BotWeapons:set_recoil(gang_presets.is_revolver, {0.5, 0.75})

  -- rifles
  BotWeapons:set_recoil(gang_presets.is_rifle, {0.25, 0.45})
  gang_presets.is_bullpup = gang_presets.is_rifle
  
  gang_presets.is_burst = deep_clone(gang_presets.is_rifle)
  gang_presets.is_burst.autofire_rounds = { 1, 3 }
  BotWeapons:set_recoil(gang_presets.is_burst, {0.5, 0.75})
  BotWeapons:set_mode(gang_presets.is_burst, {0, 0, 0, 1})
  
  -- smgs
  gang_presets.is_smg = gang_presets.is_rifle
  
  -- shotguns
  BotWeapons:set_recoil(gang_presets.is_shotgun_pump, {0.75, 1.125})
  gang_presets.is_shotgun_pump.spread = gang_presets.is_rifle.spread * 0.75

  gang_presets.is_shotgun = deep_clone(gang_presets.is_shotgun_pump)
  BotWeapons:set_recoil(gang_presets.is_shotgun, {0.4, 0.6})
  
  -- akimbo
  gang_presets.akimbo_pistol = deep_clone(gang_presets.is_pistol)
  BotWeapons:set_recoil(gang_presets.akimbo_pistol, {0.1, 0.2})
  
  gang_presets.akimbo_revolver = deep_clone(gang_presets.is_pistol)
  BotWeapons:set_recoil(gang_presets.akimbo_revolver, {0.3, 0.5})
  
  gang_presets.akimbo_smg = deep_clone(gang_presets.is_rifle)
  gang_presets.akimbo_smg.FALLOFF[#gang_presets.akimbo_smg.FALLOFF].acc = { 0.5, 0.7 }

  return presets
end