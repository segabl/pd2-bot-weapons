dofile(ModPath .. "lua/botweapons.lua")

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(...)
  log("[BotWeapons] Setting up weapon presets")
  local presets = _presets_original(self, ...)
  
  -- loop through all weapon presets and create new presets from old ones for all the weapons
  -- that are used by cops and not only team AI so to not mess with any existing presets
  for k, v in pairs(presets.weapon) do
    if v.m4 then
      v.g36 = deep_clone(v.m4)
      v.scar = deep_clone(v.m4)
    end

    if v.ak47 then
      v.m249 = deep_clone(v.ak47)
    end
  end
  
  -- gang_member presets
  -- pistols
  presets.weapon.gang_member.beretta92.spread = 10
  presets.weapon.gang_member.beretta92.range = { close = 2000, optimal = 3500, far = 7000 }
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.beretta92, 6, false)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.beretta92, 1.5)
  
  presets.weapon.gang_member.c45 = deep_clone(presets.weapon.gang_member.beretta92)
  
  presets.weapon.gang_member.raging_bull = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.raging_bull.RELOAD_SPEED = 0.5
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.raging_bull, 4, false)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.raging_bull, 1)
  -- rifles
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.m4, 4, false)
  
  presets.weapon.gang_member.ak47 = deep_clone(presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.ak47, 1.35, false)
  
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.g36, 1.35, false)
  
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.scar, 2, false)
  
  presets.weapon.gang_member.m14 = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.m14.RELOAD_SPEED = 0.4
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.m14, { 0.2, 0.5 }, { 0.75, 2 }, { 2, 3 })
  -- smgs
  presets.weapon.gang_member.mp5 = deep_clone(presets.weapon.gang_member.m4)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.mp5, 0.85)
  
  presets.weapon.gang_member.p90 = deep_clone(presets.weapon.gang_member.mp5)
  presets.weapon.gang_member.p90.RELOAD_SPEED = 0.5
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.p90, 0.7)
  -- lmgs
  presets.weapon.gang_member.m249 = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.m249.autofire_rounds = { 15, 40 }
  presets.weapon.gang_member.m249.RELOAD_SPEED = 0.4
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.m249, 2, false)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.m249, 0.4)
  BotWeapons:set_auto_fire_mode(presets.weapon.gang_member.m249, { 0, 0, 0, 1 }, { 0, 0, 0.5, 1 }, { 0, 0, 1, 0 })
  -- shotguns
  presets.weapon.gang_member.r870.FALLOFF[1].r = 500
  presets.weapon.gang_member.r870.FALLOFF[2].r = 2000
  presets.weapon.gang_member.r870.FALLOFF[3].r = 4000
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.r870, 2, true)
  
  presets.weapon.gang_member.mossberg = deep_clone(presets.weapon.gang_member.r870)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.mossberg, 3, true)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.mossberg, { 0.25, 0.5 }, { 0.5, 2 })
  
  presets.weapon.gang_member.judge = deep_clone(presets.weapon.gang_member.raging_bull)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.judge, 4, true)
  -- auto shotguns
  presets.weapon.gang_member.saiga = deep_clone(presets.weapon.gang_member.r870)
  presets.weapon.gang_member.saiga.RELOAD_SPEED = 0.5
  presets.weapon.gang_member.saiga.autofire_rounds = { 4, 7 }
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.saiga, 1.5, true)
  BotWeapons:set_auto_fire_mode(presets.weapon.gang_member.saiga, { 0, 0.33, 0.66, 1 }, { 0.33, 0.66, 1, 0 }, { 0.66, 1, 0, 0 })
  -- akimbo
  presets.weapon.gang_member.akimbo_pistol = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.akimbo_pistol.RELOAD_SPEED = 0.5
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.akimbo_pistol, 0.9)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.akimbo_pistol, { 0.1, 0.2 }, { 0.2, 0.75 }, { 1, 2 })
  
  presets.weapon.gang_member.akimbo_auto = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.akimbo_auto.RELOAD_SPEED = 0.3
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.akimbo_auto, 0.6)
  
  return presets
end

local _init_tank_original = CharacterTweakData._init_tank
function CharacterTweakData:_init_tank(...)
  _init_tank_original(self, ...)
  -- transfer ak47 weapon settings to new m249 preset
  self.tank.weapon.m249 = deep_clone(self.tank.weapon.ak47)
end

local _init_mobster_boss_original = CharacterTweakData._init_mobster_boss
function CharacterTweakData:_init_mobster_boss(...)
  _init_mobster_boss_original(self, ...)
  -- transfer ak47 weapon settings to new m249 preset
  self.mobster_boss.weapon.m249 = deep_clone(self.mobster_boss.weapon.ak47)
end

local _init_biker_boss_original = CharacterTweakData._init_biker_boss
function CharacterTweakData:_init_biker_boss(...)
  _init_biker_boss_original(self, ...)
  -- transfer ak47 weapon settings to new m249 preset
  self.biker_boss.weapon.m249 = deep_clone(self.biker_boss.weapon.ak47)
end