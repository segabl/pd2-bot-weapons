local function mean(tbl)
  local sum = 0
  for _, v in ipairs(tbl) do
    sum = sum + v
  end
  return sum / #tbl
end

local function average_burst_size(w_u_tweak)
  local mean_autofire = w_u_tweak.autofire_rounds and mean(w_u_tweak.autofire_rounds) or 1
  if StreamHeist then
    return mean_autofire
  end
  local burst_size = 0
  for _, v in ipairs(w_u_tweak.FALLOFF) do
    burst_size = burst_size + (v.mode[1] * 1 + (v.mode[2] - v.mode[1]) * 2 + (v.mode[3] - v.mode[2]) * 3 + (v.mode[4] - v.mode[3]) * mean_autofire)
  end
  return burst_size / #w_u_tweak.FALLOFF
end

local function max_kick(kick)
  local k = 0.5
  for _, v in ipairs(kick or {}) do
    k = math.max(k, math.abs(v))
  end
  return k
end

local function set_usage(key, weapon, usage)
  if not weapon.anim_usage and weapon.usage ~= usage then
    weapon.anim_usage = weapon.usage
  end
  BotWeapons:log(key .. " usage: " .. tostring(weapon.usage) .. " -> " .. usage, BotWeapons.settings.debug and weapon.usage ~= usage)
  weapon.usage = usage
end

function WeaponTweakData:_player_weapon_from_crew_weapon(crew_id)
  crew_id = crew_id:gsub("_crew$", ""):gsub("_secondary$", ""):gsub("_primary$", "")
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
  return self[weapon_table[crew_id] or crew_id]
end

function WeaponTweakData:setup_crew_weapons(crew_preset)

  BotWeapons:log("Setting up crew weapons")

  -- copy some data from the player version of a weapon to crew version and setup usage
  local function setup_crew_weapon_data(crew_weapon_name, crew_weapon, player_weapon)
    if not player_weapon then
      BotWeapons:log("Warning: Could not find player weapon version of " .. crew_weapon_name .. "!")
      return
    end
    local fire_mode = player_weapon.FIRE_MODE or "single"
    local fire_rate = player_weapon.fire_mode_data and player_weapon.fire_mode_data.fire_rate or player_weapon[fire_mode] and player_weapon[fire_mode].fire_rate or 1
    crew_weapon.auto = { fire_rate = fire_rate }
    crew_weapon.fire_mode = fire_mode
    crew_weapon.burst_delay = { fire_rate, fire_rate + max_kick(player_weapon.kick.standing) * 0.1 }
    crew_weapon.reload_time = player_weapon.timers.reload_not_empty
    if fire_mode == "auto" then
      if crew_weapon.is_shotgun or crew_weapon.usage == "is_shotgun_pump" then
        set_usage(crew_weapon_name, crew_weapon, "is_shotgun_mag")
      elseif crew_weapon.usage == "akimbo_pistol" then
        set_usage(crew_weapon_name, crew_weapon, "is_lmg")
      elseif crew_weapon.usage == "is_pistol" then
        set_usage(crew_weapon_name, crew_weapon, "is_smg")
      elseif crew_weapon.CLIP_AMMO_MAX >= 100 then
        set_usage(crew_weapon_name, crew_weapon, "is_lmg")
      end
      if crew_weapon.usage == "is_lmg" and not crew_weapon.anim_usage then
        crew_weapon.anim_usage = "is_rifle"
      end
    else
      if crew_weapon.is_shotgun or crew_weapon.usage == "is_shotgun_mag" then
        set_usage(crew_weapon_name, crew_weapon, "is_shotgun_pump")
      elseif crew_weapon.usage == "is_rifle" or crew_weapon.usage == "is_bullpup" or crew_weapon.usage == "is_smg" or crew_weapon.usage == "is_lmg" or crew_weapon.usage == "bow" then
        set_usage(crew_weapon_name, crew_weapon, "is_sniper")
      end
    end
    return true
  end

  -- setup reference weapon
  setup_crew_weapon_data("m4_crew", self.m4_crew, self.new_m4)

  -- calculate m4 dps as target dps for other weapons
  local w_u_tweak = crew_preset[self.m4_crew.usage]
  local w_automatic = self.m4_crew.fire_mode == "auto" and w_u_tweak.autofire_rounds and true
  local mag = self.m4_crew.CLIP_AMMO_MAX
  local burst_size = w_automatic and average_burst_size(w_u_tweak) or 1
  local shot_delay = self.m4_crew.auto and self.m4_crew.auto.fire_rate or 1
  local burst_delay = mean((w_automatic or not self.m4_crew.burst_delay) and w_u_tweak.FALLOFF[1].recoil or self.m4_crew.burst_delay)
  local reload_time = self.m4_crew.reload_time or 2
  local target_damage = (self.m4_crew.DAMAGE * mag) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload_time)

  for weapon_id, weapon_data in pairs(self) do
    if type(weapon_data) == "table" and weapon_id:match("_crew$") then
      if setup_crew_weapon_data(weapon_id, weapon_data, self:_player_weapon_from_crew_weapon(weapon_id)) then
        w_u_tweak = crew_preset[weapon_data.usage]
        if w_u_tweak then
          w_automatic = weapon_data.fire_mode == "auto" and w_u_tweak.autofire_rounds and true
          -- copy weapon preset for single fire weapons (to allow unique fire rates)
          if not w_automatic then
            crew_preset[weapon_id] = deep_clone(w_u_tweak)
            for _, v in ipairs(crew_preset[weapon_id].FALLOFF) do
              v.recoil = weapon_data.burst_delay
            end
            set_usage(weapon_id, weapon_data, weapon_id)
          end
          -- calculate weapon damage based on reference dps
          mag = weapon_data.CLIP_AMMO_MAX
          burst_size = w_automatic and average_burst_size(w_u_tweak) or 1
          shot_delay = weapon_data.auto and weapon_data.auto.fire_rate or 1
          burst_delay = mean(w_u_tweak.FALLOFF[1].recoil)
          reload_time = weapon_data.reload_time or 2
          weapon_data.DAMAGE = (target_damage * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload_time)) / mag
        else
          BotWeapons:log("Warning: No usage preset for " .. weapon_id .. " (" .. weapon_data.usage .. ")!")
        end
      end
    end
  end

end
