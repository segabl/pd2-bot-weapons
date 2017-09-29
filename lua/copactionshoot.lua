dofile(ModPath .. "botweapons.lua")

local init_original = CopActionShoot.init
function CopActionShoot:init(action_desc, common_data, ...)
  local result = init_original(self, action_desc, common_data, ...)
  if managers.groupai:state():is_unit_team_AI(self._unit) then
    local w_tweak = self._unit:base()._saved_w_tweak
    local w_u_tweak = self._w_usage_tweak
    if not w_tweak then
      w_tweak = deep_clone(self._weap_tweak)
      
      if not CopActionShoot.TEAM_AI_TARGET_DAMAGE then
        local damage = tweak_data.weapon.m4_crew.DAMAGE
        local mag =  tweak_data.weapon.m4_crew.CLIP_AMMO_MAX
        local burst_size = (common_data.char_tweak.weapon.is_rifle.autofire_rounds[1] + common_data.char_tweak.weapon.is_rifle.autofire_rounds[2]) * 0.5
        local shot_delay =  tweak_data.weapon.m4_crew.auto.fire_rate
        local burst_delay = shot_delay * 1.5
        local reload = common_data.char_tweak.weapon.is_rifle.RELOAD_SPEED
        CopActionShoot.TEAM_AI_TARGET_DAMAGE = (damage * mag) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)
      end
      
      local mag = w_tweak.CLIP_AMMO_MAX
      local burst_size = w_u_tweak.autofire_rounds and (w_u_tweak.autofire_rounds[1] + w_u_tweak.autofire_rounds[2]) * 0.5 or 1
      local shot_delay = w_tweak.fire_mode == "auto" and w_tweak.auto.fire_rate or w_tweak.auto.fire_rate * 1.5
      local burst_delay = w_tweak.auto.fire_rate * 1.5
      local reload = w_u_tweak.RELOAD_SPEED
      w_tweak.DAMAGE = (CopActionShoot.TEAM_AI_TARGET_DAMAGE * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload)) / mag
      
      w_tweak.falloff = deep_clone(self._falloff)
      for _, v in ipairs(w_tweak.falloff) do
        v.recoil = { shot_delay * 1.5, shot_delay * 2 }
      end
      
      con:print("DAMAGE for " .. self._weapon_base._name_id .. ": " .. w_tweak.DAMAGE)
      con:print("recoil for " .. self._weapon_base._name_id .. ": {" .. (shot_delay * 1.5) .. ", " .. (shot_delay * 2) .. "}")
      
      self._unit:base()._saved_w_tweak = w_tweak
    end
    self._weap_tweak = w_tweak
    self._falloff = w_tweak.falloff
    self._automatic_weap = w_tweak.fire_mode == "auto" and w_u_tweak.autofire_rounds and true
    self._spread = self._automatic_weap and self._spread or self._spread * 0.75
  end
  return result
end