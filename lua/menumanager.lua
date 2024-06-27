Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BotWeapons", function(loc)
	local language
	for _, mod in pairs(BLT and BLT.Mods:Mods() or {}) do
		if mod:GetName() == "PAYDAY 2 THAI LANGUAGE Mod" and mod:IsEnabled() then
			language = "thai"
			break
		end
	end
	if language then
		loc:load_localization_file(BotWeapons.mod_path .. "loc/" .. language ..".txt")
	else
		for _, filename in pairs(file.GetFiles(BotWeapons.mod_path .. "loc/") or {}) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str):key() == SystemInfo:language():key() then
				language = str
				loc:load_localization_file(BotWeapons.mod_path .. "loc/" .. filename)
				break
			end
		end
	end
	loc:load_localization_file(BotWeapons.mod_path .. "loc/english.txt", false)

	if BotWeapons.settings.chatter then
		local filename = BotWeapons.mod_path .. "data/quotes_english.json"
		if io.file_is_readable(SavePath .. "bot_weapons_quotes.json") then
			filename = SavePath .. "bot_weapons_quotes.json"
		elseif language and io.file_is_readable(BotWeapons.mod_path .. "data/quotes_" .. language .. ".json") then
			filename = BotWeapons.mod_path .. "data/quotes_" .. language .. ".json"
		end
		local file = io.file_is_readable(filename) and io.open(filename, "r")
		if file then
			BotWeapons.chatter_quotes = json.decode(file:read("*all"))
			file:close()
			Hooks:Add("MenuComponentManagerUpdate", "MenuComponentManagerUpdate", function (self, t)
				BotWeapons:update_chatter(t)
			end)
		end
	end
end)

local menu_id_main = "BotWeapons_menu_main"

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_BotWeapons", function(menu_manager, nodes)
	MenuHelper:NewMenu(menu_id_main)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_BotWeapons", function(menu_manager, nodes)

	MenuCallbackHandler.BotWeapons_select = function(self, item)
		BotWeapons.settings[item:name()] = item:value()
		BotWeapons:save()
	end

	MenuCallbackHandler.BotWeapons_toggle = function(self, item)
		BotWeapons.settings[item:name()] = (item:value() == "on");
		BotWeapons:save()
	end

	MenuHelper:AddToggle({
		id = "weapon_balance",
		title = "toggle_weapon_balance_name",
		desc = "toggle_weapon_balance_desc",
		callback = "BotWeapons_toggle",
		value = BotWeapons.settings.weapon_balance,
		menu_id = menu_id_main,
		priority = 100
	})

	MenuHelper:AddDivider({
		id = "divider0",
		size = 16,
		menu_id = menu_id_main,
		priority = 99
	})

	MenuHelper:AddToggle({
		id = "player_carry",
		title = "toggle_player_carry_name",
		desc = "toggle_player_carry_desc",
		callback = "BotWeapons_toggle",
		value = BotWeapons.settings.player_carry,
		menu_id = menu_id_main,
		priority = 98
	})

	MenuHelper:AddDivider({
		id = "divider1",
		size = 16,
		menu_id = menu_id_main,
		priority = 97
	})

	MenuHelper:AddToggle({
		id = "use_flashlights",
		title = "toggle_use_flashlights_name",
		desc = "toggle_use_flashlights_desc",
		callback = "BotWeapons_toggle",
		value = BotWeapons.settings.use_flashlights,
		menu_id = menu_id_main,
		priority = 96
	})

	MenuHelper:AddToggle({
		id = "use_lasers",
		title = "toggle_use_lasers_name",
		desc = "toggle_use_lasers_desc",
		callback = "BotWeapons_toggle",
		value = BotWeapons.settings.use_lasers,
		menu_id = menu_id_main,
		priority = 95
	})

	MenuHelper:AddDivider({
		id = "divider2",
		size = 16,
		menu_id = menu_id_main,
		priority = 94
	})

	MenuHelper:AddSlider({
		id = "mask_customized_chance",
		title = "slider_mask_customized_chance_name",
		desc = "slider_mask_customized_chance_desc",
		callback = "BotWeapons_select",
		value = BotWeapons.settings.mask_customized_chance,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		is_percentage = true,
		display_scale = 100,
		display_precision = 0,
		menu_id = menu_id_main,
		priority = 93
	})

	MenuHelper:AddSlider({
		id = "weapon_customized_chance",
		title = "slider_weapon_customized_chance_name",
		desc = "slider_weapon_customized_chance_desc",
		callback = "BotWeapons_select",
		value = BotWeapons.settings.weapon_customized_chance,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		is_percentage = true,
		display_scale = 100,
		display_precision = 0,
		menu_id = menu_id_main,
		priority = 92
	})

	MenuHelper:AddSlider({
		id = "weapon_cosmetics_chance",
		title = "slider_weapon_cosmetics_chance_name",
		desc = "slider_weapon_cosmetics_chance_desc",
		callback = "BotWeapons_select",
		value = BotWeapons.settings.weapon_cosmetics_chance,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		is_percentage = true,
		display_scale = 100,
		display_precision = 0,
		menu_id = menu_id_main,
		priority = 91
	})

	MenuHelper:AddSlider({
		id = "outfit_random_chance",
		title = "slider_outfit_random_chance_name",
		desc = "slider_outfit_random_chance_desc",
		callback = "BotWeapons_select",
		value = BotWeapons.settings.outfit_random_chance,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		is_percentage = true,
		display_scale = 100,
		display_precision = 0,
		menu_id = menu_id_main,
		priority = 90
	})

	MenuHelper:AddDivider({
		id = "divider3",
		size = 16,
		menu_id = menu_id_main,
		priority = 80
	})

	MenuHelper:AddToggle({
		id = "sync_settings",
		title = "toggle_sync_settings_name",
		desc = "toggle_sync_settings_desc",
		callback = "BotWeapons_toggle",
		value = BotWeapons.settings.sync_settings,
		menu_id = menu_id_main,
		priority = 79
	})

	MenuHelper:AddDivider({
		id = "divider4",
		size = 32,
		menu_id = menu_id_main,
		priority = 70
	})

	MenuHelper:AddToggle({
		id = "chatter",
		title = "toggle_chatter_name",
		desc = "toggle_chatter_desc",
		callback = "BotWeapons_toggle",
		value = BotWeapons.settings.chatter,
		menu_id = menu_id_main,
		priority = 69
	})

end)

-- Build the menus and add it to the Mod Options menu
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_BotWeapons", function(menu_manager, nodes)
	nodes[menu_id_main] = MenuHelper:BuildMenu(menu_id_main)
	MenuHelper:AddMenuItem(nodes["blt_options"], menu_id_main, "BotWeapons_menu_main_name", "BotWeapons_menu_main_desc")
end)
