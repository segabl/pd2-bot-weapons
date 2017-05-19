dofile(ModPath .. "lua/botweapons.lua")

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BotWeapons", function(loc)
  -- load english localization as base
  loc:load_localization_file(BotWeapons._path .. "loc/english.txt")
  for _, filename in pairs(file.GetFiles(BotWeapons._path .. "loc/")) do
    local str = filename:match('^(.*).txt$')
    if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
      loc:load_localization_file(BotWeapons._path .. "loc/" .. filename)
      break
    end
  end
end)

-- Menu setup
local menu_id_main = "BotWeapons_menu_main"
local menu_id_weapons = "BotWeapons_menu_weapons"
local menu_id_masks = "BotWeapons_menu_masks"
local menu_id_equipment = "BotWeapons_menu_equipment"
local menu_id_armor = "BotWeapons_menu_armor"

-- Register our new menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_BotWeapons", function(menu_manager, nodes)
  MenuHelper:NewMenu(menu_id_main)
  MenuHelper:NewMenu(menu_id_armor)
  MenuHelper:NewMenu(menu_id_equipment)
  MenuHelper:NewMenu(menu_id_masks)
  MenuHelper:NewMenu(menu_id_weapons)
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

  -- ARMOR MENU
  MenuHelper:AddToggle({
    id = "toggle_override_armor",
    title = "toggle_override_armor_name",
    desc = "toggle_override_armor_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_override_armor"] or false,
    menu_id = menu_id_armor,
    priority = 98
  })

  local armor_list = BotWeapons:get_menu_list(BotWeapons.armor)
  MenuHelper:AddMultipleChoice({
    id = "override_armor",
    title = "menu_override_name",
    callback = "BotWeapons_select",
    items = armor_list,
    menu_id = menu_id_armor,
    value = BotWeapons._data["override_armor"] or #BotWeapons.armor + 1,
    priority = 97
  })
  
  MenuHelper:AddDivider({
    id = "divider2",
    size = 24,
    menu_id = menu_id_armor,
    priority = 96,
  })

  for i, c in ipairs(CriminalsManager.character_names()) do
    MenuHelper:AddMultipleChoice({
      id = c .. "_armor",
      title = "menu_" .. c,
      callback = "BotWeapons_select",
      items = armor_list,
      menu_id = menu_id_armor,
      value = BotWeapons._data[c .. "_armor"] or 1,
      priority = 96 - i
    })
  end
  
  -- EQUIPMENT MENU
  MenuHelper:AddToggle({
    id = "toggle_player_carry",
    title = "toggle_player_carry_name",
    desc = "toggle_player_carry_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_player_carry"] == nil and true or BotWeapons._data["toggle_player_carry"],
    menu_id = menu_id_equipment,
    priority = 100
  })
  
  MenuHelper:AddDivider({
    id = "divider1",
    size = 24,
    menu_id = menu_id_equipment,
    priority = 99,
  })
  
  MenuHelper:AddToggle({
    id = "toggle_override_equipment",
    title = "toggle_override_equipment_name",
    desc = "toggle_override_equipment_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_override_equipment"] or false,
    menu_id = menu_id_equipment,
    priority = 98
  })
  
  local equipment_list = BotWeapons:get_menu_list(BotWeapons.equipment)
  MenuHelper:AddMultipleChoice({
    id = "override_equipment",
    title = "menu_override_name",
    callback = "BotWeapons_select",
    items = equipment_list,
    menu_id = menu_id_equipment,
    value = BotWeapons._data["override_equipment"] or #BotWeapons.equipment + 1,
    priority = 97
  })
  
  MenuHelper:AddDivider({
    id = "divider2",
    size = 24,
    menu_id = menu_id_equipment,
    priority = 96,
  })

  for i, c in ipairs(CriminalsManager.character_names()) do
    MenuHelper:AddMultipleChoice({
      id = c .. "_equipment",
      title = "menu_" .. c,
      callback = "BotWeapons_select",
      items = equipment_list,
      menu_id = menu_id_equipment,
      value = BotWeapons._data[c .. "_equipment"] or 1,
      priority = 96 - i
    })
  end
  
  -- MASKS MENU
  MenuHelper:AddSlider({
    id = "slider_mask_customized_chance",
    title = "slider_mask_customized_chance_name",
    desc = "slider_mask_customized_chance_desc",
    callback = "BotWeapons_select",
    value = BotWeapons._data["slider_mask_customized_chance"] or 0.5,
    min = 0,
    max = 1,
    show_value = true,
    menu_id = menu_id_masks,
    priority = 100
  })
  
  MenuHelper:AddDivider({
    id = "divider1",
    size = 24,
    menu_id = menu_id_masks,
    priority = 99,
  })
  
  MenuHelper:AddToggle({
    id = "toggle_override_masks",
    title = "toggle_override_masks_name",
    desc = "toggle_override_masks_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_override_masks"] or false,
    menu_id = menu_id_masks,
    priority = 98
  })
  
  local mask_list = BotWeapons:get_menu_list(BotWeapons.masks)
  MenuHelper:AddMultipleChoice({
    id = "override_masks",
    title = "menu_override_name",
    callback = "BotWeapons_select",
    items = mask_list,
    menu_id = menu_id_masks,
    value = BotWeapons._data["override_masks"] or #BotWeapons.masks,
    priority = 97
  })
  
  MenuHelper:AddDivider({
    id = "divider2",
    size = 24,
    menu_id = menu_id_masks,
    priority = 96,
  })

  for i, c in ipairs(CriminalsManager.character_names()) do
    MenuHelper:AddMultipleChoice({
      id = c .. "_mask",
      title = "menu_" .. c,
      callback = "BotWeapons_select",
      items = mask_list,
      menu_id = menu_id_masks,
      value = BotWeapons._data[c .. "_mask"] or 1,
      priority = 96 - i
    })
  end
  
  -- WEAPONS MENU
  MenuHelper:AddToggle({
    id = "toggle_override_weapons",
    title = "toggle_override_weapons_name",
    desc = "toggle_override_weapons_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_override_weapons"] or false,
    menu_id = menu_id_weapons,
    priority = 98
  })
  
  local weapon_list = BotWeapons:get_menu_list(BotWeapons.weapons)
  MenuHelper:AddMultipleChoice({
    id = "override_weapons",
    title = "menu_override_name",
    callback = "BotWeapons_select",
    items = weapon_list,
    menu_id = menu_id_weapons,
    value = BotWeapons._data["override_weapons"] or #BotWeapons.weapons + 1,
    priority = 97
  })
  
  MenuHelper:AddDivider({
    id = "divider2",
    size = 24,
    menu_id = menu_id_weapons,
    priority = 96,
  })

  for i, c in ipairs(CriminalsManager.character_names()) do
    MenuHelper:AddMultipleChoice({
      id = c .. "_weapon",
      title = "menu_" .. c,
      callback = "BotWeapons_select",
      items = weapon_list,
      menu_id = menu_id_weapons,
      value = BotWeapons._data[c .. "_weapon"] or 1,
      priority = 96 - i
    })
  end
  
end)

-- Build the menus and add it to the Mod Options menu
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_BotWeapons", function(menu_manager, nodes)
  nodes[menu_id_main] = MenuHelper:BuildMenu(menu_id_main)
  nodes[menu_id_armor] = MenuHelper:BuildMenu(menu_id_armor)
  nodes[menu_id_equipment] = MenuHelper:BuildMenu(menu_id_equipment)
  nodes[menu_id_masks] = MenuHelper:BuildMenu(menu_id_masks)
  nodes[menu_id_weapons] = MenuHelper:BuildMenu(menu_id_weapons)
  MenuHelper:AddMenuItem(MenuHelper:GetMenu("lua_mod_options_menu"), menu_id_main, "BotWeapons_menu_main_name", "BotWeapons_menu_main_desc")
  MenuHelper:AddMenuItem(nodes[menu_id_main], menu_id_armor, "BotWeapons_menu_armor_name", "BotWeapons_menu_armor_desc")
  MenuHelper:AddMenuItem(nodes[menu_id_main], menu_id_equipment, "BotWeapons_menu_equipment_name", "BotWeapons_menu_equipment_desc", menu_id_armor)
  MenuHelper:AddMenuItem(nodes[menu_id_main], menu_id_masks, "BotWeapons_menu_masks_name", "BotWeapons_menu_masks_desc", menu_id_equipment)
  MenuHelper:AddMenuItem(nodes[menu_id_main], menu_id_weapons, "BotWeapons_menu_weapons_name", "BotWeapons_menu_weapons_desc", menu_id_masks)
end)