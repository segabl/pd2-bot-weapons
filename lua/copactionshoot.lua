TeamAIActionShoot = class(CopActionShoot)

function TeamAIActionShoot:_setup_weapon()
  if not self._weap_tweak or not self._w_usage_tweak then
    return
  end
  self._automatic_weap = self._weap_tweak.auto and self._w_usage_tweak.autofire_rounds and true
  self._reload_speed = HuskPlayerMovement:get_reload_animation_time(self._weap_tweak.hold) / (self._weap_tweak.reload_time or 5)
end

function TeamAIActionShoot:init(...)
  if TeamAIActionShoot.super.init(self, ...) then
    self:_setup_weapon()
    return true
  end
end

function TeamAIActionShoot:on_inventory_event(...)
  TeamAIActionShoot.super.on_inventory_event(self, ...)
  self:_setup_weapon()
end

if StreamHeist then
  return
end

-- interpolate damage for team ai
local lerp = math.lerp
function TeamAIActionShoot:_get_shoot_falloff(target_dis, falloff)
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
