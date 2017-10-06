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
  
  local function set_usage(key, weapon, usage)
    if not weapon.anim_usage then
      weapon.anim_usage = weapon.usage
    end
    BotWeapons:log(key .. " usage: " .. weapon.usage .. " -> " .. usage, BotWeapons.debug and weapon.usage ~= usage)
    weapon.usage = usage
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
        v.burst_delay = { fire_rate, math.min(fire_rate * 1.5, fire_rate + 0.25) }
        if fire_mode == "auto" then
          if v.usage == "akimbo_pistol" then
            set_usage(k, v, "is_lmg")
          elseif v.usage == "is_pistol" then
            set_usage(k, v, "is_smg")
          elseif v.CLIP_AMMO_MAX >= 100 then
            set_usage(k, v, "is_lmg")
          end
        else
          if v.usage == "is_rifle" or v.usage == "is_bullpup" or v.usage == "is_smg" then
            set_usage(k, v, "is_sniper")
          end
        end
      else
        BotWeapons:log("Warning: Could not find player weapon version of " .. k .. "!")
      end
    end
  end
end