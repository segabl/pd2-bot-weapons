dofile(ModPath .. "botweapons.lua")

if BotWeapons._data.weapon_balance then

  local function mean(tbl)
    local sum = 0
    for _, v in ipairs(tbl) do
      sum = sum + v
    end
    return sum / #tbl
  end
  
  local function average_burst_size(w_u_tweak)
    local mean_autofire = w_u_tweak.autofire_rounds and mean(w_u_tweak.autofire_rounds) or 1
    local average_burst_size = 0
    for _, v in ipairs(w_u_tweak.FALLOFF) do
      average_burst_size = average_burst_size + (v.mode[1] * 1 + (v.mode[2] - v.mode[1]) * 2 + (v.mode[3] - v.mode[2]) * 3 + (v.mode[4] - v.mode[3]) * mean_autofire)
    end
    return average_burst_size / #w_u_tweak.FALLOFF
  end
  
  local init_original = CopActionShoot.init
  function CopActionShoot:init(...)
    local success = init_original(self, ...)
    if success and self._weapon_base._is_team_ai then
      local w_tweak = self._weap_tweak
      local w_u_tweak = self._w_usage_tweak
      local w_automatic = w_tweak.fire_mode == "auto" and w_u_tweak.autofire_rounds and true or false
      if not w_tweak.falloff then
        if not CopActionShoot.TEAM_AI_TARGET_DAMAGE then
          local m4_tweak = tweak_data.weapon.m4_crew
          local m4_u_tweak = self._common_data.char_tweak.weapon[m4_tweak.usage]
          local m4_automatic = m4_tweak.fire_mode == "auto" and m4_u_tweak.autofire_rounds and true or false
          -- calculate m4 dps as target dps for other weapons
          local dmg = m4_tweak.DAMAGE
          local mag = m4_tweak.CLIP_AMMO_MAX
          local burst_size = m4_tweak.fire_mode == "auto" and average_burst_size(m4_u_tweak) or 1
          local shot_delay = m4_tweak.auto.fire_rate or 0
          local burst_delay = mean((m4_automatic or not m4_tweak.burst_delay) and m4_u_tweak.FALLOFF[1].recoil or m4_tweak.burst_delay)
          local reload_time = HuskPlayerMovement:get_reload_animation_time(m4_tweak.hold)
          local reload = reload_time / m4_u_tweak.RELOAD_SPEED
          CopActionShoot.TEAM_AI_TARGET_DAMAGE = (dmg * mag) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)
        end
        if not w_automatic and w_tweak.burst_delay then
          w_tweak.falloff = deep_clone(w_u_tweak.FALLOFF)
          for _, v in ipairs(w_tweak.falloff) do
            v.recoil = w_tweak.burst_delay
          end
        else
          w_tweak.falloff = w_u_tweak.FALLOFF
        end
        -- calculate weapon damage based on m4 dps
        local mag = w_tweak.CLIP_AMMO_MAX
        local burst_size = w_tweak.fire_mode == "auto" and average_burst_size(w_u_tweak) or 1
        local shot_delay = w_tweak.auto.fire_rate or 0
        local burst_delay = mean(w_tweak.falloff[1].recoil)
        local reload_time = HuskPlayerMovement:get_reload_animation_time(w_tweak.hold)
        local reload = reload_time / w_u_tweak.RELOAD_SPEED
        w_tweak.DAMAGE = (CopActionShoot.TEAM_AI_TARGET_DAMAGE * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)) / mag
      end
      self._falloff = w_tweak.falloff
      self._automatic_weap = w_automatic
      self._weapon_base._damage = w_tweak.DAMAGE
    end
    return success
  end

  -- interpolate damage for team ai
  local lerp = math.lerp
  local _get_shoot_falloff_original = CopActionShoot._get_shoot_falloff
  function CopActionShoot:_get_shoot_falloff(target_dis, falloff)
    if not self._weapon_base._is_team_ai then
      return _get_shoot_falloff_original(self, target_dis, falloff)
    end
    local i = #falloff
    local data = falloff[i]
    for i_range, range_data in ipairs(falloff) do
      if target_dis < range_data.r then
        i = i_range
        data = range_data
        break
      end
    end
    if i == 1 or target_dis > data.r then
      return data, i
    else
      local prev_data = falloff[i - 1]
      local t = (target_dis - prev_data.r) / (data.r - prev_data.r)
      local n_data = {
        dmg_mul = lerp(prev_data.dmg_mul, data.dmg_mul, t),
        r = target_dis,
        acc = { lerp(prev_data.acc[1], data.acc[1], t), lerp(prev_data.acc[2], data.acc[2], t) },
        recoil = { lerp(prev_data.recoil[1], data.recoil[1], t), lerp(prev_data.recoil[2], data.recoil[2], t) },
        mode = data.mode
      }
      return n_data, i
    end
  end

end