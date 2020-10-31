-- compatibility for More Weapon Stats
local function CopActionShoot_get_shoot_falloff(target_dis, falloff)
  local i = #falloff
  local data = falloff[i]
  for i_range, range_data in ipairs(falloff) do
    if target_dis < range_data.r then
      i = i_range
      data = range_data
      break
    end
  end
  if not BotWeapons.settings.weapon_balance or i == 1 or target_dis > data.r then
    return data, i
  else
    local prev_data = falloff[i - 1]
    local t = (target_dis - prev_data.r) / (data.r - prev_data.r)
    local n_data = {
      dmg_mul = math.lerp(prev_data.dmg_mul, data.dmg_mul, t),
      acc = { math.lerp(prev_data.acc[1], data.acc[1], t), math.lerp(prev_data.acc[2], data.acc[2], t) },
    }
    return n_data, i
  end
end

function BlackMarketGui:mws_falloff_bot(wbase, index, txts, dis)
  local weap_tweak = wbase:weapon_tweak_data()
  local weapon_usage_tweak = tweak_data.character.russian.weapon[weap_tweak.usage]
  local falloff = CopActionShoot_get_shoot_falloff(dis - 0.01, weapon_usage_tweak.FALLOFF)

  txts['a' .. index]:set_text(('%.1f'):format(falloff.dmg_mul * wbase._damage * 10))
  if weapon_usage_tweak.autofire_rounds or StreamHeist then
    txts['b' .. index]:set_text((' | %i%%'):format(100 * falloff.acc[2]))
  else
    txts['b' .. index]:set_text((' | %i%%'):format(100 * (1 - weapon_usage_tweak.spread / 50)))
  end
end

function BlackMarketGui:mws_reload_bot(wbase, index, txts)
  local weap_tweak = wbase:weapon_tweak_data()
  local weapon_usage_tweak = tweak_data.character.russian.weapon[weap_tweak.usage]
  if BotWeapons.settings.weapon_balance then
    txts['a' .. index]:set_text(('%.2fs'):format(weap_tweak.reload_time))
  else
    txts['a' .. index]:set_text(('%.2f'):format(weapon_usage_tweak.RELOAD_SPEED))
  end
end