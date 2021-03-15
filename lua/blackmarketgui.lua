-- compatibility for More Weapon Stats
function BlackMarketGui.mws_CopActionShoot_get_shoot_falloff(target_dis, falloff)
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
			recoil = { math.lerp(prev_data.recoil[1], data.recoil[1], t), math.lerp(prev_data.recoil[2], data.recoil[2], t) },
		}
		return n_data, i
	end
end

local mws_falloff_bot_original = BlackMarketGui.mws_falloff_bot
function BlackMarketGui:mws_falloff_bot(wbase, index, txts, ...)
	mws_falloff_bot_original(self, wbase, index, txts, ...)
	local weap_tweak = wbase:weapon_tweak_data()
	local weapon_usage_tweak = tweak_data.character.russian.weapon[weap_tweak.usage]
	if weapon_usage_tweak.autofire_rounds or StreamHeist then
		return
	end
	txts['b' .. index]:set_text((' | %i%%'):format(100 * (1 - weapon_usage_tweak.spread / 100)))
end

function BlackMarketGui:mws_reload_bot(wbase, index, txts)
	local weap_tweak = wbase:weapon_tweak_data()
	local weapon_usage_tweak = tweak_data.character.russian.weapon[weap_tweak.usage]
	if BotWeapons.settings.weapon_balance and weap_tweak.reload_time then
		txts['a' .. index]:set_text(('%.2fs'):format(weap_tweak.reload_time))
	else
		txts['a' .. index]:set_text(('%.2f'):format(weapon_usage_tweak.RELOAD_SPEED))
	end
end
