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
    local total = v.mode[1] + v.mode[2] + v.mode[3] + v.mode[4]
    burst_size = burst_size + (v.mode[1] / total) * 1 + (v.mode[2] / total) * 2 + (v.mode[3] / total) * 3 + (v.mode[4] / total) * mean_autofire
  end
  return burst_size / #w_u_tweak.FALLOFF
end

local function set_usage(crew_weapon_name, weapon, usage)
  if not weapon.anim_usage and weapon.usage ~= usage then
    weapon.anim_usage = weapon.usage
  end
  BotWeapons:log("Changed " .. crew_weapon_name .. " usage from " .. tostring(weapon.usage) .. " to " .. usage, BotWeapons.settings.debug and weapon.usage ~= usage)
  weapon.usage = usage
end

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
function WeaponTweakData:_player_weapon_from_crew_weapon(crew_id)
  crew_id = crew_id:gsub("_crew$", ""):gsub("_secondary$", ""):gsub("_primary$", "")
  return self[weapon_table[crew_id] or crew_id]
end

function WeaponTweakData:setup_crew_weapons(crew_preset)

  BotWeapons:log("Setting up crew weapon data")

  -- copy some data from the player version of a weapon to crew version and setup usage
  local anim_usage_redirects = {
    is_lmg = "is_rifle",
    is_shotgun_mag = "is_rifle"
  }
  local function setup_crew_weapon_data(crew_weapon_name, crew_weapon, player_weapon)
    if not player_weapon then
      BotWeapons:log("Error: Could not find player weapon version of " .. crew_weapon_name .. "!")
      return
    end
    local fire_mode = player_weapon.FIRE_MODE or "single"
    local is_automatic = fire_mode == "auto"
    local fire_rate = player_weapon.fire_mode_data and player_weapon.fire_mode_data.fire_rate or player_weapon[fire_mode] and player_weapon[fire_mode].fire_rate or 1
    crew_weapon[fire_mode] = { fire_rate = fire_rate }
    crew_weapon.CLIP_AMMO_MAX = player_weapon.CLIP_AMMO_MAX
    crew_weapon.reload_time = player_weapon.timers.reload_empty or 5
    if is_automatic then
      if crew_weapon.is_shotgun or crew_weapon.usage == "is_shotgun_pump" then
        set_usage(crew_weapon_name, crew_weapon, "is_shotgun_mag")
      elseif crew_weapon.usage == "is_pistol" or crew_weapon.usage == "akimbo_pistol" then
        set_usage(crew_weapon_name, crew_weapon, "is_smg")
      elseif crew_weapon.CLIP_AMMO_MAX >= 100 then
        set_usage(crew_weapon_name, crew_weapon, "is_lmg")
      end
    else
      if crew_weapon.is_shotgun or crew_weapon.usage == "is_shotgun_mag" then
        set_usage(crew_weapon_name, crew_weapon, "is_shotgun_pump")
      elseif crew_weapon.usage == "is_rifle" or crew_weapon.usage == "is_bullpup" or crew_weapon.usage == "is_smg" or crew_weapon.usage == "is_lmg" or crew_weapon.usage == "bow" then
        set_usage(crew_weapon_name, crew_weapon, "is_sniper")
      end
    end
    -- fix anim_usage
    crew_weapon.anim_usage = anim_usage_redirects[crew_weapon.anim_usage or crew_weapon.usage] or crew_weapon.anim_usage
    if crew_weapon.usage ~= crew_weapon_name and not crew_preset[crew_weapon.usage] then
      BotWeapons:log("Error: No usage preset for " .. crew_weapon_name .. " (" .. crew_weapon.usage .. ")!")
      return
    end
    -- clone weapon usage preset to allow unique settings for each weapon
    local preset = deep_clone(crew_preset[crew_weapon.usage])
    local recoil = player_weapon.stats and self.stats.recoil[player_weapon.stats.recoil] or self.stats.recoil[1]
    local burst_delay = is_automatic and { 0.25 + recoil * 0.2, 0.25 + recoil * 0.4 } or { fire_rate, fire_rate + recoil * 0.1 }
    for _, v in ipairs(preset.FALLOFF) do
      v.recoil = burst_delay
    end
    local mult = crew_weapon.hold == "akimbo_pistol" and 0.5 or 1
    preset.autofire_rounds = is_automatic and { math.max(1, math.floor(crew_weapon.CLIP_AMMO_MAX * 0.15 * mult)), math.ceil(crew_weapon.CLIP_AMMO_MAX * 0.35 * mult) }
    preset.RELOAD_SPEED = 1
    -- set new usage preset
    crew_weapon.anim_usage = not crew_weapon.anim_usage and crew_weapon.usage or crew_weapon.anim_usage
    crew_weapon.usage = crew_weapon_name
    crew_preset[crew_weapon_name] = preset
    return true
  end

  -- setup reference weapon
  if not setup_crew_weapon_data("m4_crew", self.m4_crew, self.new_m4) then
    BotWeapons:log("Error: Reference weapon m4_crew could not be set up, weapon balance option will not work properly!")
    return
  end

  -- target dps for other weapons based on m4
  local w_u_tweak = crew_preset[self.m4_crew.usage]
  local is_automatic =  w_u_tweak.autofire_rounds and true
  local mag = self.m4_crew.CLIP_AMMO_MAX
  local burst_size = is_automatic and average_burst_size(w_u_tweak) or 1
  local shot_delay = is_automatic and self.m4_crew.auto.fire_rate or 0
  local burst_delay = mean(w_u_tweak.FALLOFF[1].recoil)
  local reload_time = self.m4_crew.reload_time
  local target_damage = (self.m4_crew.DAMAGE * mag) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload_time)

  for crew_weapon_name, crew_weapon in pairs(self) do
    if type(crew_weapon) == "table" and crew_weapon_name:match("_crew$") then
      if setup_crew_weapon_data(crew_weapon_name, crew_weapon, self:_player_weapon_from_crew_weapon(crew_weapon_name)) then
        -- calculate weapon damage based on reference dps
        w_u_tweak = crew_preset[crew_weapon.usage]
        is_automatic = w_u_tweak.autofire_rounds and true
        mag = crew_weapon.CLIP_AMMO_MAX
        burst_size = is_automatic and average_burst_size(w_u_tweak) or 1
        shot_delay = is_automatic and crew_weapon.auto.fire_rate or 0
        burst_delay = mean(w_u_tweak.FALLOFF[1].recoil)
        reload_time = crew_weapon.reload_time
        crew_weapon.DAMAGE = (target_damage * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload_time)) / mag
      end
    end
  end

end
