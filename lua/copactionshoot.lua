if StreamHeist then
	return
end

TeamAIActionShoot = class(CopActionShoot)

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
			autofire_rounds = prev_data.autofire_rounds and {
				lerp(prev_data.autofire_rounds[1], data.autofire_rounds[1], t),
				lerp(prev_data.autofire_rounds[2], data.autofire_rounds[2], t)
			},
			mode = data.mode
		}
		return n_data, i
	end
end
