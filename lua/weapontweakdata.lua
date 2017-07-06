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
  
  -- fix stuff
  self.m14_crew.usage = "is_burst"
  self.g22c_crew.auto = nil
  self.usp_crew.auto = nil
  self.tecci_crew.auto = { fire_rate = 0.09 }
  self.desertfox_crew.auto = { fire_rate = 1 }
  
  local m4_dps = self.m4_crew.DAMAGE / self.m4_crew.auto.fire_rate

  for k, v in pairs(self) do
    if type(v) == "table" and k:match("_crew$") then
      -- fix auto akimbo fire rates
      if k:match("^x_") and self[k:gsub("^x_", "")] then
        v.auto = self[k:gsub("^x_", "")].auto or v.auto
        if v.auto and v.auto.fire_rate then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"akimbo_auto\"", v.usage ~= "akimbo_auto")
          v.usage = "akimbo_auto"
        end 
      end
      
      -- fix shotguns
      if v.is_shotgun and v.usage ~= "is_shotgun_pump" and v.usage ~= "is_shotgun" and v.usage ~= "is_shotgun_mag" then
        v.usage = "is_shotgun"
      end
    
      -- fix auto damage
      if v.auto and v.auto.fire_rate and not v.is_shotgun then
        if v.CLIP_AMMO_MAX >= 100 then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_lmg\"", v.usage ~= "is_lmg")
          v.usage = "is_lmg"
        elseif v.usage == "is_pistol" then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_smg\"", v.usage ~= "is_smg")
          v.usage = "is_smg"
        end
        v.DAMAGE = m4_dps * v.auto.fire_rate
      end
      
      -- fix pistol damage
      if v.usage == "is_pistol" or v.usage == "is_revolver" then
        if v.CLIP_AMMO_MAX <= 6 then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_revolver\"", v.usage ~= "is_revolver")
          v.usage = "is_revolver"
        end
        v.DAMAGE = v.usage == "is_revolver" and m4_dps * 0.5 or m4_dps * 0.2
      end
      
      -- fix akimbo pistol damage
      if v.usage == "akimbo_pistol" then
        if self[k:gsub("^x_", "")] and (self[k:gsub("^x_", "")].CLIP_AMMO_MAX <= 6 or self[k:gsub("^x_", "")].usage == "is_revolver") then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"akimbo_deagle\"", v.usage ~= "akimbo_deagle")
          v.usage = "akimbo_deagle"
        end
        v.DAMAGE = v.usage == "akimbo_deagle" and m4_dps * 0.3 or m4_dps * 0.1
      end
      
      -- fix shotgun damage
      if v.usage == "is_shotgun_pump" or v.usage == "is_shotgun" then
        if v.CLIP_AMMO_MAX <= 2 or v.auto and v.auto.fire_rate and v.auto.fire_rate < 0.33 and v.is_shotgun then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_shotgun\"", v.usage ~= "is_shotgun")
          v.usage = "is_shotgun"
          v.DAMAGE = v.CLIP_AMMO_MAX <= 2 and m4_dps * 0.8 or m4_dps * 0.4
        else
          v.DAMAGE = "is_shotgun" and m4_dps * 0.4 or m4_dps * 0.75
        end
      end

      -- fix m14 damage
      if v.usage == "is_burst" then
        v.DAMAGE = v.DAMAGE * 2 
      end
      
    end
  end
end