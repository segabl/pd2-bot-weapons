dofile(ModPath .. "botweapons.lua")

local init_original = CopActionShoot.init
function CopActionShoot:init(action_desc, common_data, ...)
  local result = init_original(self, action_desc, common_data, ...)
  if managers.groupai:state():is_unit_team_AI(self._unit) then
    local w_tweak = self._weap_tweak
    local w_u_tweak = self._w_usage_tweak
    if not w_tweak.falloff then
      if not CopActionShoot.TEAM_AI_TARGET_DAMAGE then
        local damage = tweak_data.weapon.m4_crew.DAMAGE
        local dmg_mul = common_data.char_tweak.weapon.is_rifle.FALLOFF[1].dmg_mul
        local mag =  tweak_data.weapon.m4_crew.CLIP_AMMO_MAX
        local burst_size = (common_data.char_tweak.weapon.is_rifle.autofire_rounds[1] + common_data.char_tweak.weapon.is_rifle.autofire_rounds[2]) * 0.5
        local shot_delay =  tweak_data.weapon.m4_crew.auto.fire_rate
        local burst_delay = shot_delay * 1.5
        local reload = common_data.char_tweak.weapon.is_rifle.RELOAD_SPEED
        CopActionShoot.TEAM_AI_TARGET_DAMAGE = (damage * dmg_mul * mag) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)
      end
      
      local dmg_mul = w_u_tweak.FALLOFF[1].dmg_mul
      local mag = w_tweak.CLIP_AMMO_MAX
      local burst_size = w_tweak.fire_mode == "auto" and w_u_tweak.autofire_rounds and (w_u_tweak.autofire_rounds[1] + w_u_tweak.autofire_rounds[2]) * 0.5 or 1
      local shot_delay = w_tweak.auto.fire_rate
      local burst_delay = shot_delay * 1.5
      local reload = w_u_tweak.RELOAD_SPEED
      self._weapon_base._damage = (CopActionShoot.TEAM_AI_TARGET_DAMAGE * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)) / (mag * dmg_mul)
      
      w_tweak.falloff = deep_clone(self._falloff)
      for _, v in ipairs(w_tweak.falloff) do
        v.recoil = { burst_delay, burst_delay * 1.25 }
      end
      
      --con:print("DAMAGE for " .. self._weapon_base._name_id .. ": " .. w_tweak.DAMAGE)
      --con:print("recoil for " .. self._weapon_base._name_id .. ": {" .. (shot_delay * 1.5) .. ", " .. (shot_delay * 2) .. "}")
    end
    self._falloff = w_tweak.falloff
    self._automatic_weap = w_tweak.fire_mode == "auto" and w_u_tweak.autofire_rounds and true
    self._spread = self._automatic_weap and self._spread or self._spread * 0.75
  end
  return result
end