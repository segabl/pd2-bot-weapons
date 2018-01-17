dofile(ModPath .. "botweapons.lua")

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BotWeapons", function(loc)
  if PD2KR then
    loc:load_localization_file(BotWeapons._path .. "loc/korean.txt")
  else
    for _, filename in pairs(file.GetFiles(BotWeapons._path .. "loc/") or {}) do
      local str = filename:match('^(.*).txt$')
      if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
        loc:load_localization_file(BotWeapons._path .. "loc/" .. filename)
        break
      end
    end
  end
  loc:load_localization_file(BotWeapons._path .. "loc/english.txt", false)
end)

local menu_id_main = "BotWeapons_menu_main"

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_BotWeapons", function(menu_manager, nodes)
  MenuHelper:NewMenu(menu_id_main)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_BotWeapons", function(menu_manager, nodes)

  MenuCallbackHandler.BotWeapons_select = function(self, item)
    BotWeapons._data[item:name()] = item:value()
    BotWeapons:save()
  end
  
  MenuCallbackHandler.BotWeapons_toggle = function(self, item)
    BotWeapons._data[item:name()] = (item:value() == "on");
    BotWeapons:save()
  end

  MenuHelper:AddToggle({
    id = "weapon_balance",
    title = "toggle_weapon_balance_name",
    desc = "toggle_weapon_balance_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data.weapon_balance,
    menu_id = menu_id_main,
    priority = 100
  })
  
  MenuHelper:AddToggle({
    id = "player_carry",
    title = "toggle_player_carry_name",
    desc = "toggle_player_carry_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data.player_carry,
    menu_id = menu_id_main,
    priority = 99
  })
  
  MenuHelper:AddToggle({
    id = "use_flashlights",
    title = "toggle_use_flashlights_name",
    desc = "toggle_use_flashlights_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data.use_flashlights,
    menu_id = menu_id_main,
    priority = 98
  })
  
  MenuHelper:AddToggle({
    id = "use_lasers",
    title = "toggle_use_lasers_name",
    desc = "toggle_use_lasers_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data.use_lasers,
    menu_id = menu_id_main,
    priority = 97
  })

  MenuHelper:AddSlider({
    id = "mask_customized_chance",
    title = "slider_mask_customized_chance_name",
    desc = "slider_mask_customized_chance_desc",
    callback = "BotWeapons_select",
    value = BotWeapons._data.mask_customized_chance,
    min = 0,
    max = 1,
    step = 0.01,
    show_value = true,
    menu_id = menu_id_main,
    priority = 96
  })
  
  MenuHelper:AddSlider({
    id = "weapon_customized_chance",
    title = "slider_weapon_customized_chance_name",
    desc = "slider_weapon_customized_chance_desc",
    callback = "BotWeapons_select",
    value = BotWeapons._data.weapon_customized_chance,
    min = 0,
    max = 1,
    step = 0.01,
    show_value = true,
    menu_id = menu_id_main,
    priority = 95
  })
  
  MenuHelper:AddSlider({
    id = "weapon_cosmetics_chance",
    title = "slider_weapon_cosmetics_chance_name",
    desc = "slider_weapon_cosmetics_chance_desc",
    callback = "BotWeapons_select",
    value = BotWeapons._data.weapon_cosmetics_chance,
    min = 0,
    max = 1,
    step = 0.01,
    show_value = true,
    menu_id = menu_id_main,
    priority = 94
  })
  
  MenuHelper:AddDivider({
    id = "divider",
    size = 16,
    menu_id = menu_id_main,
    priority = 93
  })
  
  MenuHelper:AddToggle({
    id = "sync_settings",
    title = "toggle_sync_settings_name",
    desc = "toggle_sync_settings_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data.sync_settings,
    menu_id = menu_id_main,
    priority = 93
  })
  
end)

-- Build the menus and add it to the Mod Options menu
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_BotWeapons", function(menu_manager, nodes)
  nodes[menu_id_main] = MenuHelper:BuildMenu(menu_id_main)
  MenuHelper:AddMenuItem(nodes["blt_options"], menu_id_main, "BotWeapons_menu_main_name", "BotWeapons_menu_main_desc")
end)