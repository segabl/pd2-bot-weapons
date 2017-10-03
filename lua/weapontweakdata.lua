dofile(ModPath .. "botweapons.lua")

local init_original = WeaponTweakData.init
function WeaponTweakData:init(...)
  init_original(self, ...)
  
  BotWeapons:log("Setting up weapons")
  
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
      if player_weapon then
        local fire_mode = player_weapon.FIRE_MODE or "single"
        local fire_rate = player_weapon.fire_mode_data and player_weapon.fire_mode_data.fire_rate or player_weapon[fire_mode] and player_weapon[fire_mode].fire_rate or 0.5
        v.auto = { fire_rate = fire_rate }
        v.fire_mode = fire_mode
        v.burst_delay = math.min(fire_rate * 1.5, fire_rate + 0.25)
        if v.usage == "akimbo_pistol" and fire_rate == "auto" then
          v.anim_usage = v.usage
          v.usage = "is_lmg"
        end
      else
        BotWeapons:log("Warning: Could not find player weapon version of " .. k .. "!")
      end
    end
  end
end