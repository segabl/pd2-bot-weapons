if not BotWeapons.settings.weapon_balance then
	return
end

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(tweak_data, ...)
	local presets = _presets_original(self, tweak_data, ...)

	local crew_presets = deep_clone(presets.weapon.gang_member)

	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings and Global.game_settings.difficulty or "normal")
	local rifle_dmg_mul = difficulty_index * 0.75

	-- rifle preset
	crew_presets.is_rifle.RELOAD_SPEED = 1
	crew_presets.is_rifle.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.7, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.3, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } }
	}

	-- sniper preset
	crew_presets.is_sniper.RELOAD_SPEED = 1
	crew_presets.is_sniper.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.5, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.5, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
	}

	-- pistol preset
	crew_presets.is_pistol.RELOAD_SPEED = 1
	crew_presets.is_pistol.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.8, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.2, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
	}

	-- LMG preset
	crew_presets.is_lmg.RELOAD_SPEED = 1
	crew_presets.is_lmg.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.9, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.1, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } }
	}

	-- shotgun preset
	crew_presets.is_shotgun_pump.RELOAD_SPEED = 1
	crew_presets.is_shotgun_pump.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 1.0, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.0, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
	}

	-- auto shotgun preset
	crew_presets.is_shotgun_mag.RELOAD_SPEED = 1
	crew_presets.is_shotgun_mag.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 1.0, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.0, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } }
	}

	-- flamethrower preset
	crew_presets.is_flamethrower.RELOAD_SPEED = 1
	crew_presets.is_flamethrower = deep_clone(crew_presets.is_lmg)
	crew_presets.is_flamethrower.range = { optimal = 900, far = 1800, close = 450 }
	crew_presets.is_flamethrower.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 2, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 1, r = 1000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.0, r = 2000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } }
	}

	-- spread does nothing in SH so don't confuse people that use more weapon stats
	if not StreamHeist then
		crew_presets.is_flamethrower.spread = 15
		crew_presets.is_lmg.spread = 15
		crew_presets.is_pistol.spread = 10
		crew_presets.is_rifle.spread = 10
		crew_presets.is_shotgun_mag.spread = 15
		crew_presets.is_shotgun_pump.spread = 10
		crew_presets.is_sniper.spread = 5
	end

	crew_presets.akimbo_pistol = crew_presets.is_pistol
	crew_presets.is_bullpup = crew_presets.is_rifle
	crew_presets.is_revolver = crew_presets.is_sniper
	crew_presets.is_smg = crew_presets.is_lmg
	crew_presets.mac11 = crew_presets.is_lmg
	crew_presets.mini = crew_presets.is_lmg
	crew_presets.rifle = crew_presets.is_rifle

	tweak_data.weapon:setup_crew_weapons(crew_presets)

	presets.weapon.bot_weapons = crew_presets

	return presets
end

Hooks:PostHook(CharacterTweakData, "_init_team_ai", "_init_team_ai_bot_weapons", function (self, presets)
	for k, v in pairs(self) do
		if type(v) == "table" and v.access == "teamAI1" then
			v.weapon = presets.weapon.bot_weapons
		end
	end
end)
