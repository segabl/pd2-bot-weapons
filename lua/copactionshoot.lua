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
  function CopActionShoot:init(action_desc, common_data, ...)
    local result = init_original(self, action_desc, common_data, ...)
    if managers.groupai:state():is_unit_team_AI(self._unit) then
      local m4_tweak = tweak_data.weapon.m4_crew
      local m4_u_tweak = common_data.char_tweak.weapon[m4_tweak.usage]
      local m4_automatic = m4_tweak.fire_mode == "auto" and m4_u_tweak.autofire_rounds and true or false
      local w_tweak = self._weap_tweak
      local w_u_tweak = self._w_usage_tweak
      local w_automatic = w_tweak.fire_mode == "auto" and w_u_tweak.autofire_rounds and true or false
      --if not w_tweak.falloff then
      if not w_tweak.falloff then
        if not CopActionShoot.TEAM_AI_TARGET_DAMAGE then
          -- calculate m4 dps as target dps for other weapons
          local dmg = m4_tweak.DAMAGE
          local mag = m4_tweak.CLIP_AMMO_MAX
          local burst_size = m4_tweak.fire_mode == "auto" and average_burst_size(m4_u_tweak) or 1
          local shot_delay = m4_tweak.auto.fire_rate
          local burst_delay = m4_automatic and mean(m4_u_tweak.FALLOFF[1].recoil) or mean({ m4_tweak.auto.fire_rate, m4_tweak.auto.fire_rate * 1.5 })
          local reload_time = HuskPlayerMovement:get_reload_animation_time(m4_tweak.hold)
          local reload = reload_time / m4_u_tweak.RELOAD_SPEED
          CopActionShoot.TEAM_AI_TARGET_DAMAGE = (dmg * mag) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)
        end
        if not w_automatic then
          w_tweak.falloff = deep_clone(w_u_tweak.FALLOFF)
          local recoil = { w_tweak.auto.fire_rate, w_tweak.auto.fire_rate * 1.5 }
          for _, v in ipairs(w_tweak.falloff) do
            v.recoil = recoil
          end
        else
          w_tweak.falloff = w_u_tweak.FALLOFF
        end
        -- calculate weapon damage based on m4 dps
        local mag = w_tweak.CLIP_AMMO_MAX
        local burst_size = w_tweak.fire_mode == "auto" and average_burst_size(w_u_tweak) or 1
        local shot_delay = w_tweak.auto.fire_rate
        local burst_delay = mean(w_u_tweak.FALLOFF[1].recoil)
        local reload_time = HuskPlayerMovement:get_reload_animation_time(w_tweak.hold)
        local reload = reload_time / w_u_tweak.RELOAD_SPEED
        w_tweak.DAMAGE = (CopActionShoot.TEAM_AI_TARGET_DAMAGE * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)) / mag
      end
      self._falloff = w_tweak.falloff
      self._automatic_weap = w_automatic
      self._weapon_base._damage = w_tweak.DAMAGE
    end
    return result
  end

end