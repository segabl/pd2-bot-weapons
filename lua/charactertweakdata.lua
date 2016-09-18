local _presetsORIG = CharacterTweakData._presets
function CharacterTweakData:_presets(tweak_data)
  log("[BotWeapons] Setting up additional npc weapon presets")
  local presets = _presetsORIG(self, tweak_data)
  
  -- loop through all weapon presets and create new presets from old ones for all the weapons
  -- that are used by AI other than team AI
  for k, v in pairs(presets.weapon) do
    if v.m4 ~= nil then
      v.g36 = deep_clone(v.m4)
      v.scar = deep_clone(v.m4)
    end

    if v.ak47 ~= nil then
      v.m249 = deep_clone(v.ak47)
    end
  end
  
  -- gang_member presets
  -- pistols
  presets.weapon.gang_member.beretta92.spread = 15
  presets.weapon.gang_member.c45 = deep_clone(presets.weapon.gang_member.beretta92)
  
  presets.weapon.gang_member.raging_bull = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.raging_bull.RELOAD_SPEED = 0.5
  presets.weapon.gang_member.raging_bull.spread = 20
  -- smgs
  presets.weapon.gang_member.mp5 = deep_clone(presets.weapon.gang_member.m4)
  -- rifles
  presets.weapon.gang_member.ak47 = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.m14 = deep_clone(presets.weapon.gang_member.raging_bull)
  presets.weapon.gang_member.m14.autofire_rounds = { 2, 4 }
  presets.weapon.gang_member.m14.FALLOFF[1].mode = { 1, 0.8, 0.6, 0.4 }
  presets.weapon.gang_member.m14.FALLOFF[2].mode = { 1, 0.4, 0.3, 0.1 }
  presets.weapon.gang_member.m14.FALLOFF[3].mode = { 1, 0.2, 0, 0 }
  -- lmg
  presets.weapon.gang_member.m249.autofire_rounds = { 20, 40 }
  presets.weapon.gang_member.m249.RELOAD_SPEED = 0.4
  presets.weapon.gang_member.m249.spread = 50
  presets.weapon.gang_member.m249.FALLOFF[1].acc = {0.3, 0.7}
  presets.weapon.gang_member.m249.FALLOFF[2].acc = {0.1, 0.2}
  presets.weapon.gang_member.m249.FALLOFF[3].acc = {0, 0.1}
  presets.weapon.gang_member.m249.FALLOFF[1].recoil = {0, 1}
  presets.weapon.gang_member.m249.FALLOFF[2].recoil = {1, 2}
  presets.weapon.gang_member.m249.FALLOFF[3].recoil = {2, 3}
  -- shotguns
  presets.weapon.gang_member.r870.FALLOFF[1].r = 600
  presets.weapon.gang_member.r870.FALLOFF[2].r = 2000
  presets.weapon.gang_member.r870.FALLOFF[3].r = 10000
  
  presets.weapon.gang_member.mossberg = deep_clone(presets.weapon.gang_member.r870)
  
  presets.weapon.gang_member.judge = deep_clone(presets.weapon.gang_member.r870)
  presets.weapon.gang_member.judge.RELOAD_SPEED = 0.7
  -- auto shotguns
  presets.weapon.gang_member.saiga = deep_clone(presets.weapon.gang_member.r870)
  presets.weapon.gang_member.saiga.RELOAD_SPEED = 0.5
  presets.weapon.gang_member.saiga.autofire_rounds = { 3, 7 }
  -- akimbo
  presets.weapon.gang_member.akimbo_pistol = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.akimbo_pistol.RELOAD_SPEED = 0.5
  
  presets.weapon.gang_member.akimbo_auto = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.akimbo_auto.RELOAD_SPEED = 0.3
  presets.weapon.gang_member.akimbo_auto.spread = 40
  presets.weapon.gang_member.akimbo_auto.FALLOFF[1].acc = {0.3, 0.7}
  presets.weapon.gang_member.akimbo_auto.FALLOFF[2].acc = {0.1, 0.2}
  presets.weapon.gang_member.akimbo_auto.FALLOFF[3].acc = {0, 0.1}
  presets.weapon.gang_member.akimbo_auto.FALLOFF[1].recoil = {0, 1}
  presets.weapon.gang_member.akimbo_auto.FALLOFF[2].recoil = {1, 2}
  presets.weapon.gang_member.akimbo_auto.FALLOFF[3].recoil = {2, 3}
  
  return presets
end

local _init_tankORIG = CharacterTweakData._init_tank
function CharacterTweakData:_init_tank(presets)
  _init_tankORIG(self, presets)
  -- transfer ak47 weapon settings to new m249 preset
  self.tank.weapon.m249 = deep_clone(self.tank.weapon.ak47)
end

local _init_mobster_bossORIG = CharacterTweakData._init_mobster_boss
function CharacterTweakData:_init_mobster_boss(presets)
  _init_mobster_bossORIG(self, presets)
  -- transfer ak47 weapon settings to new m249 preset
  self.mobster_boss.weapon.m249 = deep_clone(self.mobster_boss.weapon.ak47)
end

local _init_biker_bossORIG = CharacterTweakData._init_biker_boss
function CharacterTweakData:_init_biker_boss(presets)
  _init_biker_bossORIG(self, presets)
  -- transfer ak47 weapon settings to new m249 preset
  self.biker_boss.weapon.m249 = deep_clone(self.biker_boss.weapon.ak47)
end