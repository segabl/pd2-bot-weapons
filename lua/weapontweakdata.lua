local math_ceil = math.ceil
local math_lerp = math.lerp

local function mean_burst_delay(falloff)
	local delay = 0
	for _, v in ipairs(falloff) do
		delay = delay + (v.recoil[1] + v.recoil[2]) * 0.5
	end
	return delay / #falloff
end

local function set_usage(weapon, usage)
	if not weapon.anim_usage and weapon.usage ~= usage then
		weapon.anim_usage = weapon.usage
	end
	weapon.usage = usage
end

local weapon_table = {
	g17 = "glock_17",
	c45 = "glock_17",
	x_c45 = "x_g17",
	glock_18 = "glock_18c",
	m4 = "new_m4",
	mp5 = "new_mp5",
	ak47 = "ak74",
	ak47_ass = "ak74",
	raging_bull = "new_raging_bull",
	mossberg = "huntsman",
	m14 = "new_m14",
	ben = "benelli",
	beretta92 = "b92fs"
}
function WeaponTweakData:_player_weapon_from_crew_weapon(crew_id)
	crew_id = crew_id:gsub("_crew$", ""):gsub("_secondary$", ""):gsub("_primary$", "")
	return self[weapon_table[crew_id] or crew_id]
end

function WeaponTweakData:setup_crew_weapons(crew_preset)
	local anim_usage_redirects = {
		is_lmg = "is_rifle",
		is_shotgun_mag = "is_rifle"
	}
	local function setup_crew_weapon_data(crew_weapon_name, crew_weapon, player_weapon)
		if not player_weapon then
			BLT:Log(LogLevel.ERROR, "[BWE] Could not find player weapon version of " .. crew_weapon_name .. "!")
			return
		end
		local fire_mode = player_weapon.FIRE_MODE or "single"
		local is_automatic = fire_mode == "auto"
		local fire_rate = player_weapon.fire_mode_data and player_weapon.fire_mode_data.fire_rate or player_weapon[fire_mode] and player_weapon[fire_mode].fire_rate or 1
		local reload_speed = (self.stats.reload[player_weapon.stats.reload] or 1) * 1.5
		if not crew_weapon.old_usage then
			local cat_map = table.list_to_set(player_weapon.categories)

			crew_weapon[fire_mode] = { fire_rate = fire_rate }
			crew_weapon.CLIP_AMMO_MAX = player_weapon.CLIP_AMMO_MAX
			crew_weapon.reload_time = (player_weapon.timers.reload_empty or player_weapon.CLIP_AMMO_MAX * (player_weapon.timers.shotgun_reload_shell or 0.5)) / reload_speed

			if is_automatic then
				if cat_map.flamethrower then
					set_usage(crew_weapon, "is_flamethrower")
				elseif cat_map.shotgun then
					set_usage(crew_weapon, "is_shotgun_mag")
				elseif cat_map.pistol or cat_map.smg then
					set_usage(crew_weapon, "is_smg")
				elseif cat_map.lmg or cat_map.minigun or crew_weapon.CLIP_AMMO_MAX >= 100 then
					set_usage(crew_weapon, "is_lmg")
				else
					set_usage(crew_weapon, "is_rifle")
				end
			else
				if cat_map.shotgun then
					set_usage(crew_weapon, "is_shotgun_pump")
				elseif cat_map.revolver then
					set_usage(crew_weapon, "is_revolver")
				elseif cat_map.snp then
					set_usage(crew_weapon, "is_sniper")
				else
					set_usage(crew_weapon, "is_pistol")
				end
			end
			-- fix anim_usage
			crew_weapon.reload = crew_weapon.reload or (crew_weapon.anim_usage or crew_weapon.usage) == "is_shotgun_pump" and "looped" or nil
			crew_weapon.anim_usage = anim_usage_redirects[crew_weapon.anim_usage or crew_weapon.usage] or crew_weapon.anim_usage or crew_weapon.usage
			-- save original usage
			crew_weapon.old_usage = crew_weapon.usage
		end
		if not crew_preset[crew_weapon.old_usage] then
			BLT:Log(LogLevel.ERROR, "[BWE] No usage preset for " .. crew_weapon_name .. " (" .. crew_weapon.old_usage .. ")!")
			return
		end
		-- clone weapon usage preset to allow unique settings for each weapon
		local preset = deep_clone(crew_preset[crew_weapon.old_usage])
		local recoil = (player_weapon.stats and self.stats.recoil[player_weapon.stats.recoil] or self.stats.recoil[1]) / self.stats.recoil[1]
		local accuracy = (player_weapon.stats and player_weapon.stats.spread or 1) / #self.stats.spread
		local max_r = preset.FALLOFF[#preset.FALLOFF].r
		local mod = crew_weapon.hold == "akimbo_pistol" and 0.5 or crew_weapon.old_usage == "is_shotgun_mag" and 2 or 1
		preset.autofire_rounds = is_automatic and { math_ceil(crew_weapon.CLIP_AMMO_MAX * 0.15 * mod), math_ceil(crew_weapon.CLIP_AMMO_MAX * 0.35 * mod) } or nil
		for _, v in ipairs(preset.FALLOFF) do
			mod = 1 - (v.r / max_r) * 0.65
			v.autofire_rounds = is_automatic and { math_ceil(preset.autofire_rounds[1] * mod), math_ceil(preset.autofire_rounds[2] * mod) } or nil
			mod = (v.r / max_r) * 0.1
			v.recoil = is_automatic and { 0.25 + recoil * 0.5, 0.5 + recoil * 0.5 } or { fire_rate + mod, fire_rate + mod + recoil * 0.1 }
			mod = v.r / max_r
			v.acc = { math_lerp(accuracy, 0, mod), math_lerp(1, accuracy, mod) }
		end
		preset.RELOAD_SPEED = 1
		-- set new usage preset
		crew_weapon.usage = crew_weapon_name
		crew_preset[crew_weapon_name] = preset
		return true
	end

	-- setup reference weapon
	local reference_name, reference, player_reference = "m4_crew", self.m4_crew, self.new_m4
	if not setup_crew_weapon_data(reference_name, reference, player_reference) then
		BLT:Log(LogLevel.ERROR, "[BWE] Reference weapon \"" .. reference_name .. "\" could not be set up, weapon balance option will not work properly!")
		return
	end

	-- target dps for other weapons based on m4
	local w_u_tweak = crew_preset[reference.usage]
	local is_automatic =  w_u_tweak.autofire_rounds and true
	local mag = reference.CLIP_AMMO_MAX
	local burst_size = is_automatic and (w_u_tweak.autofire_rounds[1] + w_u_tweak.autofire_rounds[2]) * 0.5 or 1
	local shot_delay = is_automatic and reference.auto.fire_rate or 0
	local burst_delay = mean_burst_delay(w_u_tweak.FALLOFF)
	local reload_time = reference.reload_time
	local accuracy = (is_automatic or StreamHeist) and (9 + w_u_tweak.FALLOFF[1].acc[1]) / 10 or 1 - w_u_tweak.spread / 100
	local target_damage = (reference.DAMAGE * mag * accuracy) / ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload_time)
	for crew_weapon_name, crew_weapon in pairs(self) do
		if type(crew_weapon) == "table" and crew_weapon_name:match("_crew$") then
			if setup_crew_weapon_data(crew_weapon_name, crew_weapon, self:_player_weapon_from_crew_weapon(crew_weapon_name)) then
				-- calculate weapon damage based on reference dps
				w_u_tweak = crew_preset[crew_weapon.usage]
				is_automatic = w_u_tweak.autofire_rounds and true
				mag = crew_weapon.CLIP_AMMO_MAX
				burst_size = is_automatic and (w_u_tweak.autofire_rounds[1] + w_u_tweak.autofire_rounds[2]) * 0.5 or 1
				shot_delay = is_automatic and crew_weapon.auto.fire_rate or 0
				burst_delay = mean_burst_delay(w_u_tweak.FALLOFF)
				reload_time = crew_weapon.reload_time
				accuracy = (is_automatic or StreamHeist) and (9 + w_u_tweak.FALLOFF[1].acc[1]) / 10 or 1 - w_u_tweak.spread / 100
				crew_weapon.DAMAGE = (target_damage * ((mag / burst_size) * (burst_size - 1) * shot_delay + (mag / burst_size - 1) * burst_delay + reload_time)) / (mag * accuracy)
			end
		end
	end
end
