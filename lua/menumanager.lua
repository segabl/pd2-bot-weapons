dofile(ModPath .. "lua/botweapons.lua")

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BotWeapons", function(loc)
  -- load english localization as base
  loc:load_localization_file(BotWeapons._path .. "loc/english.txt")
  for _, filename in pairs(file.GetFiles(BotWeapons._path .. "loc/") or {}) do
    local str = filename:match('^(.*).txt$')
    if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
      loc:load_localization_file(BotWeapons._path .. "loc/" .. filename)
      break
    end
  end
end)

-- Menu setup
local menu_id_main = "BotWeapons_menu_main"

-- Register our new menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_BotWeapons", function(menu_manager, nodes)
  MenuHelper:NewMenu(menu_id_main)
end)

-- Populate it with items and callbacks
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
    id = "toggle_player_carry",
    title = "toggle_player_carry_name",
    desc = "toggle_player_carry_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_player_carry"] == nil and true or BotWeapons._data["toggle_player_carry"],
    menu_id = menu_id_main,
    priority = 100
  })

  MenuHelper:AddSlider({
    id = "slider_mask_customized_chance",
    title = "slider_mask_customized_chance_name",
    desc = "slider_mask_customized_chance_desc",
    callback = "BotWeapons_select",
    value = BotWeapons._data["slider_mask_customized_chance"] or 0.5,
    min = 0,
    max = 1,
    show_value = true,
    menu_id = menu_id_main,
    priority = 99
  })
  
end)

-- Build the menus and add it to the Mod Options menu
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_BotWeapons", function(menu_manager, nodes)
  nodes[menu_id_main] = MenuHelper:BuildMenu(menu_id_main)
  MenuHelper:AddMenuItem(MenuHelper:GetMenu("lua_mod_options_menu"), menu_id_main, "BotWeapons_menu_main_name", "BotWeapons_menu_main_desc")
end)