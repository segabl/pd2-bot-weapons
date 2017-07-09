dofile(ModPath .. "lua/botweapons.lua")

local init_original = WeaponTweakData.init
function WeaponTweakData:init(...)
  init_original(self, ...)
  
  BotWeapons:log("Setting up weapons")

  -- copy reload animations from usage
  for k, v in pairs(self) do
    if type(v) == "table" and k:match("_crew$") then
      v.anim = v.usage
    end
  end
  
  -- manual stuff fixing
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
          --BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"akimbo_smg\"", v.usage ~= "akimbo_smg")
          v.usage = "akimbo_smg"
        end 
      end
      
      -- fix shotguns
      if v.is_shotgun and v.usage ~= "is_shotgun_pump" and v.usage ~= "is_shotgun" and v.usage ~= "is_shotgun_mag" then
        v.usage = "is_shotgun"
      end
    
      -- fix auto damage
      if v.auto and v.auto.fire_rate and not v.is_shotgun then
        if v.CLIP_AMMO_MAX >= 100 then
          --BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_lmg\"", v.usage ~= "is_lmg")
          v.usage = "is_lmg"
        elseif v.usage == "is_pistol" then
          --BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_smg\"", v.usage ~= "is_smg")
          v.usage = "is_smg"
        elseif (v.usage == "is_rifle" or v.usage == "is_bullpup") and v.CLIP_AMMO_MAX < 20 then
          --BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_burst\"", v.usage ~= "is_burst")
          v.usage = "is_burst"
        end
        v.DAMAGE = v.usage == "is_burst" and m4_dps * v.auto.fire_rate * 3 or m4_dps * v.auto.fire_rate
      end
      
      -- fix pistol damage
      if v.usage == "is_pistol" or v.usage == "is_revolver" then
        if v.CLIP_AMMO_MAX <= 6 then
          --BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_revolver\"", v.usage ~= "is_revolver")
          v.usage = "is_revolver"
        end
        v.DAMAGE = v.usage == "is_revolver" and m4_dps * 0.5 or m4_dps * 0.2
      end
      
      -- fix akimbo pistol damage
      if v.usage == "akimbo_pistol" then
        local single = self[k:gsub("^x_", "")]
        if single and (single.CLIP_AMMO_MAX <= 6 or single.usage == "is_revolver") then
          --BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"akimbo_revolver\"", v.usage ~= "akimbo_revolver")
          v.usage = "akimbo_revolver"
        end
        v.DAMAGE = v.usage == "akimbo_revolver" and m4_dps * 0.3 or m4_dps * 0.1
      end
      
      -- fix shotgun damage
      if v.is_shotgun and (v.usage == "is_shotgun_pump" or v.usage == "is_shotgun") then
        if v.CLIP_AMMO_MAX <= 2 or v.auto and v.auto.fire_rate and v.auto.fire_rate < 0.33 and v.is_shotgun then
          --BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_shotgun\"", v.usage ~= "is_shotgun")
          v.usage = "is_shotgun"
          v.auto = {}
          v.DAMAGE = v.CLIP_AMMO_MAX <= 2 and m4_dps * 0.8 or m4_dps * 0.4
        else
          v.DAMAGE = "is_shotgun" and m4_dps * 0.4 or m4_dps * 0.75
        end
      end
      
      -- fix sniper damage
      if v.usage == "is_sniper" then
        v.auto = {}
        v.DAMAGE = m4_dps * 1.5
      end
      
    end
  end
end