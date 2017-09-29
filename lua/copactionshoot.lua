local function mean(tbl, member)
  local sum = 0
  if member then
    for _, v in ipairs(tbl) do
      sum = sum + v[member]
    end
  else
    for _, v in ipairs(tbl) do
      sum = sum + v
    end
  end
  return sum / #tbl
end

local init_original = CopActionShoot.init
function CopActionShoot:init(action_desc, common_data, ...)
  local result = init_original(self, action_desc, common_data, ...)
  if managers.groupai:state():is_unit_team_AI(self._unit) then
    local w_tweak = self._weap_tweak
    local w_u_tweak = self._w_usage_tweak
    if not w_tweak.falloff then
      if not CopActionShoot.TEAM_AI_TARGET_DAMAGE then
        -- calculate m4 dps as target dps for other weapons
        local damage = tweak_data.weapon.m4_crew.DAMAGE
        local dmg_mul = mean(common_data.char_tweak.weapon.is_rifle.FALLOFF, "dmg_mul")
        local mag =  tweak_data.weapon.m4_crew.CLIP_AMMO_MAX
        local burst_size = mean(common_data.char_tweak.weapon.is_rifle.autofire_rounds)
        local shot_delay =  tweak_data.weapon.m4_crew.auto.fire_rate
        local burst_delay = tweak_data.weapon.m4_crew.burst_delay
        local reload = common_data.char_tweak.weapon.is_rifle.RELOAD_SPEED
        CopActionShoot.TEAM_AI_TARGET_DAMAGE = (damage * dmg_mul * mag) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)
      end
      -- calculate weapon damage based on m4 dps
      local dmg_mul = mean(w_u_tweak.FALLOFF, "dmg_mul")
      local mag = w_tweak.CLIP_AMMO_MAX
      local burst_size = w_tweak.fire_mode == "auto" and w_u_tweak.autofire_rounds and mean(w_u_tweak.autofire_rounds) or 1
      local shot_delay = w_tweak.auto.fire_rate
      local burst_delay = w_tweak.burst_delay
      local reload = w_u_tweak.RELOAD_SPEED
      self._weapon_base._damage = (CopActionShoot.TEAM_AI_TARGET_DAMAGE * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)) / (mag * dmg_mul)
      -- customize falloff to allow usage independent single fire rates
      w_tweak.falloff = deep_clone(self._falloff)
      local recoil = { burst_delay, burst_delay }
      for _, v in ipairs(w_tweak.falloff) do
        v.recoil = recoil
      end
      --con:print(self._weapon_base._name_id .. ": damage = " .. self._weapon_base._damage .. ", recoil = " .. recoil[1])
    end
    self._falloff = w_tweak.falloff
    self._automatic_weap = w_tweak.fire_mode == "auto" and w_u_tweak.autofire_rounds and true
    self._spread = common_data.char_tweak.weapon.is_rifle.spread
  end
  return result
end