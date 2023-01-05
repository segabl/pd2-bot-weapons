if not BotWeapons then

	BotWeapons = {}
	BotWeapons.mod_path = ModPath
	BotWeapons.settings_path = SavePath .. "bot_weapons_data.txt"
	BotWeapons.settings = {
		debug = false,
		weapon_balance = true,
		player_carry = true,
		use_flashlights = true,
		use_lasers = false,
		mask_customized_chance = 0.5,
		weapon_customized_chance = 0.5,
		weapon_cosmetics_chance = 0.5,
		outfit_random_chance = 1,
		sync_settings = true,
		chatter = false
	}
	BotWeapons.weapon_categories = {
		"assault_rifle",
		"shotgun",
		"snp",
		"lmg",
		"smg",
		"akimbo",
		"pistol"
	}

	local unit_ids = Idstring("unit")

	function BotWeapons:log(message, condition)
		if condition or condition == nil then
			log("[BotWeapons] " .. message)
		end
	end

	function BotWeapons:init()
		-- load mask sets
		local file = io.open(BotWeapons.mod_path .. "data/masks.json", "r")
		if file then
			self.masks = json.decode(file:read("*all"))
			file:close()
		end
		self.masks = self.masks or {}

		-- load settings
		self:load()

		self:patch_armor_skin_ext()
	end

	function BotWeapons:is_mwc_installed()
		-- check if "more weapon categories" is used
		return tweak_data.weapon.judge.categories[1] == "revolver"
	end

	function BotWeapons:patch_armor_skin_ext()
		if not Unit then
			return
		end

		-- to add armor skin extensions to bots, the easiest solution is to patch the armor_skin function
		local armor_skin = Unit.armor_skin
		Unit.armor_skin = function (unit, ...)
			local base = unit.base and unit:base()
			local base_meta = base and getmetatable(base)
			if not base_meta or base_meta ~= TeamAIBase and base_meta ~= HuskTeamAIBase then
				return armor_skin(unit, ...)
			end

			if not base._armor_skin_ext then
				base._armor_skin_ext = ArmorSkinExt:new(unit)
				base._armor_skin_ext:set_character(base._tweak_table)
				base.update = function (b, ...)
					b._armor_skin_ext:update(...)
				end
				unit:set_extension_update_enabled(Idstring("base"), true)
			end

			return base._armor_skin_ext
		end
	end

	function BotWeapons:check_setup_gadget_colors(unit, weapon_base)
		if weapon_base._setup_team_ai_colors then
			return
		end
		local loadout = managers.criminals:get_loadout_for(unit:base()._tweak_table)
		local category = loadout.primary_category or "primaries"
		local slot = loadout.primary_slot or 0
		local parts = weapon_base._parts or {}
		local colors, data, sub_type, part_base
		for part_id, part_data in pairs(parts) do
			part_base = part_data.unit and part_data.unit:base()
			if part_base and part_base.set_color then
				colors = managers.blackmarket:get_part_custom_colors(category, slot, part_id, true) or loadout.primary_random and {
					laser = loadout.gadget_laser_color or tweak_data.custom_colors.defaults.laser,
					flashlight = tweak_data.custom_colors.defaults.flashlight
				}
				if colors then
					data = tweak_data.weapon.factory.parts[part_id]
					if colors[data.sub_type] then
						part_base:set_color(colors[data.sub_type]:with_alpha(part_base.GADGET_TYPE == "laser" and tweak_data.custom_colors.defaults.laser_alpha or 1))
					end
					for _, add_part_id in ipairs(data.adds or {}) do
						part_data = parts[add_part_id]
						part_base = part_data and part_data.unit and part_data.unit:base()
						if part_base and part_base.set_color then
							sub_type = tweak_data.weapon.factory.parts[add_part_id].sub_type
							if colors[sub_type] then
								part_base:set_color(colors[sub_type])
							end
						end
					end
				end
			end
		end
		weapon_base._setup_team_ai_colors = weapon_base._assembly_complete
	end

	function BotWeapons:should_sync_settings()
		return Network:is_server() and self.settings.sync_settings and not Global.game_settings.single_player
	end

	function BotWeapons:check_set_gadget_state(unit, weapon_base)
		if not weapon_base or not weapon_base.get_gadget_by_type or not alive(unit) or unit:movement():cool() then
			return
		end
		local gadget = self:should_use_flashlight(unit:position()) and weapon_base:get_gadget_by_type("flashlight") or self:should_use_laser() and weapon_base:get_gadget_by_type("laser") or 0
		if gadget == weapon_base._gadget_on then
			return
		end
		self:check_setup_gadget_colors(unit, weapon_base)
		if alive(weapon_base._second_gun) then
			self:check_setup_gadget_colors(unit, weapon_base._second_gun:base())
		end
		weapon_base:set_gadget_on(gadget)
		if self:should_sync_settings() then
			local gadget_base = weapon_base:get_active_gadget()
			if gadget_base and gadget_base.color then
				local col = gadget_base:color()
				managers.network:session():send_to_peers_synched("set_weapon_gadget_color", unit, col.r * 255, col.g * 255, col.b * 255)
			end
			managers.network:session():send_to_peers_synched("set_weapon_gadget_state", unit, weapon_base._gadget_on or 0)
		end
	end

	function BotWeapons:get_sync_data(unit)
		local character = managers.criminals:character_by_unit(unit)
		return {
			name = character.name,
			equip = character.visual_state and character.visual_state.deployable_id,
			armor = character.visual_state and character.visual_state.armor_id,
			skin = character.visual_state and character.visual_state.armor_skin
		}
	end

	function BotWeapons:sync_to_all_peers(unit, sync_delay)
		DelayedCalls:Add("bot_weapons_sync_" .. unit:base()._tweak_table, sync_delay or 0, function ()
			if not alive(unit) then
				return
			end
			LuaNetworking:SendToPeers("bot_weapons_sync", json.encode(self:get_sync_data(unit)))
		end)
	end

	local sun_color_key = Idstring("others/sun_ray_color"):key()
	local sun_color_scale_key = Idstring("others/sun_ray_color_scale"):key()
	local ambient_color_key = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_color"):key()
	local ambient_color_scale_key = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_color_scale"):key()
	function BotWeapons:should_use_flashlight(position)
		if not self.settings.use_flashlights then
			return false
		end
		local environment = position and managers.environment_area and managers.environment_area:environment_at_position(position)
		if not environment then
			return false
		end
		local data = managers.viewport._env_manager:_get_data(environment)
		local sun_col = data[sun_color_key] * math.min(data[sun_color_scale_key] * 0.5, 5)
		local ambient_col = data[ambient_color_key] * data[ambient_color_scale_key]
		return sun_col.x + sun_col.y + sun_col.z + ambient_col.x + ambient_col.y + ambient_col.z < 1
	end

	function BotWeapons:should_use_laser()
		return self.settings.use_lasers
	end

	-- selects and returns a random mask from a set or all masks and a blueprint
	function BotWeapons:get_random_mask(category, char_name)
		if type(category) == "string" and self.masks[category] then
			if self.masks[category].character and self.masks[category].character[char_name] or self.masks[category].pool then
				local selection = self.masks[category].character and self.masks[category].character[char_name] or table.random(self.masks[category].pool)
				return selection.id, selection.blueprint
			else
				return "character_locked", nil
			end
		else
			if not self._masks_data then
				self._masks_data = {}
				self._masks_data.masks = table.map_keys(table.filter(tweak_data.blackmarket.masks, function (v, k) return not v.inaccessible end))
				self._masks_data.colors = table.map_keys(tweak_data.blackmarket.mask_colors)
				self._masks_data.patterns = table.map_keys(tweak_data.blackmarket.textures)
				self._masks_data.materials = table.map_keys(tweak_data.blackmarket.materials)
			end
			local mask = table.random(self._masks_data.masks)
			local blueprint = math.random() < self.settings.mask_customized_chance and {
				color_a = { id = table.random(self._masks_data.colors) },
				color_b = { id = table.random(self._masks_data.colors) },
				pattern = { id = table.random(self._masks_data.patterns) },
				material = { id = table.random(self._masks_data.materials) }
			} or nil
			return mask, blueprint
		end
	end

	-- returns npc version of weapon if it exists
	function BotWeapons:get_npc_version(weapon_id)
		local factory_id = weapon_id and managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
		local tweak = factory_id and tweak_data.weapon.factory[factory_id .. "_npc"]
		return tweak and (not tweak.custom or tweak.unit and DB:has(unit_ids, tweak.unit:id())) and factory_id .. "_npc"
	end

	-- selects a random weapon and constructs a random blueprint for it
	function BotWeapons:get_random_weapon(category)
		local check_cat = self:is_mwc_installed() and 2 or 1
		local cat = type(category) ~= "string" and table.random(self.weapon_categories) or category
		if not self._weapons or not self._weapons[cat] then
			self._weapons = self._weapons or {}
			self._weapons[cat] = {}
			for weapon_id, data in pairs(tweak_data.weapon) do
				if data.autohit and (data.categories[check_cat] or data.categories[1]) == cat then
					local factory_id = self:get_npc_version(weapon_id)
					if factory_id then
						table.insert(self._weapons[cat], {
							category = data.use_data.selection_index == 2 and "primaries" or "secondaries",
							factory_id = factory_id,
							weapon_id = weapon_id,
						})
					end
				end
			end
		end
		local weapon = table.random(self._weapons[cat])
		if not weapon then
			return
		end
		if math.random() < self.settings.weapon_cosmetics_chance then
			local cosmetics = table.random_key(managers.blackmarket:get_cosmetics_by_weapon_id(weapon.weapon_id))
			local cosmetics_data = tweak_data.blackmarket.weapon_skins[cosmetics]
			if cosmetics then
				weapon.cosmetics = {
					id = cosmetics,
					quality = table.random_key(tweak_data.economy.qualities),
					color_index = cosmetics_data.is_a_color_skin and math.random(#cosmetics_data)
				}
			end
		end
		weapon.blueprint = deep_clone(weapon.cosmetics and tweak_data.blackmarket.weapon_skins[weapon.cosmetics.id].default_blueprint or tweak_data.weapon.factory[weapon.factory_id].default_blueprint)
		local forbidden = managers.weapon_factory:_get_forbidden_parts(weapon.factory_id, weapon.blueprint)
		for _, parts_data in pairs(managers.blackmarket:get_dropable_mods_by_weapon_id(weapon.weapon_id)) do
			if math.random() < self.settings.weapon_customized_chance then
				local part_data = table.random(parts_data)
				if part_data and not forbidden[part_data[1]] then
					local factory_data = tweak_data.weapon.factory.parts[part_data[1]]
					if factory_data and (not factory_data.custom or factory_data.third_unit and DB:has(unit_ids, factory_data.third_unit:id())) then
						managers.weapon_factory:change_part_blueprint_only(weapon.factory_id, part_data[1], weapon.blueprint)
						forbidden = managers.weapon_factory:_get_forbidden_parts(weapon.factory_id, weapon.blueprint)
					end
				end
			end
		end
		return weapon.factory_id, weapon.category, weapon.blueprint, weapon.cosmetics
	end

	function BotWeapons:get_random_armor(category)
		return table.random_key(tweak_data.blackmarket.armors)
	end

	function BotWeapons:get_random_player_style(category)
		if not self._player_styles then
			self._player_styles = table.map_keys(table.filter(tweak_data.blackmarket.player_styles, function (v, k) return not k ~= "none" end))
		end
		return table.random(self._player_styles)
	end

	function BotWeapons:get_random_suit_variation(category, player_style)
		if not tweak_data.blackmarket:have_suit_variations(player_style) then
			return "default"
		end
		return table.random_key(tweak_data.blackmarket.player_styles[player_style].material_variations)
	end

	function BotWeapons:get_random_gloves(category)
		return table.random_key(tweak_data.blackmarket.gloves)
	end

	function BotWeapons:get_random_glove_variation(category, glove_id)
		if not tweak_data.blackmarket:have_glove_variations(glove_id) then
			return "default"
		end
		return table.random_key(tweak_data.blackmarket.gloves[glove_id].variations)
	end

	function BotWeapons:get_random_armor_skin(category)
		return table.random_key(tweak_data.economy.armor_skins)
	end

	function BotWeapons:get_random_deployable(category)
		return table.random_key(tweak_data.blackmarket.deployables)
	end

	function BotWeapons:get_char_loadout(char_name)
		return char_name and type(self.settings[char_name]) == "table" and self.settings[char_name] or {}
	end

	function BotWeapons:get_loadout(char_name, original_loadout, refresh)
		if not char_name or not original_loadout then
			return original_loadout
		end
		if not refresh and self._loadouts and self._loadouts[char_name] and self._loadouts[char_name].henchman_loadout == original_loadout then
			return self._loadouts[char_name]
		end
		local loadout = deep_clone(original_loadout)
		loadout.henchman_loadout = original_loadout
		if not Utils:IsInGameState() or Network:is_server() then

			local char_loadout = self:get_char_loadout(char_name)

			-- choose mask
			if loadout.mask == "character_locked" or loadout.mask_random then
				loadout.mask_slot = nil
				if not loadout.mask_random then
					loadout.mask = char_loadout.mask or "character_locked"
					loadout.mask_random = char_loadout.mask_random
					loadout.mask_blueprint = char_loadout.mask_blueprint
				end
				if loadout.mask_random then
					loadout.mask, loadout.mask_blueprint = self:get_random_mask(loadout.mask_random, char_name)
				end
			elseif loadout.mask_slot then
				local crafted = managers.blackmarket:get_crafted_category_slot("masks", loadout.mask_slot)
				if crafted then
					loadout.mask_blueprint = crafted.blueprint
				end
			end
			-- check for invalid mask
			if not tweak_data.blackmarket.masks[loadout.mask] then
				self:log("WARNING: Mask " .. tostring(loadout.mask) .. " does not exist, removed it from " .. char_name .. "!", loadout.mask)
				loadout.mask = "character_locked"
				loadout.mask_blueprint = nil
			end
			-- convert old color data to new system
			if loadout.mask_blueprint and loadout.mask_blueprint.color then
				local color = tweak_data.blackmarket.colors[loadout.mask_blueprint.color.id]
				if color then
					loadout.mask_blueprint.color_a = { id = color.color_ids[1] }
					loadout.mask_blueprint.color_b = { id = color.color_ids[2] }
				else
					self:log("WARNING: Mask blueprint is invalid, removed it from " .. char_name .. "!", loadout.mask)
					loadout.mask_blueprint = nil
				end
			end

			-- choose weapon
			if not loadout.primary or loadout.primary_random then
				loadout.primary_slot = nil
				if not loadout.primary_random then
					loadout.primary = char_loadout.primary
					loadout.primary_random = char_loadout.primary_random
					loadout.primary_blueprint = char_loadout.primary_blueprint
					loadout.primary_cosmetics = char_loadout.primary_cosmetics
				end
				if loadout.primary_random then
					loadout.primary, loadout.primary_category, loadout.primary_blueprint, loadout.primary_cosmetics = self:get_random_weapon(loadout.primary_random)
					loadout.gadget_laser_color = Color(hsv_to_rgb(math.random(360), 1, 0.4 + math.random() * 0.4))
				end
			elseif loadout.primary_slot then
				local crafted = managers.blackmarket:get_crafted_category_slot(loadout.primary_category or "primaries", loadout.primary_slot)
				if crafted then
					loadout.primary_blueprint = crafted.blueprint
					loadout.primary_cosmetics = crafted.cosmetics
				end
			end
			-- check for invalid weapon or weapon parts
			if loadout.primary and not tweak_data.weapon.factory[loadout.primary] then
				self:log("WARNING: Weapon " .. loadout.primary .. " does not exist, removed it from " .. char_name .. "!")
				loadout.primary = nil
				loadout.primary_blueprint = nil
			end
			for _, part in pairs(loadout.primary_blueprint or {}) do
				if not tweak_data.weapon.factory.parts[part] then
					self:log("WARNING: Weapon part " .. part .. " does not exist, removed weapon blueprint from " .. char_name .. "!")
					loadout.primary_blueprint = nil
					break
				end
			end

			-- choose outfit
			if not loadout.player_style or loadout.player_style_random then
				if not loadout.player_style_random then
					loadout.player_style = char_loadout.player_style
					loadout.player_style_random = char_loadout.player_style_random
					loadout.suit_variation = char_loadout.suit_variation
					loadout.suit_variation_random = char_loadout.suit_variation_random
				end
				if loadout.player_style_random then
					if math.random() < self.settings.outfit_random_chance then
						loadout.player_style = self:get_random_player_style(loadout.player_style_random)
						loadout.suit_variation_random = true
					else
						loadout.player_style = loadout.player_style or managers.blackmarket:get_default_player_style()
						loadout.suit_variation = "default"
						loadout.suit_variation_random = false
					end
				end
			end
			-- check for invalid outfit
			loadout.player_style = loadout.player_style or managers.blackmarket:get_default_player_style()
			if not tweak_data.blackmarket.player_styles[loadout.player_style] then
				self:log("WARNING: Player style " .. tostring(loadout.player_style) .. " does not exist, removed it from " .. char_name .. "!")
				loadout.player_style = managers.blackmarket:get_default_player_style()
			end
			loadout.suit_variation = loadout.suit_variation or "default"
			if loadout.suit_variation_random then
				loadout.suit_variation = self:get_random_suit_variation(loadout.suit_variation_random, loadout.player_style)
			elseif not tweak_data.blackmarket:have_suit_variations(loadout.player_style) then
				loadout.suit_variation = "default"
			elseif not tweak_data.blackmarket.player_styles[loadout.player_style].material_variations[loadout.suit_variation] then
				self:log("WARNING: Suit variant " .. tostring(loadout.suit_variation) .. " does not exist, removed it from " .. char_name .. "!")
				loadout.suit_variation = "default"
			end

			-- choose gloves
			if not loadout.glove_id or loadout.glove_id_random then
				if not loadout.glove_id_random then
					loadout.glove_id = char_loadout.glove_id
					loadout.glove_id_random = char_loadout.glove_id_random
					loadout.glove_variation = char_loadout.glove_variation
					loadout.glove_variation_random = char_loadout.glove_variation_random
				end
				if loadout.glove_id_random then
					loadout.glove_id = self:get_random_gloves(loadout.glove_id_random)
					loadout.glove_variation_random = true
				end
			end
			-- check for invalid gloves
			loadout.glove_id = loadout.glove_id or managers.blackmarket:get_default_glove_id()
			if not tweak_data.blackmarket.gloves[loadout.glove_id] then
				self:log("WARNING: Gloves " .. tostring(loadout.glove_id) .. " does not exist, removed it from " .. char_name .. "!")
				loadout.glove_id = managers.blackmarket:get_default_glove_id()
			end
			if tweak_data.blackmarket.have_glove_variations then
				loadout.glove_variation = loadout.glove_variation or "default"
				if loadout.glove_variation_random then
					loadout.glove_variation = self:get_random_glove_variation(loadout.glove_variation_random, loadout.glove_id)
				elseif not tweak_data.blackmarket:have_glove_variations(loadout.glove_id) then
					loadout.glove_variation = "default"
				elseif not tweak_data.blackmarket.gloves[loadout.glove_id].variations or not tweak_data.blackmarket.gloves[loadout.glove_id].variations[loadout.glove_variation] then
					self:log("WARNING: Glove variant " .. tostring(loadout.glove_variation) .. " does not exist, removed it from " .. char_name .. "!")
					loadout.glove_variation = "default"
				end
			end

			-- choose armor models
			if not loadout.armor or loadout.armor_random then
				if not loadout.armor_random then
					loadout.armor = char_loadout.armor
					loadout.armor_random = char_loadout.armor_random
				end
				if loadout.armor_random then
					loadout.armor = self:get_random_armor(loadout.armor_random)
				end
			end
			-- check for invalid armor
			if loadout.armor and not tweak_data.blackmarket.armors[loadout.armor] then
				self:log("WARNING: Armor " .. tostring(loadout.armor) .. " does not exist, removed it from " .. char_name .. "!", loadout.armor)
				loadout.armor = "level_1"
			end

			-- choose armor skin
			if not loadout.armor_skin or loadout.armor_skin_random then
				if not loadout.armor_skin_random then
					loadout.armor_skin = char_loadout.armor_skin
					loadout.armor_skin_random = char_loadout.armor_skin_random
				end
				if loadout.armor_skin_random then
					loadout.armor_skin = self:get_random_armor_skin(loadout.armor_skin_random)
				end
			end
			-- check for invalid armor skin
			if loadout.armor_skin and not tweak_data.economy.armor_skins[loadout.armor_skin] then
				self:log("WARNING: Armor Skin " .. tostring(loadout.armor_skin) .. " does not exist, removed it from " .. char_name .. "!", loadout.armor_skin)
				loadout.armor_skin = "none"
			end

			-- choose equipment models
			if not loadout.deployable or loadout.deployable_random then
				if not loadout.deployable_random then
					loadout.deployable = char_loadout.deployable
					loadout.deployable_random = char_loadout.deployable_random
				end
				if loadout.deployable_random then
					loadout.deployable = self:get_random_deployable(loadout.deployable_random)
				end
			end
			-- check for invalid deployable
			if loadout.deployable and not tweak_data.upgrades.definitions[loadout.deployable] then
				self:log("WARNING: Deployable " .. tostring(loadout.deployable) .. " does not exist, removed it from " .. char_name .. "!")
				loadout.deployable = nil
			end

		end
		self._loadouts = self._loadouts or {}
		self._loadouts[char_name] = loadout
		return loadout
	end

	function BotWeapons:set_character_loadout(char_name, loadout)
		if not char_name then
			return
		end
		if not loadout then
			self.settings[char_name] = nil
			return
		end
		self.settings[char_name] = {
			armor = not loadout.armor_random and loadout.armor or nil,
			armor_random = loadout.armor_random or nil,
			armor_skin = not loadout.armor_skin_random and loadout.armor_skin or nil,
			armor_skin_random = loadout.armor_skin_random or nil,
			player_style = not loadout.player_style_random and loadout.player_style or nil,
			player_style_random = loadout.player_style_random or nil,
			suit_variation = not loadout.suit_variation_random and loadout.suit_variation or nil,
			suit_variation_random = loadout.suit_variation_random or nil,
			glove_id = not loadout.glove_id_random and loadout.glove_id or nil,
			glove_id_random = loadout.glove_id_random or nil,
			glove_variation = not loadout.glove_variation_random and loadout.glove_variation or nil,
			glove_variation_random = loadout.glove_variation_random or nil,
			deployable = not loadout.deployable_random and loadout.deployable or nil,
			deployable_random = loadout.deployable_random or nil,
			mask = not loadout.mask_random and loadout.mask or nil,
			mask_blueprint = not loadout.mask_random and loadout.mask_blueprint or nil,
			mask_random = loadout.mask_random or nil,
			primary = not loadout.primary_random and loadout.primary or nil,
			primary_blueprint = not loadout.primary_random and loadout.primary_blueprint or nil,
			primary_cosmetics = not loadout.primary_random and loadout.primary_cosmetics or nil,
			primary_random = loadout.primary_random or nil
		}
	end

	function BotWeapons:save()
		local file = io.open(self.settings_path, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		end
	end

	function BotWeapons:load()
		local file = io.open(self.settings_path, "r")
		if file then
			local data = json.decode(file:read("*all"))
			file:close()
			if data then
				for k, v in pairs(data) do
					self.settings[k] = v
				end
			end
		end
	end

	function BotWeapons:update_chatter(t)
		if not Utils:IsInHeist() or not managers.chat then
			return
		end
		if not self._next_quote_check_t then
			self._next_quote_check_t = t + math.random(60, 120)
			return
		end
		if self._next_quote_check_t < t then
			if self._current_quote then

				local actor
				local line = self._current_quote[self._current_quote_index]:gsub("^$([1-3]):", function (n)
					actor = n
					return ""
				end)
				local data = self._available_ai[tonumber(actor)]

				if data then
					line = line:gsub("$p", managers.network.account:username())
					line = line:gsub("$([1-3])", function (n)
						local ref = self._available_ai[tonumber(n)]
						return ref and ref.name or n
					end)
					managers.chat:_receive_message(1, data.name, line, tweak_data.chat_colors[data.color] or tweak_data.system_chat_color)
				end

				if self._current_quote_index < #self._current_quote then
					local same_actor = self._current_quote[self._current_quote_index + 1]:match("^$([1-3]):") == actor
					self._next_quote_check_t = same_actor and t or t + 0.25 + self._current_quote[self._current_quote_index]:len() / 40
					self._current_quote_index = self._current_quote_index + 1
					self._next_quote_check_t = self._next_quote_check_t + 0.5 + self._current_quote[self._current_quote_index]:len() / 20
				else
					self._current_quote = nil
					self._next_quote_check_t = t + math.random(120, 240)
				end
			else
				self._available_ai = {}
				for _, v in pairs(managers.groupai:state():all_AI_criminals()) do
					if alive(v.unit) then
						table.insert(self._available_ai, {
							name = v.unit:base():nick_name(),
							color = managers.criminals:character_color_id_by_unit(v.unit)
						})
					end
				end
				table.shuffle(self._available_ai)

				local weight, num = 0, 0
				for i = 1, math.min(#self._available_ai, 3) do
					weight = weight + #self.chatter_quotes[i]
				end
				weight = math.random(weight)
				while weight > 0 do
					num = num + 1
					weight = weight - #self.chatter_quotes[num]
				end
				self._current_quote = table.remove(self.chatter_quotes[num], math.random(#self.chatter_quotes[num]))
				self._current_quote_index = 1

				self._used_quotes = self._used_quotes or {}
				self._used_quotes[num] = self._used_quotes[num] or {}
				table.insert(self._used_quotes[num], self._current_quote)
				if #self.chatter_quotes[num] == 0 then
					self.chatter_quotes[num] = self._used_quotes[num]
					self._used_quotes[num] = {}
				end
			end
		end
	end

	-- initialize
	BotWeapons:init()

	Hooks:Add("NetworkReceivedData", "NetworkReceivedDataBotWeapons", function (sender, id, data)
		if id ~= "bot_weapons_sync" then
			return
		end

		data = json.decode(data)

		local character = managers.criminals:character_by_name(data and data.name)
		local visual_state = character and alive(character.unit) and character.visual_state
		if not visual_state then
			return
		end

		visual_state.armor_id = tweak_data.blackmarket.armors[data.armor] and data.armor or visual_state.armor_id
		visual_state.armor_skin = tweak_data.economy.armor_skins[data.skin] and data.skin or visual_state.armor_skin
		visual_state.deployable_id = tweak_data.upgrades.definitions[data.equip] and data.equip or visual_state.deployable_id

		managers.criminals:update_character_visual_state(data.name, visual_state)
	end)

end

local required = {}
if RequiredScript and not required[RequiredScript] then

	local fname = BotWeapons.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	required[RequiredScript] = true

end
