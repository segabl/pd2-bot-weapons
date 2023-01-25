if not BotWeapons.settings.weapon_balance then
	return
end

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(tweak_data, ...)
	local presets = _presets_original(self, tweak_data, ...)

	local crew_presets = presets.weapon.gang_member

	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings and Global.game_settings.difficulty or "normal")
	local rifle_dmg_mul = StreamHeist and crew_presets.is_rifle.FALLOFF[1].dmg_mul or difficulty_index * 0.75

	-- rifle preset
	crew_presets.is_rifle.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.8, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.2, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } }
	}
	crew_presets.is_rifle.spread = 10
	crew_presets.is_bullpup = crew_presets.is_rifle
	crew_presets.rifle = crew_presets.is_rifle

	-- sniper preset
	crew_presets.is_sniper.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.5, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.5, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
	}
	crew_presets.is_sniper.spread = 5
	crew_presets.is_revolver = crew_presets.is_sniper

	-- pistol preset
	crew_presets.is_pistol.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.7, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.3, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
	}
	crew_presets.is_pistol.spread = 10
	crew_presets.akimbo_pistol = crew_presets.is_pistol

	-- LMG preset
	crew_presets.is_lmg.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.9, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.1, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
	}
	crew_presets.is_lmg.spread = 15
	crew_presets.is_smg = crew_presets.is_lmg
	crew_presets.mac11 = crew_presets.is_lmg

	-- shotgun preset
	crew_presets.is_shotgun_pump.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 1.0, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.0, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
	}
	crew_presets.is_shotgun_pump.spread = 10

	-- auto shotgun preset
	crew_presets.is_shotgun_mag.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 1.0, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.0, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
	}
	crew_presets.is_shotgun_mag.spread = 15

	-- flamethrower preset
	crew_presets.is_flamethrower = deep_clone(crew_presets.is_lmg)
	crew_presets.is_flamethrower.range = { optimal = 900, far = 1800, close = 450 }
	crew_presets.is_flamethrower.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 2, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.0, r = 2000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
	}
	crew_presets.is_flamethrower.spread = 15

	tweak_data.weapon:setup_crew_weapons(crew_presets)

	return presets
end
