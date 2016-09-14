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
local menu_id_weapons = "BotWeapons_menu_weapons"
local menu_id_equipment = "BotWeapons_menu_equipment"
local menu_id_armor = "BotWeapons_menu_armor"

-- Register our new menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_BotWeapons", function(menu_manager, nodes)
  MenuHelper:NewMenu(menu_id_armor)
  MenuHelper:NewMenu(menu_id_equipment)
  MenuHelper:NewMenu(menu_id_weapons)
end)

-- Populate it with items and callbacks
Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_BotWeapons", function(menu_manager, nodes)

  MenuCallbackHandler.BotWeapons_select = function(self, item)
    BotWeapons._data[item:name()] = item:value()
    BotWeapons:Save()
  end
  
  MenuCallbackHandler.BotWeapons_toggle = function(self, item)
    BotWeapons._data[item:name()] = (item:value() == "on");
    BotWeapons:Save()
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
  
  MenuHelper:AddMultipleChoice({
    id = "override_armor",
    title = "menu_override_name",
    callback = "BotWeapons_select",
    items = BotWeapons.armor_ids;
    menu_id = menu_id_armor,
    value = BotWeapons._data["override_armor"] or (#BotWeapons.armor_ids),
    priority = 97
 })
  
  MenuHelper:AddDivider({
    id = "divider2",
    size = 32,
    menu_id = menu_id_armor,
    priority = 96,
 })

  for i, c in ipairs(CriminalsManager.character_names()) do
    MenuHelper:AddMultipleChoice({
      id = c .. "_armor",
      title = "menu_" .. c,
      callback = "BotWeapons_select",
      items = BotWeapons.armor_ids;
      menu_id = menu_id_armor,
      value = BotWeapons._data[c .. "_armor"] or 1,
      priority = 96 - i
   })
  end
  
  -- EQUIPMENT MENU
  MenuHelper:AddToggle({
    id = "toggle_override_equipment",
    title = "toggle_override_equipment_name",
    desc = "toggle_override_equipment_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_override_equipment"] or false,
    menu_id = menu_id_equipment,
    priority = 98
 })
  
  MenuHelper:AddMultipleChoice({
    id = "override_equipment",
    title = "menu_override_name",
    callback = "BotWeapons_select",
    items = BotWeapons.equipment_ids;
    menu_id = menu_id_equipment,
    value = BotWeapons._data["override_equipment"] or (#BotWeapons.equipment_ids),
    priority = 97
 })
  
  MenuHelper:AddDivider({
    id = "divider2",
    size = 32,
    menu_id = menu_id_equipment,
    priority = 96,
 })

  for i, c in ipairs(CriminalsManager.character_names()) do
    MenuHelper:AddMultipleChoice({
      id = c .. "_equipment",
      title = "menu_" .. c,
      callback = "BotWeapons_select",
      items = BotWeapons.equipment_ids;
      menu_id = menu_id_equipment,
      value = BotWeapons._data[c .. "_equipment"] or 1,
      priority = 96 - i
   })
  end
  
  -- WEAPONS MENU
  MenuHelper:AddToggle({
    id = "toggle_adjust_damage",
    title = "toggle_adjust_damage_name",
    desc = "toggle_adjust_damage_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_adjust_damage"],
    menu_id = menu_id_weapons,
    priority = 100
 })

  MenuHelper:AddDivider({
    id = "divider1",
    size = 32,
    menu_id = menu_id_weapons,
    priority = 99,
 })

  MenuHelper:AddToggle({
    id = "toggle_override_weapons",
    title = "toggle_override_weapons_name",
    desc = "toggle_override_weapons_desc",
    callback = "BotWeapons_toggle",
    value = BotWeapons._data["toggle_override_weapons"] or false,
    menu_id = menu_id_weapons,
    priority = 98
 })
  
  MenuHelper:AddMultipleChoice({
    id = "override_weapons",
    title = "menu_override_name",
    callback = "BotWeapons_select",
    items = BotWeapons.weapon_ids;
    menu_id = menu_id_weapons,
    value = BotWeapons._data["override_weapons"] or (#BotWeapons.weapon_ids),
    priority = 97
 })
  
  MenuHelper:AddDivider({
    id = "divider2",
    size = 32,
    menu_id = menu_id_weapons,
    priority = 96,
 })

  for i, c in ipairs(CriminalsManager.character_names()) do
    MenuHelper:AddMultipleChoice({
      id = c .. "_weapon",
      title = "menu_" .. c,
      callback = "BotWeapons_select",
      items = BotWeapons.weapon_ids;
      menu_id = menu_id_weapons,
      value = BotWeapons._data[c .. "_weapon"] or 4,
      priority = 96 - i
   })
  end
  
end)

-- Build the menus and add it to the Mod Options menu
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_BotWeapons", function(menu_manager, nodes)
  nodes[menu_id_armor] = MenuHelper:BuildMenu(menu_id_armor)
  nodes[menu_id_equipment] = MenuHelper:BuildMenu(menu_id_equipment)
  nodes[menu_id_weapons] = MenuHelper:BuildMenu(menu_id_weapons)
  MenuHelper:AddMenuItem(MenuHelper:GetMenu("lua_mod_options_menu"), menu_id_armor, "BotWeapons_menu_armor_name", "BotWeapons_menu_armor_desc")
  MenuHelper:AddMenuItem(MenuHelper:GetMenu("lua_mod_options_menu"), menu_id_equipment, "BotWeapons_menu_equipment_name", "BotWeapons_menu_equipment_desc", menu_id_armor)
  MenuHelper:AddMenuItem(MenuHelper:GetMenu("lua_mod_options_menu"), menu_id_weapons, "BotWeapons_menu_weapons_name", "BotWeapons_menu_weapons_desc", menu_id_deployables)
end)