dofile(ModPath .. "botweapons.lua")

local _create_table_structure_original = WeaponTweakData._create_table_structure
function WeaponTweakData:_create_table_structure(...)
  _create_table_structure_original(self, ...)
  -- copy animations from usage
  for k, v in pairs(self) do
    if type(v) == "table" and k:match("_crew$") and v.anim_usage == nil then
      v.anim_usage = v.usage
    end
  end
end

local init_original = WeaponTweakData.init
function WeaponTweakData:init(...)
  init_original(self, ...)
  
  BotWeapons:log("Setting up weapons")

  -- manual stuff fixing
  self.siltstone_crew.pull_magazine_during_reload = "rifle"
  self.erma_crew.anim_usage = "is_smg"
  self.erma_crew.usage = "is_smg"
  self.ching_crew.usage = "is_sniper_fast"
  self.ching_crew.pull_magazine_during_reload = nil
  self.rota_crew.usage = "is_shotgun"
  self.deagle_crew.usage = "is_revolver"
  self.g22c_crew.auto = nil
  self.usp_crew.auto = nil
  self.desertfox_crew.auto = { fire_rate = 1 }
  
  local m4_dps = self.m4_crew.DAMAGE / self.m4_crew.auto.fire_rate

  for k, v in pairs(self) do
    if type(v) == "table" and k:match("_crew$") then
      -- fix auto akimbo fire rates
      if k:match("^x_") and self[k:gsub("^x_", "")] then
        v.auto = self[k:gsub("^x_", "")].auto or v.auto
        if v.auto and v.auto.fire_rate then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"akimbo_smg\"", BotWeapons.debug and v.usage ~= "akimbo_smg")
          v.usage = "akimbo_smg"
        end 
      end
      -- fix shotguns
      if v.is_shotgun and v.usage ~= "is_shotgun_pump" and v.usage ~= "is_shotgun" and v.usage ~= "is_shotgun_mag" then
        v.usage = "is_shotgun"
      end
      -- fix auto damage and presets (use is_bullpup as burst fire preset)
      if v.auto and v.auto.fire_rate and not v.is_shotgun then
        if v.CLIP_AMMO_MAX >= 100 then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_lmg\"", BotWeapons.debug and v.usage ~= "is_lmg")
          v.usage = "is_lmg"
        elseif v.usage == "is_pistol" then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_smg\"", BotWeapons.debug and v.usage ~= "is_smg")
          v.usage = "is_smg"
        elseif (v.usage == "is_rifle" or v.usage == "is_bullpup") and v.CLIP_AMMO_MAX < 20 then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_bullpup\"", BotWeapons.debug and v.usage ~= "is_bullpup")
          v.usage = "is_bullpup"
        elseif v.usage == "is_bullpup" then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_rifle\"", BotWeapons.debug and v.usage ~= "is_rifle")
          v.usage = "is_rifle"
        end
        v.DAMAGE = v.usage == "is_bullpup" and m4_dps * v.auto.fire_rate * 3 or m4_dps * v.auto.fire_rate
      end
      -- fix pistol damage
      if v.usage == "is_pistol" or v.usage == "is_revolver" then
        if v.CLIP_AMMO_MAX <= 6 then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_revolver\"", BotWeapons.debug and v.usage ~= "is_revolver")
          v.usage = "is_revolver"
        end
        v.DAMAGE = v.usage == "is_revolver" and m4_dps * 0.5 or m4_dps * 0.2
      end
      -- fix akimbo pistol damage
      if v.usage == "akimbo_pistol" then
        local single = self[k:gsub("^x_", "")]
        if single and (single.CLIP_AMMO_MAX <= 6 or single.usage == "is_revolver") then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"akimbo_revolver\"", BotWeapons.debug and v.usage ~= "akimbo_revolver")
          v.usage = "akimbo_revolver"
        end
        v.DAMAGE = v.usage == "akimbo_revolver" and m4_dps * 0.3 or m4_dps * 0.1
      end
      -- fix shotgun damage
      if v.is_shotgun and (v.usage == "is_shotgun_pump" or v.usage == "is_shotgun") then
        if v.CLIP_AMMO_MAX <= 2 or v.auto and v.auto.fire_rate and v.auto.fire_rate <= 0.5 then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_shotgun\"", BotWeapons.debug and v.usage ~= "is_shotgun")
          v.usage = "is_shotgun"
          v.DAMAGE = v.CLIP_AMMO_MAX <= 2 and m4_dps * 0.8 or m4_dps * 0.4
          v.auto = {}
        else
          v.DAMAGE = "is_shotgun" and m4_dps * 0.4 or m4_dps * 0.75
        end
      end
      -- fix sniper damage
      if v.usage == "is_sniper" or v.usage == "is_sniper_fast" then
        if v.auto and v.auto.fire_rate and v.auto.fire_rate <= 0.5 then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_sniper_fast\"", BotWeapons.debug and v.usage ~= "is_sniper_fast")
          v.usage = "is_sniper_fast"
          v.DAMAGE = m4_dps * 0.5
        else
          v.DAMAGE = m4_dps * 1.25
        end
        v.auto = {}
      end
      
    end
  end
end