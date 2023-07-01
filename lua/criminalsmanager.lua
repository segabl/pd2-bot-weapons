local _reserve_loadout_for_original = CriminalsManager._reserve_loadout_for
function CriminalsManager:_reserve_loadout_for(char_name, ...)
	return BotWeapons:get_loadout(char_name, _reserve_loadout_for_original(self, char_name, ...))
end

local get_loadout_for_original = CriminalsManager.get_loadout_for
function CriminalsManager:get_loadout_for(char_name, ...)
	return BotWeapons:get_loadout(char_name, get_loadout_for_original(self, char_name, ...))
end

local update_character_visual_state_original = CriminalsManager.update_character_visual_state
function CriminalsManager:update_character_visual_state(character_name, visual_state, ...)
	local character = self:character_by_name(character_name)
	if Network:is_server() and character and character.taken and character.data.ai and alive(character.unit) then
		local loadout = self:get_loadout_for(character_name)
		visual_state = visual_state or {}
		visual_state.glove_variation = visual_state.glove_variation or loadout.glove_variation
		visual_state.deployable_id = loadout.deployable
		visual_state.armor_id = loadout.armor
		visual_state.armor_skin = loadout.armor_skin

		if BotWeapons:should_sync_settings() then
			BotWeapons:sync_to_all_peers(character.unit, 1)
		end
	end

	if character and character.taken and character.data.ai and visual_state.armor_skin and visual_state.armor_skin ~= "none" then
		if not visual_state.player_style or visual_state.player_style == managers.blackmarket:get_default_player_style() then
			BotWeapons:patch_armor_skin_ext()
		end
	end

	return update_character_visual_state_original(self, character_name, visual_state, ...)
end

function CriminalsManager:get_free_character_name()
	local name = managers.blackmarket:preferred_henchmen(self:nr_AI_criminals() + 1)
	if name then
		local data = table.find_value(self._characters, function (val) return val.name == name end)
		if data and not data.taken then
			return name
		end
	end

	local available = {}
	for _, data in pairs(self._characters) do
		if not data.taken and not self:is_character_as_AI_level_blocked(data.name) then
			table.insert(available, data.name)
		end
	end

	if #available > 0 then
		math.randomseed(os.clock() * 1000 * #available)
		math.random()
		math.random()
		math.random()
		return table.random(available)
	end
end
