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
  self.ching_crew.pull_magazine_during_reload = nil
  self.rota_crew.usage = "is_shotgun_pump"
  
  local function get_player_weapon(id)
    local weapon_table = {
      g17 = "glock_17",
      c45 = "glock_17",
      x_c45 = "x_g17",
      glock_18 = "glock_18c",
      m4 = "new_m4",
      mp5 = "new_mp5",
      ak47 = "ak74",
      ak47_ass = "ak74",
      raging_bull = "new_raging_bull",
      mossberg = "huntsman",
      m14 = "new_m14",
      ben = "benelli",
      beretta92 = "b92fs"
    }
    id = weapon_table[id] or id
    return self[id]
  end
  for k, v in pairs(self) do
    if type(v) == "table" and k:match("_crew$") then
      -- get player version of gun to copy fire rate and mode from
      local player_weapon = get_player_weapon(k:gsub("_crew$", ""):gsub("_secondary$", ""):gsub("_primary$", ""))
      BotWeapons:log("Warning: Could not find player weapon version of " .. k .. "!", not player_weapon)
      if player_weapon then
        local fire_mode = player_weapon.FIRE_MODE or "single"
        local fire_rate = player_weapon.fire_mode_data and player_weapon.fire_mode_data.fire_rate or player_weapon[fire_mode] and player_weapon[fire_mode].fire_rate or 0.5
        v.auto = { fire_rate = fire_rate }
        v.fire_mode = fire_mode
        v.burst_delay = fire_mode == "auto" and fire_rate * 2.5 or fire_rate
        if v.CLIP_AMMO_MAX >= 100 then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_lmg\"", BotWeapons.debug and v.usage ~= "is_lmg")
          v.usage = "is_lmg"
        elseif v.usage == "is_pistol" and fire_mode == "auto" then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_smg\"", BotWeapons.debug and v.usage ~= "is_smg")
          v.usage = "is_smg"
        elseif (v.usage == "akimbo_pistol" or k:match("^x_")) and fire_mode == "auto" then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_lmg\"", BotWeapons.debug and v.usage ~= "is_lmg")
          v.usage = "is_lmg"
        elseif v.is_shotgun and v.usage ~= "is_shotgun_pump" and v.usage ~= "is_shotgun_mag" then
          BotWeapons:log("Change " .. k .. " usage from \"" .. v.usage .. "\" to \"is_shotgun_pump\"", BotWeapons.debug and v.usage ~= "is_shotgun_pump")
          v.usage = "is_shotgun_pump"
        end
      end
    end
  end
end
