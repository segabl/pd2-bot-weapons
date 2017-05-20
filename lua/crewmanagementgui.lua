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

function CrewManagementGui:create_weapon_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local data = managers.blackmarket:get_crafted_category_slot(loadout.primary_category or "primaries", loadout.primary_slot) or {}
	local texture, rarity = managers.blackmarket:get_weapon_icon_path(data.weapon_id, data.cosmetics)
	local text = loadout.primary_slot and managers.blackmarket:get_weapon_name_by_category_slot(loadout.primary_category or "primaries", loadout.primary_slot) or ""
	local cat_text = managers.localization:to_upper_text("bm_menu_primaries")
	local item = CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or managers.localization:to_upper_text("menu_crew_defualt"), text, cat_text, callback(self, self, "show_category_selection", index))
	if rarity then
		local rare_item = item._panel:bitmap({
			texture = rarity,
			blend_mode = "add",
			layer = 0
		})
		fit_texture(rare_item, item._panel:size())
		rare_item:set_world_center(item._panel:world_center())
	end
	return item
end

function CrewManagementGui:open_weapon_category_menu(category, henchmen_index)
  local loadout = managers.blackmarket:henchman_loadout(henchmen_index)
	local new_node_data = {category = category}
	local selected_tab = self:create_pages(new_node_data, henchmen_index, "weapon", loadout.primary_slot, tweak_data.gui.WEAPON_ROWS_PER_PAGE, tweak_data.gui.WEAPON_COLUMNS_PER_PAGE, tweak_data.gui.MAX_WEAPON_PAGES, loadout.primary_category or "primaries")
	new_node_data.can_move_over_tabs = true
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = true
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		w_equip = callback(self, self, "select_weapon", henchmen_index),
		w_unequip = callback(self, self, "select_weapon", henchmen_index),
		ew_buy = callback(self, self, "buy_new_weapon")
	}
	new_node_data.topic_id = "bm_menu_" .. category
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_weapons")
	}
	managers.menu:open_node("blackmarket_node", {new_node_data})
end

function CrewManagementGui:create_pages(new_node_data, params, identifier, selected_slot, rows, columns, max_pages, selected_category)
	local category = new_node_data.category
	rows = rows or 3
	columns = columns or 3
	max_pages = max_pages or 8
	local items_per_page = rows * columns
	local item_data
	local selected_tab = 1
	for page = 1, max_pages do
		local index = 1
		local start_i = 1 + items_per_page * (page - 1)
		item_data = {}
		for i = start_i, items_per_page * page do
			item_data[index] = i
			index = index + 1
			if i == selected_slot and (category == selected_category or selected_category == nil) then
				selected_tab = page
			end
		end
		local name_id = managers.localization:to_upper_text("bm_menu_page", {
			page = tostring(page)
		})
		table.insert(new_node_data, {
			name = category,
			category = category,
			prev_node_data = false,
			start_i = start_i,
			allow_preview = true,
			name_localized = name_id,
			on_create_func = callback(self, self, "populate_" .. category, params),
			on_create_data = item_data,
			identifier = BlackMarketGui.identifiers[identifier],
			override_slots = {columns, rows}
		})
	end
	return selected_tab
end

function CrewManagementGui:populate_primaries(henchmen_index, data, gui)
	gui:populate_weapon_category_new(data)
	local loadout = managers.blackmarket:henchman_loadout(henchmen_index)
	for k, v in ipairs(data) do
		local tweak = tweak_data.weapon[v.name]
		v.equipped = loadout.primary_slot == v.slot and loadout.primary_category == v.category
		if tweak and not managers.blackmarket:is_weapon_category_allowed_for_crew(tweak.categories[1]) then
			v.buttons = {}
			v.unlocked = false
			v.lock_texture = "guis/textures/pd2/lock_incompatible"
			v.lock_text = managers.localization:text("menu_data_crew_not_allowed")
		elseif v.equipped then
			v.buttons = {"w_unequip"}
		elseif not v.empty_slot then
			v.buttons = {"w_equip"}
		end
		v.comparision_data = nil
		v.mini_icons = nil
	end
end

CrewManagementGui.populate_secondaries = CrewManagementGui.populate_primaries

function CrewManagementGui:select_weapon(index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(index)
	if not data or data.equipped then
		loadout.primary = nil
		loadout.primary_slot = nil
    loadout.primary_category = nil
	else
		local crafted = managers.blackmarket:get_crafted_category_slot(data.category, data.slot)
		loadout.primary = crafted.factory_id .. "_npc"
		loadout.primary_slot = data.slot
    loadout.primary_category = data.category
	end
  if gui then
    gui:reload()
  end
end

function CrewManagementGui:show_category_selection(henchmen_index)
  local menu_title = managers.localization:text("BotWeapons_menu_category_select_name")
  local menu_message = managers.localization:text("BotWeapons_menu_category_select_desc")
  local menu_options = {
    [1] = {
        text = managers.localization:text("bm_menu_primaries"),
        callback = function ()
          self:open_weapon_category_menu("primaries", henchmen_index)
        end,
    },
    [2] = {
        text = managers.localization:text("bm_menu_secondaries"),
        callback = function ()
          self:open_weapon_category_menu("secondaries", henchmen_index)
        end,
    },
    [3] = {
        text = managers.localization:text("menu_back"),
        is_cancel_button = true,
    }
  }
  --[[
  if managers.blackmarket:henchman_loadout(henchmen_index).primary then
    table.insert(menu_options, 3, {
        text = managers.localization:text("bm_menu_btn_unequip_weapon"),
        callback = function ()
          self:select_weapon(henchmen_index)
          managers.menu_scene:set_henchmen_loadout(henchmen_index)
        end})
  end
  ]]
  QuickMenu:new(menu_title, menu_message, menu_options):Show()
end