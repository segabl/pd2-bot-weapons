local BEARDLIB_GLOVEVARS_INSTALLED = MenuSceneManager.preview_gloves_and_variation and true or false

-- lots of stuff to copy from the original file since OVK made it local
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local make_fine_text = function(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end
local fit_texture = function(bitmap, target_w, target_h)
	local texture_width = bitmap:texture_width()
	local texture_height = bitmap:texture_height()
	local panel_width, panel_height = bitmap:parent():size()
	target_w = target_w or bitmap:parent():w()
	target_h = target_h or bitmap:parent():h()
	local aspect = target_w / target_h
	local sw = math.max(texture_width, texture_height * aspect)
	local sh = math.max(texture_height, texture_width / aspect)
	local dw = texture_width / sw
	local dh = texture_height / sh
	bitmap:set_size(math.round(dw * target_w), math.round(dh * target_h))
end

function CrewManagementGui:init(ws, fullscreen_ws, node)
	CriminalsManager.MAX_NR_TEAM_AI = LobbySettings and LobbySettings.original_MAX_NR_TEAM_AI or CriminalsManager.MAX_NR_TEAM_AI

	managers.menu_component:close_contract_gui()
	managers.blackmarket:verfify_crew_loadout()
	MenuCallbackHandler:reset_crew_outfit()

	if alive(CrewManagementGui.panel_crash_protection) then
		CrewManagementGui.panel_crash_protection:parent():remove(CrewManagementGui.panel_crash_protection)
	end

	self._node = node
	node:parameters().data = node:parameters().data or {}
	self._panel = ws:panel():panel()
	CrewManagementGui.panel_crash_protection = self._panel
	self._item_w = 136
	self._item_h = 78
	self._image_max_h = 54
	self._buttons = {}
	self._buttons_no_nav = {}

	local title_text = self._panel:text({
		text = managers.localization:to_upper_text("menu_crew_management"),
		font = large_font,
		font_size = large_font_size
	})
	make_fine_text(title_text)
	local loadout_text = self._panel:text({
		text = managers.localization:text("menu_crew_loadout_order"),
		font = medium_font,
		font_size = medium_font_size,
		y = medium_font_size
	})
	make_fine_text(loadout_text)

	local back_button = self._panel:text({
		name = "back_button",
		text = managers.localization:text("menu_back"),
		align = "right",
		vertical = "bottom",
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3,
		layer = 40,
		blend_mode = "add"
	})
	make_fine_text(back_button)
	back_button:set_right(self._panel:w())
	back_button:set_bottom(self._panel:h())
	back_button:set_visible(managers.menu:is_pc_controller())
	local back = CrewManagementGuiButton:new(self, function()
		managers.menu:back(true)
	end, true)
	back._panel = back_button
	back._select_col = tweak_data.screen_colors.button_stage_2
	back._normal_col = tweak_data.screen_colors.button_stage_3
	back._selected_changed = CrewManagementGuiTextButton._selected_changed

	local info_panel
	if managers.menu:is_pc_controller() then
		info_panel = self._panel:panel({
			w = 30,
			h = 24
		})
		local info_icon = info_panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/inv_newdrop"
		})

		info_icon:set_texture_coordinates(Vector3(0, 16, 0), Vector3(16, 16, 0), Vector3(0, 0, 0), Vector3(16, 0, 0))
		info_icon:set_center(info_panel:center())

		local info_button = CrewManagementGuiButton:new(self, callback(self, self, "show_help_dialog"), true)
		info_button._panel = info_panel
		info_button._select_col = Color.white:with_alpha(0.25)
		info_button._normal_col = Color.white

		function info_button:_selected_changed(state)
			info_icon:set_color(state and self._select_col or self._normal_col)
		end
	end

	self._1_panel = self._panel:panel({
		h = 0,
		w = self._item_w,
		y = loadout_text:bottom()
	})
	self._2_panel = self._panel:panel({
		h = 0,
		w = self._item_w,
		y = loadout_text:bottom()
	})
	self._3_panel = self._panel:panel({
		h = 0,
		w = self._item_w,
		y = loadout_text:bottom()
	})
	self._btn_panels = {
		self._1_panel,
		self._2_panel,
		self._3_panel
	}
	self._3_panel:set_right(self._panel:right())
	self._2_panel:set_right(self._3_panel:left() - 10)
	self._1_panel:set_right(self._2_panel:left() - 10)
	for i, panel in pairs(self._btn_panels) do
		local slot_text = self._panel:text({
			text = managers.localization:text("menu_crew_slot_index", {index = i}),
			font = small_font,
			font_size = small_font_size
		})
		make_fine_text(slot_text)
		slot_text:set_lefttop(panel:lefttop())
		panel:set_top(slot_text:bottom())
	end
	loadout_text:set_left(self._1_panel:left())

	if info_panel then
		info_panel:set_center_y(loadout_text:center_y())
		info_panel:set_left(loadout_text:right())
	end

	self._item_h = (back_button:top() - 18 - self._1_panel:top()) / 7
	self._image_max_h = math.min(self._item_h * 0.65, 96)

	self:create_character_button(self._1_panel, 1)
	self:create_character_button(self._2_panel, 2)
	self:create_character_button(self._3_panel, 3)
	self:new_row()
	self:create_mask_button(self._1_panel, 1)
	self:create_mask_button(self._2_panel, 2)
	self:create_mask_button(self._3_panel, 3)
	self:new_row()
	self:create_weapon_button(self._1_panel, 1)
	self:create_weapon_button(self._2_panel, 2)
	self:create_weapon_button(self._3_panel, 3)
	self:new_row()
	self:create_deployable_button(self._1_panel, 1)
	self:create_deployable_button(self._2_panel, 2)
	self:create_deployable_button(self._3_panel, 3)
	self:new_row()
	self:create_armor_button(self._1_panel, 1)
	self:create_armor_button(self._2_panel, 2)
	self:create_armor_button(self._3_panel, 3)
	self:new_row()
	self:create_ability_button(self._1_panel, 1)
	self:create_ability_button(self._2_panel, 2)
	self:create_ability_button(self._3_panel, 3)
	self:new_row()
	self:create_skill_button(self._1_panel, 1)
	self:create_skill_button(self._2_panel, 2)
	self:create_skill_button(self._3_panel, 3)
	self:new_row()

	local character_text = self._panel:text({
		text = managers.localization:to_upper_text("menu_character_settings_name"),
		font = medium_font,
		font_size = medium_font_size
	})
	make_fine_text(character_text)
	character_text:set_right(loadout_text:x() - small_font_size)
	character_text:set_y(loadout_text:y())
	local character_settings = CrewManagementGuiButton:new(self, function()
		self:show_character_specific_settings()
	end, true)
	character_settings._panel = character_text
	character_settings._select_col = tweak_data.screen_colors.button_stage_2
	character_settings._normal_col = tweak_data.screen_colors.button_stage_3
	character_settings._selected_changed = CrewManagementGuiTextButton._selected_changed

	for _, v in pairs(self._btn_panels) do
		BoxGuiObject:new(v, {
			sides = { 1, 1, 2, 1 }
		})
		v:bitmap({
			texture = "guis/textures/test_blur_df",
			render_template = "VertexColorTexturedBlur3D",
			w = v:w(),
			h = v:h(),
			halign = "scale",
			valign = "scale",
			layer = -1,
			alpha = 1
		})
		v:rect({
			color = Color.black,
			alpha = 0.4,
			layer = -1
		})
	end
	WalletGuiObject.set_wallet(self._panel)
	if managers.menu:is_pc_controller() then
		self._legends_panel = self._panel:panel({
			name = "legends_panel",
			w = self._panel:w() * 0.75,
			h = tweak_data.menu.pd2_medium_font_size
		})

		self._legends_panel:set_right(self._panel:w())

		self._legends = {}

		local function new_legend(name, text_string, hud_icon)
			local panel = self._legends_panel:panel({
				visible = false,
				name = name
			})
			local text = panel:text({
				blend_mode = "add",
				text = text_string,
				font = small_font,
				font_size = small_font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text(text)

			local text_x = 0
			local center_y = text:center_y()

			if hud_icon then
				local texture, texture_rect = tweak_data.hud_icons:get_icon_data(hud_icon)
				local icon = panel:bitmap({
					name = "icon",
					h = 23,
					blend_mode = "add",
					w = 17,
					texture = texture,
					texture_rect = texture_rect
				})
				text_x = icon:right() + 2
				center_y = math.max(center_y, icon:center_y())

				icon:set_center_y(center_y)
			end

			text:set_left(text_x)
			text:set_center_y(center_y)
			panel:set_w(text:right())

			self._legends[name] = panel
		end

		new_legend("select", managers.localization:to_upper_text("menu_mouse_select"), "mouse_left_click")
		new_legend("switch", managers.localization:to_upper_text("menu_mouse_switch"), "mouse_scroll_wheel")
	end

	local index_x = node:parameters().data.crew_gui_index_x or 1
	local index_y = node:parameters().data.crew_gui_index_y or 1

	self:select_index(index_x, index_y)

	CriminalsManager.MAX_NR_TEAM_AI = Global.game_settings.max_bots or CriminalsManager.MAX_NR_TEAM_AI
end

local create_pages_original = CrewManagementGui.create_pages
function CrewManagementGui:create_pages(new_node_data, params, identifier, selected_slot, rows, columns, max_pages, selected_category)
	local correct_category = not new_node_data.category or not selected_category or new_node_data.category == selected_category
	local selected_tab = create_pages_original(self, new_node_data, params, identifier, selected_slot, rows, columns, max_pages, selected_category)
	return correct_category and selected_tab or 1
end

--[[ CHARACTER ]]
function CrewManagementGui:create_character_button(panel, index)
	local character = managers.blackmarket:preferred_henchmen(index)
	local texture = character and managers.blackmarket:get_character_icon(character) or "guis/textures/pd2/dice_icon"
	local text = character and managers.localization:text("menu_" .. character) or managers.localization:text("item_random")
	local cat_text = managers.localization:to_upper_text("menu_preferred_character")
	return CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1}, text, cat_text, callback(self, self, "open_character_menu", index), callback(self, self, "previous_character", index), callback(self, self, "next_character", index))
end

function CrewManagementGui:open_character_menu(henchman_index)
	local category = "characters"
	local new_node_data = {
		category = category
	}
	local selected_tab = self:create_pages(new_node_data, henchman_index, "custom", nil, 3, 6, 1)
	new_node_data.can_move_over_tabs = true
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = false
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		custom_select = callback(self, self, "select_character", henchman_index),
		custom_unselect = callback(self, self, "select_character", henchman_index)
	}

	function new_node_data.custom_update_text_info(data, updated_texts, gui)
		updated_texts[1].text = data.name_localized
		updated_texts[4].text = managers.localization:text(data.name .. "_desc")
		if not data.unlocked then
			updated_texts[3].text = managers.localization:text(data.dlc_locked)
		end
	end

	new_node_data.topic_id = "bm_menu_crew_characters"
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_" .. category) .. " " .. tostring(henchman_index)
	}

	managers.menu:open_node("blackmarket_node", { new_node_data })
end

function CrewManagementGui:populate_characters(henchman_index, data, gui)
	gui:populate_characters(data)

	for _, v in ipairs(data) do
		v.equipped = managers.blackmarket:preferred_henchmen(henchman_index) == v.name
		v.buttons = v.unlocked and { v.equipped and "custom_unselect" or "custom_select" } or {}
	end
end

function CrewManagementGui:select_character(index, data, gui)
	if data.equipped then
		managers.blackmarket:set_preferred_henchmen(index, nil)
	else
		managers.blackmarket:set_preferred_henchmen(index, data.name)
	end
	return gui and gui:reload()
end

function CrewManagementGui:previous_character(henchman_index)
	local character = managers.blackmarket:preferred_henchmen(henchman_index)
	local characters = CriminalsManager.character_names()
	local char_index = character and table.get_vector_index(characters, character)

	while char_index and char_index > 1 do
		char_index = char_index - 1
		character = characters[char_index]
		local char_name = CriminalsManager.convert_old_to_new_character_workname(character)
		local character_table = tweak_data.blackmarket.characters[char_name] or tweak_data.blackmarket.characters.locked[char_name]
		if not character_table or not character_table.dlc or managers.dlc:is_dlc_unlocked(character_table.dlc) then
			managers.blackmarket:set_preferred_henchmen(henchman_index, character)
			return self:reload()
		end
	end
end

function CrewManagementGui:next_character(henchman_index)
	local character = managers.blackmarket:preferred_henchmen(henchman_index)
	local characters = CriminalsManager.character_names()
	local char_index = character and table.get_vector_index(characters, character)

	while char_index and char_index < #characters do
		char_index = char_index + 1
		character = characters[char_index]
		local char_name = CriminalsManager.convert_old_to_new_character_workname(character)
		local character_table = tweak_data.blackmarket.characters[char_name] or tweak_data.blackmarket.characters.locked[char_name]
		if not character_table or not character_table.dlc or managers.dlc:is_dlc_unlocked(character_table.dlc) then
			managers.blackmarket:set_preferred_henchmen(henchman_index, character)
			return self:reload()
		end
	end
end

--[[ WEAPONS ]]
function CrewManagementGui:create_weapon_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local char_loadout = BotWeapons:get_char_loadout(managers.menu_scene._picked_character_position[index])
	local data = managers.blackmarket:get_crafted_category_slot(loadout.primary_category or "primaries", loadout.primary_slot) or {}
	local texture, rarity = managers.blackmarket:get_weapon_icon_path(data.weapon_id, data.cosmetics)
	local text = loadout.primary_slot and managers.blackmarket:get_weapon_name_by_category_slot(loadout.primary_category or "primaries", loadout.primary_slot) or loadout.primary_random and managers.localization:text("item_random") or ""
	local cat_text = managers.localization:to_upper_text("item_weapon")
	local weapon_text = loadout.primary_random and managers.localization:to_upper_text("item_random") or (char_loadout.primary or char_loadout.primary_random) and managers.localization:to_upper_text("menu_crew_character") or managers.localization:to_upper_text("menu_crew_defualt")
	if type(loadout.primary_random) == "string" then
		weapon_text = managers.localization:to_upper_text("menu_" .. loadout.primary_random)
	elseif loadout.primary_random then
		texture = "guis/textures/pd2/dice_icon"
	end
	local item = CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or weapon_text, text, cat_text, callback(self, self, "show_weapon_selection", index), callback(self, self, "previous_weapon_category", index), callback(self, self, "next_weapon_category", index))
	if rarity then
		local rare_item = item._panel:bitmap({
			blend_mode = "add",
			layer = 0,
			texture = rarity
		})
		fit_texture(rare_item, item._panel:size())
		rare_item:set_world_center(item._panel:world_center())
	end
	return item
end

function CrewManagementGui:open_weapon_category_menu(category, henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local new_node_data = {category = category}
	local selected_tab = self:create_pages(new_node_data, henchman_index, "weapon", loadout.primary_slot, tweak_data.gui.WEAPON_ROWS_PER_PAGE, tweak_data.gui.WEAPON_COLUMNS_PER_PAGE, tweak_data.gui.MAX_WEAPON_PAGES)
	new_node_data.can_move_over_tabs = true
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = true
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		w_equip = callback(self, self, "select_weapon", henchman_index),
		w_unequip = callback(self, self, "select_weapon", henchman_index)
	}
	new_node_data.topic_id = "bm_menu_" .. category
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_weapons")
	}
	managers.menu:open_node("blackmarket_node", {new_node_data})
end

function CrewManagementGui:populate_primaries(henchman_index, data, gui)
	gui:populate_weapon_category_new(data)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	for k, v in ipairs(data) do
		v.equipped = not v.locked_slot and not v.empty_slot and loadout.primary_slot == v.slot and loadout.primary_category == v.category
		v.comparision_data = nil
		if not v.empty_slot and not managers.blackmarket:is_weapon_allowed_for_crew(v.name) then
			v.buttons = {}
			v.unlocked = false
			v.lock_texture = "guis/textures/pd2/lock_incompatible"
			v.lock_text = managers.localization:text("menu_data_crew_not_allowed")
		else
			v.buttons = not v.empty_slot and {v.equipped and "w_unequip" or "w_equip", "w_mod", "w_preview", "w_sell"} or {v.locked_slot and "ew_unlock" or "ew_buy"}
		end
	end
end
CrewManagementGui.populate_secondaries = CrewManagementGui.populate_primaries

function CrewManagementGui:select_weapon(index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(index)
	if not data or data.equipped or data.random then
		loadout.primary = nil
		loadout.primary_slot = nil
		loadout.primary_category = nil
		loadout.primary_random = data and not data.equipped and data.random
	else
		local crafted = managers.blackmarket:get_crafted_category_slot(data.category, data.slot)
		loadout.primary = crafted.factory_id .. "_npc"
		loadout.primary_slot = data.slot
		loadout.primary_category = data.category
		loadout.primary_random = nil
	end
	return gui and gui:reload()
end

function CrewManagementGui:show_weapon_selection(henchman_index)
	local menu_title = managers.localization:text("menu_action_select_name")
	local menu_message = managers.localization:text("menu_action_select_desc")
	local menu_options = {
		{
			text = managers.localization:text("menu_action_inventory_primaries_name"),
			callback = function () self:open_weapon_category_menu("primaries", henchman_index) end
		},
		{
			text = managers.localization:text("menu_action_inventory_secondaries_name"),
			callback = function () self:open_weapon_category_menu("secondaries", henchman_index) end
		},
		{
			text = managers.localization:text("menu_action_random_weapon_name"),
			callback = function()
				local menu_title = managers.localization:text("menu_category_select_name")
				local menu_message = managers.localization:text("menu_category_select_desc")
				local menu_options = {
					{
						text = managers.localization:text("item_random"),
						callback = function ()
							self:select_weapon(henchman_index, { random = true })
							self:reload()
						end
					},
					{--[[seperator]]},
					{
						text = managers.localization:text("menu_back"),
						callback = function () self:show_weapon_selection(henchman_index) end,
						is_cancel_button = true
					}
				}
				for i, v in ipairs(BotWeapons.weapon_categories) do
					table.insert(menu_options, #menu_options - 2, {
						text = managers.localization:text("menu_" .. v),
						callback = function ()
							self:select_weapon(henchman_index, { random = v })
							self:reload()
						end
					})
				end
				QuickMenu:new(menu_title, menu_message, menu_options, true)
			end
		},
		{--[[seperator]]},
		{
			text = managers.localization:text("menu_back"),
			is_cancel_button = true
		}
	}
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if loadout.primary or loadout.primary_random then
		table.insert(menu_options, #menu_options, {
			text = managers.localization:text("bm_menu_btn_unequip_weapon"),
			callback = function ()
				self:select_weapon(henchman_index)
				self:reload()
			end
		})
		table.insert(menu_options, #menu_options, {--[[seperator]]})
	end
	QuickMenu:new(menu_title, menu_message, menu_options, true)
end

--[[ MASKS ]]
function CrewManagementGui:create_mask_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local char_loadout = BotWeapons:get_char_loadout(managers.menu_scene._picked_character_position[index])
	local texture = loadout.mask ~= "character_locked" and managers.blackmarket:get_mask_icon(loadout.mask)
	local text = loadout.mask ~= "character_locked" and managers.blackmarket:get_mask_name_by_category_slot("masks", loadout.mask_slot) or loadout.mask_random and managers.localization:text("item_random") or ""
	local cat_text = managers.localization:to_upper_text("bm_menu_masks")
	local mask_text = loadout.mask_random and managers.localization:to_upper_text("item_random") or (char_loadout.mask or char_loadout.mask_random) and managers.localization:to_upper_text("menu_crew_character") or managers.localization:to_upper_text("menu_crew_defualt")
	if type(loadout.mask_random) == "string" then
		mask_text = managers.localization:to_upper_text("item_" .. loadout.mask_random)
	elseif loadout.mask_random then
		texture = "guis/textures/pd2/dice_icon"
	end
	return CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or mask_text, text, cat_text, callback(self, self, "show_mask_selection", index), callback(self, self, "previous_mask", index), callback(self, self, "next_mask", index))
end

function CrewManagementGui:select_mask(index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(index)
	if not data or data.random then
		loadout.mask = "character_locked"
		loadout.mask_slot = 1
		loadout.mask_random = data and data.random
	else
		loadout.mask = data.name
		loadout.mask_slot = data.slot
		loadout.mask_random = nil
	end
	return gui and gui:reload()
end

function CrewManagementGui:show_mask_selection(henchman_index)
	local menu_title = managers.localization:text("menu_action_select_name")
	local menu_message = managers.localization:text("menu_action_select_desc")
	local menu_options = {
		{
			text = managers.localization:text("menu_action_inventory_masks_name"),
			callback = function () self:open_mask_category_menu(henchman_index) end
		},
		{
			text = managers.localization:text("menu_action_mask_set_name"),
			callback = function()
				local menu_title = managers.localization:text("menu_mask_set_select_name")
				local menu_message = managers.localization:text("menu_mask_set_select_desc")
				local menu_options = {
					{--[[seperator]]},
					{
						text = managers.localization:text("menu_back"),
						callback = function () self:show_mask_selection(henchman_index) end,
						is_cancel_button = true
					}
				}
				for k, v in pairs(BotWeapons.masks) do
					table.insert(menu_options, #menu_options - 1, {
						text = managers.localization:text("item_" .. k),
						callback = function ()
							self:select_mask(henchman_index, { random = k })
							self:reload()
						end
					})
				end
				QuickMenu:new(menu_title, menu_message, menu_options, true)
			end
		},
		{
			text = managers.localization:text("menu_action_random_mask_name"),
			callback = function ()
				self:select_mask(henchman_index, { random = true })
				self:reload()
			end
		},
		{--[[seperator]]},
		{
			text = managers.localization:text("menu_back"),
			is_cancel_button = true
		}
	}
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if loadout.mask ~= "character_locked" or loadout.mask_random then
		table.insert(menu_options, #menu_options, {
			text = managers.localization:text("menu_action_unequip_mask"),
			callback = function ()
				self:select_mask(henchman_index)
				self:reload()
			end
		})
		table.insert(menu_options, #menu_options, {--[[seperator]]})
	end
	QuickMenu:new(menu_title, menu_message, menu_options, true)
end

local function pad_data(data, amount)
	if data[#data].name == "empty" and data[#data - 1].name == "empty" then
		table.remove(data, #data)
		table.remove(data, #data)
	else
		for i = 1, amount - (#data % amount), 1 do
			table.insert(data, {
				name = "empty",
				name_localized = "",
				category = data.category,
				unlocked = true,
				equipped = false
			})
		end
	end
end

--[[ DEPLOYABLES ]]
function CrewManagementGui:create_deployable_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local char_loadout = BotWeapons:get_char_loadout(managers.menu_scene._picked_character_position[index])
	local texture = loadout.deployable and managers.blackmarket:get_deployable_icon(loadout.deployable) or loadout.deployable_random and "guis/textures/pd2/dice_icon"
	local text = loadout.deployable and managers.localization:to_upper_text(tweak_data.upgrades.definitions[loadout.deployable].name_id) or loadout.deployable_random and managers.localization:text("item_random") or ""
	local cat_text = managers.localization:to_upper_text("bm_menu_deployables")
	local deployable_text = loadout.deployable_random and managers.localization:to_upper_text("item_random") or (char_loadout.deployable or char_loadout.deployable_random) and managers.localization:to_upper_text("menu_crew_character") or managers.localization:to_upper_text("menu_crew_defualt")
	return CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or deployable_text, text, cat_text, callback(self, self, "open_deployables_category_menu", index), callback(self, self, "previous_deployable", index), callback(self, self, "next_deployable", index))
end

function CrewManagementGui:open_deployables_category_menu(henchman_index)
	local new_node_data = {
		category = "deployables"
	}
	self:create_pages(new_node_data, henchman_index, "custom", nil, 3, 3, 1)
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		lo_d_equip = callback(self, self, "select_deployable", henchman_index),
		lo_d_unequip = callback(self, self, "select_deployable", henchman_index)
	}
	new_node_data.topic_id = "bm_menu_deployables"
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_deployables")
	}
	function new_node_data.custom_update_text_info(data, updated_texts, gui)
		updated_texts[1].text = data.name_localized
		updated_texts[4].text = (data.random or data.default) and "" or managers.localization:text(tweak_data.blackmarket.deployables[data.name].desc_id, {
			BTN_INTERACT = managers.localization:btn_macro("interact", true),
			BTN_USE_ITEM = managers.localization:btn_macro("use_item", true)
		})
	end
	managers.menu:open_node("blackmarket_node", {new_node_data})
end

function CrewManagementGui:populate_deployables(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not self._deployables_data then
		gui:populate_deployables(data)

		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("item_random"),
			name = "ammo_bag",
			name_localized = managers.localization:text("item_random_deployable"),
			random = true
		})
		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("menu_crew_character"),
			name = "ammo_bag",
			name_localized = managers.localization:text("item_default_deployable"),
			default = true
		})
		pad_data(data, data.override_slots[2])

		self._deployables_data = true
	end

	for i, v in ipairs(data) do
		v.slot = i
		v.equipped = i == 1 and not loadout.deployable and not loadout.deployable_random or i == 2 and loadout.deployable_random or i > 2 and loadout.deployable == v.name
		v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
		v.unlocked = true
		v.lock_texture = nil
		v.lock_text = nil
		v.comparision_data = nil
		v.buttons = not v.empty_slot and {v.equipped and "lo_d_unequip" or "lo_d_equip"}
	end
end

function CrewManagementGui:select_deployable(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not data or data.default or data.random or data.equipped then
		loadout.deployable = nil
		loadout.deployable_random = data and not data.equipped and data.random
	else
		loadout.deployable = data.name
		loadout.deployable_random = nil
	end
	return gui and gui:reload()
end

function CrewManagementGui:previous_deployable(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local deployable = loadout.deployable
	local deployables = table.map_keys(tweak_data.blackmarket.deployables)
	local deployable_index = deployable and table.get_vector_index(deployables, deployable)

	if deployable_index and deployables[deployable_index - 1] then
		loadout.deployable = deployables[deployable_index - 1]
		return self:reload()
	end
end

function CrewManagementGui:next_deployable(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local deployable = loadout.deployable
	local deployables = table.map_keys(tweak_data.blackmarket.deployables)
	local deployable_index = deployable and table.get_vector_index(deployables, deployable)

	if deployable_index and deployables[deployable_index + 1] then
		loadout.deployable = deployables[deployable_index + 1]
		return self:reload()
	end
end

--[[ ARMOR ]]
function CrewManagementGui:create_armor_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local char_loadout = BotWeapons:get_char_loadout(managers.menu_scene._picked_character_position[index])
	local player_style = loadout.player_style and loadout.player_style ~= "none" and loadout.player_style
	local texture = player_style and managers.blackmarket:get_player_style_icon(player_style) or loadout.armor and managers.blackmarket:get_armor_icon(loadout.armor) or (loadout.player_style_random or loadout.armor_random) and "guis/textures/pd2/dice_icon"
	local text = player_style and managers.localization:text(tweak_data.blackmarket.player_styles[player_style].name_id) or loadout.armor and managers.localization:text(tweak_data.blackmarket.armors[loadout.armor].name_id) or (loadout.player_style_random or loadout.armor_random) and managers.localization:text("item_random") or ""
	local cat_text = managers.localization:to_upper_text("bm_menu_player_styles")
	local armor_text = (char_loadout.armor or char_loadout.armor_random or char_loadout.player_style or char_loadout.player_style_random) and managers.localization:to_upper_text("menu_crew_character") or managers.localization:to_upper_text("menu_crew_defualt")
	return CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or armor_text, text, cat_text, callback(self, self, "open_armor_category_menu", index), callback(self, self, "previous_armor", index), callback(self, self, "next_armor", index))
end

function CrewManagementGui:open_armor_category_menu(henchman_index)
	local new_node_data = {}
	local override_slots = { 3, 3 }
	table.insert(new_node_data, {
		name = "bm_menu_armors",
		on_create_func = callback(self, self, "populate_armors", henchman_index),
		category = "armors",
		override_slots = override_slots,
		identifier = BlackMarketGui.identifiers.armor
	})
	table.insert(new_node_data, {
		name = "bm_menu_player_styles",
		on_create_func = callback(self, self, "populate_player_styles", henchman_index),
		category = "suits",
		override_slots = override_slots,
		identifier = BlackMarketGui.identifiers.custom
	})
	table.insert(new_node_data, {
		name = "bm_menu_gloves",
		on_create_func = callback(self, self, "populate_gloves_bwe", henchman_index),
		category = "gloves",
		override_slots = override_slots,
		identifier = BlackMarketGui.identifiers.custom
	})
	function new_node_data.custom_update_text_info(data, updated_texts, gui)
		local bm_tweak = tweak_data.blackmarket
		local tweak = bm_tweak[data.category == "gloves" and "gloves" or "player_styles"][data.name]
		if not data.unlocked then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
			updated_texts[2].resource_color = tweak_data.screen_colors.important_1
			updated_texts[3].text = data.dlc_locked and managers.localization:to_upper_text(data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
		end
		updated_texts[1].text = data.name_localized
		updated_texts[4].text = (data.random or data.default) and "" or managers.localization:text(tweak.desc_id)
	end

	new_node_data.topic_id = "bm_menu_outfits"
	new_node_data.skip_blur = true
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		a_equip = callback(self, self, "select_armor", henchman_index),
		a_mod = callback(self, self, "open_armor_skins_menu", henchman_index),
		trd_equip = callback(self, self, "select_player_style", henchman_index),
		trd_customize = callback(self, self, "customize_player_style", henchman_index),
		hnd_equip = callback(self, self, "select_glove", henchman_index)
	}

	if BEARDLIB_GLOVEVARS_INSTALLED then
		new_node_data.custom_callback.hnd_customize = callback(self, self, "open_glove_customize_menu_bwe", henchman_index)
	end

	managers.menu_scene:remove_item()
	managers.menu:open_node("blackmarket_node", { new_node_data })
end

function CrewManagementGui:customize_player_style(henchman_index, data)
		local new_node_data = {}

		table.insert(new_node_data, {
			name = "bm_menu_suit_variations",
			on_create_func = callback(self, self, "populate_suit_variations", henchman_index),
			category = "suit_variations",
			override_slots = { 3, 3 },
			identifier = BlackMarketGui.identifiers.custom,
			prev_node_data = data
		})
		function new_node_data.custom_update_text_info(data, updated_texts, gui)
			local player_style = gui._data.prev_node_data.name
			local player_style_tweak = tweak_data.blackmarket.player_styles[player_style]
			local suit_variation = data.name
			local suit_variation_tweak = player_style_tweak.material_variations[suit_variation]
			updated_texts[1].text = data.name_localized
			if not data.unlocked then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
				updated_texts[2].resource_color = tweak_data.screen_colors.important_1
				updated_texts[3].text = data.dlc_locked and managers.localization:to_upper_text(data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
			end
			updated_texts[4].text = (data.random or data.default) and "" or managers.localization:text(suit_variation_tweak and suit_variation_tweak.desc_id or "menu_default")
		end

		new_node_data.topic_id = "bm_menu_suit_variations"
		new_node_data.skip_blur = true
		new_node_data.hide_detection_panel = true
		new_node_data.prev_node_data = data
		new_node_data.custom_callback = {
			trd_mod_equip = callback(self, self, "select_suit_variation", henchman_index)
		}
		self._prev_node_data = data
		managers.menu:open_node("blackmarket_node", { new_node_data })
end

function CrewManagementGui:populate_armors(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not self._armors_data then
		gui:populate_armors(data)

		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("item_random"),
			bitmap_texture = "guis/textures/empty",
			name = "level_1",
			name_localized = managers.localization:text("item_random_armor"),
			random = true
		})
		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("menu_crew_character"),
			bitmap_texture = "guis/textures/empty",
			name = "level_1",
			name_localized = managers.localization:text("item_default_armor"),
			default = true
		})
		pad_data(data, data.override_slots[2])

		self._armors_data = true
	end

	for i, v in ipairs(data) do
		v.slot = i
		v.equipped = i == 1 and not loadout.armor and not loadout.armor_random or i == 2 and loadout.armor_random or i > 2 and loadout.armor == v.name
		v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
		v.unlocked = true
		v.lock_texture = nil
		v.lock_text = nil
		v.comparision_data = nil
		v.buttons = {"a_mod"}
		if not v.empty_slot and not v.equipped then
			table.insert(v.buttons, 1, "a_equip")
		end
	end
end

function CrewManagementGui:populate_player_styles(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not self._outfit_data then
		gui:populate_player_styles(data)

		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("item_random"),
			bitmap_texture = "guis/textures/empty",
			name = managers.blackmarket:get_default_player_style(),
			name_localized = managers.localization:text("item_random_outfit"),
			unlocked = true,
			random = true
		})
		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("menu_crew_character"),
			bitmap_texture = "guis/textures/empty",
			name = managers.blackmarket:get_default_player_style(),
			name_localized = managers.localization:text("item_default_outfit"),
			unlocked = true,
			default = true
		})
		pad_data(data, data.override_slots[2])

		self._outfit_data = true
	end

	for i, v in ipairs(data) do
		v.slot = i
		v.equipped = i == 1 and not loadout.player_style and not loadout.player_style_random or i == 2 and loadout.player_style_random or i > 2 and loadout.player_style == v.name
		v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
		v.comparision_data = nil
		v.buttons = { v.unlocked and (v.equipped and tweak_data.blackmarket:have_suit_variations(v.name) and "trd_customize" or not v.empty_slot and not v.equipped and "trd_equip") }
	end
end

function CrewManagementGui:populate_suit_variations(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)

	gui:populate_suit_variations(data)

	table.insert(data, 1, {
		category = data.category,
		button_text = managers.localization:to_upper_text("item_random"),
		bitmap_texture = "guis/textures/empty",
		name = "default",
		name_localized = managers.localization:text("item_random_variation"),
		random = true
	})
	table.insert(data, 1, {
		category = data.category,
		button_text = managers.localization:to_upper_text("menu_crew_character"),
		bitmap_texture = "guis/textures/empty",
		name = "default",
		name_localized = managers.localization:text("item_default_variation"),
		default = true
	})
	pad_data(data, data.override_slots[2])

	for i, v in ipairs(data) do
		v.slot = i
		v.equipped = i == 1 and not loadout.suit_variation and not loadout.suit_variation_random or i == 2 and loadout.suit_variation_random or i > 2 and loadout.suit_variation == v.name
		v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
		v.unlocked = true
		v.lock_texture = nil
		v.lock_text = nil
		v.comparision_data = nil
		v.buttons = {}
		if not v.empty_slot and not v.equipped then
			table.insert(v.buttons, 1, "trd_mod_equip")
		end
	end
end

function CrewManagementGui:populate_gloves_bwe(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	-- For the beardlib variant icon stuff to work we have to reload every time even if it might not be super efficient.
	if BEARDLIB_GLOVEVARS_INSTALLED or not self._gloves_data then
		if BEARDLIB_GLOVEVARS_INSTALLED then
			data.henchman_index = henchman_index
		end

		gui:populate_gloves(data)

		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("item_random"),
			bitmap_texture = "guis/textures/empty",
			name = managers.blackmarket:get_default_glove_id(),
			name_localized = managers.localization:text("item_random_gloves"),
			unlocked = true,
			random = true
		})
		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("menu_crew_character"),
			bitmap_texture = "guis/textures/empty",
			name = managers.blackmarket:get_default_glove_id(),
			name_localized = managers.localization:text("item_default_gloves"),
			unlocked = true,
			default = true
		})
		pad_data(data, data.override_slots[2])

		self._gloves_data = true
	end

	for i, v in ipairs(data) do
		v.slot = i
		v.equipped = i == 1 and not loadout.glove_id and not loadout.glove_id_random or i == 2 and loadout.glove_id_random or i > 2 and loadout.glove_id == v.name
		v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
		v.comparision_data = nil
		v.buttons = { v.unlocked and not v.empty_slot and not v.equipped and "hnd_equip" }

		if BEARDLIB_GLOVEVARS_INSTALLED and v.equipped then
			if tweak_data.blackmarket:have_glove_variations(v.name) then
				table.insert(v.buttons, "hnd_customize")
			end
		end
	end
end

if BEARDLIB_GLOVEVARS_INSTALLED then
	function CrewManagementGui:open_glove_customize_menu_bwe(henchman_index, data)
		local new_node_data = {}

		table.insert(new_node_data, {
			name = "bm_menu_glove_variations",
			on_create_func = callback(self, self, "populate_glove_variations", henchman_index),
			category = "glove_variations",
			override_slots = { 3, 3 },
			identifier = BlackMarketGui.identifiers.custom,
			prev_node_data = data
		})

		function new_node_data.custom_update_text_info(data, updated_texts, gui)
			local glove_id = gui._data.prev_node_data.name
			local glove_tweak = tweak_data.blackmarket.gloves[glove_id]
			local glove_variation = data.name
			local glove_variation_tweak = glove_tweak.variations[glove_variation]
			updated_texts[1].text = data.name_localized
			if not data.unlocked then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
				updated_texts[2].resource_color = tweak_data.screen_colors.important_1
				updated_texts[3].text = data.dlc_locked and managers.localization:to_upper_text(data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
			end
			updated_texts[4].text = (data.random or data.default) and "" or managers.localization:text(glove_variation_tweak and glove_variation_tweak.desc_id or "menu_default")
		end

		new_node_data.topic_id = "bm_menu_glove_variations"
		new_node_data.skip_blur = true
		new_node_data.hide_detection_panel = true
		new_node_data.prev_node_data = data
		new_node_data.custom_callback = {
			hnd_mod_equip = callback(self, self, "select_glove_variation", henchman_index)
		}

		self._prev_node_data = data
		managers.menu:open_node("blackmarket_node", { new_node_data })
	end
end

function CrewManagementGui:previous_armor(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if loadout.player_style and loadout.player_style ~= "none" then
		return self:previous_suit(henchman_index)
	end
	local armor = loadout.armor
	local armors = table.map_keys(tweak_data.blackmarket.armors)
	local armor_index = armor and table.get_vector_index(armors, armor)

	if armor_index and armors[armor_index - 1] then
		loadout.armor = armors[armor_index - 1]
		return self:reload()
	end
end

function CrewManagementGui:next_armor(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if loadout.player_style and loadout.player_style ~= "none" then
		return self:next_suit(henchman_index)
	end
	local armor = loadout.armor
	local armors = table.map_keys(tweak_data.blackmarket.armors)
	local armor_index = armor and table.get_vector_index(armors, armor)

	if armor_index and armors[armor_index + 1] then
		loadout.armor = armors[armor_index + 1]
		return self:reload()
	end
end

function CrewManagementGui:select_armor(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not data or data.default or data.random then
		loadout.armor = nil
		loadout.armor_random = data and data.random
	else
		loadout.armor = data.name
		loadout.armor_random = nil
	end
	return gui and gui:reload()
end

function CrewManagementGui:select_player_style(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not data or data.default or data.random then
		loadout.player_style = nil
		loadout.player_style_random = data and data.random
	else
		loadout.player_style = data.name
		loadout.player_style_random = nil
	end
	loadout.suit_variation_random = nil
	loadout.suit_variation = nil
	return gui and gui:reload()
end

function CrewManagementGui:select_suit_variation(henchman_index, data, gui)
	self:select_player_style(henchman_index, self._prev_node_data)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not data or data.default or data.random then
		loadout.suit_variation = nil
		loadout.suit_variation_random = data and data.random
	else
		loadout.suit_variation = data.name
		loadout.suit_variation_random = nil
	end
	return gui and gui:reload()
end

function CrewManagementGui:select_glove(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not data or data.default or data.random then
		loadout.glove_id = nil
		loadout.glove_id_random = data and data.random
	else
		loadout.glove_id = data.name
		loadout.glove_id_random = nil
	end
	return gui and gui:reload()
end

function CrewManagementGui:open_armor_skins_menu(henchman_index)
	local new_node_data = {}

	table.insert(new_node_data, {
		name = "bm_menu_armor_skins",
		on_create_func = callback(self, self, "populate_armor_skins", henchman_index),
		category = "armor_skins",
		override_slots = { 3, 3 },
		identifier = BlackMarketGui.identifiers.armor_skins
	})

	new_node_data.topic_id = "bm_menu_armor_skins"
	new_node_data.skip_blur = true
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		as_equip = callback(self, self, "select_armor_skin", henchman_index)
	}

	managers.menu:open_node("blackmarket_node", { new_node_data })
end

function CrewManagementGui:populate_armor_skins(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not self._armor_skins_data then
		gui:populate_armor_skins(data)

		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("item_random"),
			name = "none",
			name_localized = managers.localization:text("item_random_armor_skin"),
			unlocked = true,
			cosmetic_unlocked = true,
			random = true
		})
		table.insert(data, 1, {
			category = data.category,
			button_text = managers.localization:to_upper_text("menu_crew_character"),
			name = "none",
			name_localized = managers.localization:text("item_default_armor_skin"),
			unlocked = true,
			cosmetic_unlocked = true,
			default = true
		})
		pad_data(data, data.override_slots[2])

		self._armor_skins_data = true
	end

	for i, v in ipairs(data) do
		v.slot = i
		v.equipped = i == 1 and not loadout.armor_skin and not loadout.armor_skin_random or i == 2 and loadout.armor_skin_random == true or i > 2 and loadout.armor_skin == v.name
		v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
		v.comparision_data = nil
		if not v.equipped and v.cosmetic_unlocked then
			v.buttons = {"as_equip"}
		else
			v.buttons = {}
		end
	end
end

function CrewManagementGui:select_armor_skin(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	if not data or data.default or data.random then
		loadout.armor_skin = nil
		loadout.armor_skin_random = data and data.random
	else
		loadout.armor_skin = data.name
		loadout.armor_skin_random = nil
	end
	return gui and gui:reload()
end

function CrewManagementGui:show_character_specific_settings()
	local menu_title = managers.localization:text("menu_character_settings_name")
	local menu_message = managers.localization:text("menu_character_settings_desc")
	local menu_options = {
		{
			text = managers.localization:text("menu_action_set_character_loadout"),
			callback = function ()
				for i = 1, 3 do
					local character = managers.menu_scene._picked_character_position[i]
					BotWeapons:set_character_loadout(character, BotWeapons:get_loadout(character, managers.blackmarket:henchman_loadout(i), true))
					self:select_armor(i, nil)
					self:select_armor_skin(i, nil)
					self:select_deployable(i, nil)
					self:select_mask(i, nil)
					self:select_weapon(i, nil)
				end
				BotWeapons:save()
				self:reload()
			end
		},
		{
			text = managers.localization:text("menu_action_clear_character_loadout"),
			callback = function ()
				for i = 1, 3 do
					BotWeapons:set_character_loadout(managers.menu_scene._picked_character_position[i], nil)
				end
				BotWeapons:save()
				self:reload()
			end
		},
		{
			text = managers.localization:text("menu_action_clear_all_character_loadout"),
			callback = function ()
				for _, char_name in ipairs(CriminalsManager.character_names()) do
					BotWeapons:set_character_loadout(char_name, nil)
				end
				BotWeapons:save()
				self:reload()
			end
		},
		{--[[seperator]]},
		{
			text = managers.localization:text("menu_back"),
			is_cancel_button = true
		}
	}
	QuickMenu:new(menu_title, menu_message, menu_options, true)
end

-- custom reload since it doesnt have one
function CrewManagementGui:reload()
	managers.menu_component:close_crew_management_gui()
	managers.menu_component:create_crew_management_gui(self._node)
end
