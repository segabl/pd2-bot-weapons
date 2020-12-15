if not BotWeapons.settings.weapon_balance then
	return
end

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(tweak_data, ...)
	local presets = _presets_original(self, tweak_data, ...)

	local gang_presets = presets.weapon.gang_member

	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings and Global.game_settings.difficulty or "normal")
	local rifle_dmg_mul = StreamHeist and gang_presets.is_rifle.FALLOFF[1].dmg_mul or difficulty_index * 0.75

	BotWeapons:log("Preparing base crew weapon presets, reference dmg_mul is " .. rifle_dmg_mul)

	-- rifle preset
	gang_presets.is_rifle.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.8, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.6, r = 1000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.4, r = 2000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.2, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } }
	}
	gang_presets.is_rifle.spread = 15
	gang_presets.is_bullpup = gang_presets.is_rifle
	gang_presets.rifle = gang_presets.is_rifle

	-- sniper preset
	gang_presets.is_sniper.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.5, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.5, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
	}
	gang_presets.is_sniper.spread = 5
	gang_presets.is_revolver = gang_presets.is_sniper

	-- pistol preset
	gang_presets.is_pistol.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.7, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.3, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
	}
	gang_presets.is_pistol.spread = 10
	gang_presets.akimbo_pistol = gang_presets.is_pistol

	-- LMG preset
	gang_presets.is_lmg.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 0.9, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.1, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
	}
	gang_presets.is_lmg.spread = 15
	gang_presets.is_smg = gang_presets.is_lmg
	gang_presets.mac11 = gang_presets.is_lmg

	-- shotgun preset
	gang_presets.is_shotgun_pump.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 1.0, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
		{ dmg_mul = rifle_dmg_mul * 0.0, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
	}
	gang_presets.is_shotgun_pump.spread = 10

	-- auto shotgun preset
	gang_presets.is_shotgun_mag.FALLOFF = {
		{ dmg_mul = rifle_dmg_mul * 1.0, r = 0, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
		{ dmg_mul = rifle_dmg_mul * 0.0, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 0, 0, 0, 1 } },
	}
	gang_presets.is_shotgun_mag.spread = 15

	tweak_data.weapon:setup_crew_weapons(gang_presets)

	return presets
end
