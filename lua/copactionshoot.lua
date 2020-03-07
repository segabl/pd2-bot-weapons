TeamAIActionShoot = class(CopActionShoot)

local function mean(tbl)
  local sum = 0
  for _, v in ipairs(tbl) do
    sum = sum + v
  end
  return sum / #tbl
end

local function average_burst_size(w_u_tweak)
  local mean_autofire = w_u_tweak.autofire_rounds and mean(w_u_tweak.autofire_rounds) or 1
  if CASS then
    return mean_autofire
  end
  local burst_size = 0
  for _, v in ipairs(w_u_tweak.FALLOFF) do
    burst_size = burst_size + (v.mode[1] * 1 + (v.mode[2] - v.mode[1]) * 2 + (v.mode[3] - v.mode[2]) * 3 + (v.mode[4] - v.mode[3]) * mean_autofire)
  end
  return burst_size / #w_u_tweak.FALLOFF
end

local m4_tweak = tweak_data.weapon.m4_crew
local m4_u_tweak = tweak_data.character.presets.weapon.gang_member[m4_tweak.usage]
local m4_automatic = m4_tweak.fire_mode == "auto" and m4_u_tweak.autofire_rounds and true or false
-- calculate m4 dps as target dps for other weapons
local mag = m4_tweak.CLIP_AMMO_MAX
local burst_size = m4_automatic and average_burst_size(m4_u_tweak) or 1
local shot_delay = m4_tweak.auto and m4_tweak.auto.fire_rate or 0.5
local burst_delay = mean((m4_automatic or not m4_tweak.burst_delay) and m4_u_tweak.FALLOFF[1].recoil or m4_tweak.burst_delay)
local reload_time = m4_tweak.reload_time or 2

TeamAIActionShoot.TARGET_DAMAGE = (m4_tweak.DAMAGE * mag) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload_time)

function TeamAIActionShoot:init(...)
  if not TeamAIActionShoot.super.init(self, ...) then
    return false
  end

  local w_tweak = self._weap_tweak
  local w_u_tweak = self._w_usage_tweak
  local w_automatic = w_tweak.fire_mode == "auto" and w_u_tweak.autofire_rounds and true or false
  if not self._weapon_base._falloff_data then
    if not w_automatic and w_tweak.burst_delay then
      self._weapon_base._falloff_data = deep_clone(w_u_tweak.FALLOFF)
      for _, v in ipairs(self._weapon_base._falloff_data) do
        v.recoil = w_tweak.burst_delay
      end
    else
      self._weapon_base._falloff_data = w_u_tweak.FALLOFF
    end
    -- calculate weapon damage based on m4 dps
    mag = w_tweak.CLIP_AMMO_MAX
    burst_size = w_automatic and average_burst_size(w_u_tweak) or 1
    shot_delay = w_tweak.auto and w_tweak.auto.fire_rate or 0.5
    burst_delay = mean(self._weapon_base._falloff_data[1].recoil)
    reload_time = w_tweak.reload_time or 2
    self._weapon_base._damage = (self.TARGET_DAMAGE * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload_time)) / mag
    if alive(self._weapon_base._second_gun) then
      self._weapon_base._second_gun:base()._damage = self._weapon_base._damage
      self._weapon_base._second_gun:base().SKIP_AMMO = false
    end
  end
  self._falloff = self._weapon_base._falloff_data
  self._automatic_weap = w_automatic
  self._reload_speed = HuskPlayerMovement:get_reload_animation_time(w_tweak.hold) / (w_tweak.reload_time or 2)
  return true
end

if not CASS then

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

end