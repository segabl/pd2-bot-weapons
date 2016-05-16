if _G.BotWeapons == nil then
  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath .. "bot_weapons_data.txt"
  BotWeapons._data = {}

  BotWeapons.weapon_ids = {
    "item_beretta92",
    "item_c45",
    "item_raging_bull",
    "item_m4",
    "item_ak47",
    "item_r870",
    "item_mossberg",
    "item_mp5",
    "item_mp5_tactical",
    "item_mp9",
    "item_mac11",
    "item_saiga",
    "item_m249",
    "item_benelli",
    "item_g36",
    "item_ump",
    "item_scar_murky",
    "item_asval",
    "item_sr2",
    "item_akmsu",
    "item_rpk",
    "item_random"
  }

  BotWeapons.weapon_unit_names = {
    Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92"),
    Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45"),
    Idstring("units/payday2/weapons/wpn_npc_raging_bull/wpn_npc_raging_bull"),
    Idstring("units/payday2/weapons/wpn_npc_m4/wpn_npc_m4"),
    Idstring("units/payday2/weapons/wpn_npc_ak47/wpn_npc_ak47"),
    Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870"),
    Idstring("units/payday2/weapons/wpn_npc_sawnoff_shotgun/wpn_npc_sawnoff_shotgun"),
    Idstring("units/payday2/weapons/wpn_npc_mp5/wpn_npc_mp5"),
    Idstring("units/payday2/weapons/wpn_npc_mp5_tactical/wpn_npc_mp5_tactical"),
    Idstring("units/payday2/weapons/wpn_npc_smg_mp9/wpn_npc_smg_mp9"),
    Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11"),
    Idstring("units/payday2/weapons/wpn_npc_saiga/wpn_npc_saiga"),
    Idstring("units/payday2/weapons/wpn_npc_lmg_m249/wpn_npc_lmg_m249"),
    Idstring("units/payday2/weapons/wpn_npc_benelli/wpn_npc_benelli"),
    Idstring("units/payday2/weapons/wpn_npc_g36/wpn_npc_g36"),
    Idstring("units/payday2/weapons/wpn_npc_ump/wpn_npc_ump"),
    Idstring("units/payday2/weapons/wpn_npc_scar_murkywater/wpn_npc_scar_murkywater"),
    Idstring("units/pd2_dlc_mad/weapons/wpn_npc_asval/wpn_npc_asval"),
    Idstring("units/pd2_dlc_mad/weapons/wpn_npc_sr2/wpn_npc_sr2"),
    Idstring("units/pd2_dlc_mad/weapons/wpn_npc_akmsu/wpn_npc_akmsu"),
    Idstring("units/pd2_dlc_mad/weapons/wpn_npc_rpk/wpn_npc_rpk")
  }

  function BotWeapons:Save()
    local file = io.open(self._data_path, "w+")
    if file then
      file:write(json.encode(self._data))
      file:close()
    end
  end

  function BotWeapons:Load()
    local file = io.open(self._data_path, "r")
    if file then
      self._data = json.decode(file:read("*all"))
      file:close()
    end
  end

  Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BotWeapons", function(loc)
    -- fallback to english
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
  local menu_id = "BotWeapons_menu"

  -- Register our new menu
  Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_BotWeapons", function(menu_manager, nodes)
    MenuHelper:NewMenu(menu_id)
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

    -- Load settings
    BotWeapons:Load()

    -- Toggle damage
    MenuHelper:AddToggle({
      id = "toggle_adjust_damage",
      title = "toggle_adjust_damage_name",
      desc = "toggle_adjust_damage_desc",
      callback = "BotWeapons_toggle",
      value = BotWeapons._data["toggle_adjust_damage"],
      menu_id = menu_id,
      priority = 100
   })
    
    -- divider
    MenuHelper:AddDivider({
      id = "divider1",
      size = 32,
      menu_id = menu_id,
      priority = 99,
   })
    
    --override
    MenuHelper:AddToggle({
      id = "toggle_override",
      title = "toggle_override_name",
      desc = "toggle_override_desc",
      callback = "BotWeapons_toggle",
      value = BotWeapons._data["toggle_override"] or false,
      menu_id = menu_id,
      priority = 98
   })
    
    MenuHelper:AddMultipleChoice({
      id = "override",
      title = "menu_override_name",
      callback = "BotWeapons_select",
      items = BotWeapons.weapon_ids;
      menu_id = menu_id,
      value = BotWeapons._data["override"] or (#BotWeapons.weapon_ids - 1),
      priority = 97
   })
    
    -- divider
    MenuHelper:AddDivider({
      id = "divider2",
      size = 32,
      menu_id = menu_id,
      priority = 96,
   })
    
    -- Add every available character to the menus using the game's own menu names
    for i = 1, CriminalsManager.get_num_characters() do
      local character = CriminalsManager.character_names()[i]

      MenuHelper:AddMultipleChoice({
        id = character,
        title = "menu_" .. character,
        callback = "BotWeapons_select",
        items = BotWeapons.weapon_ids;
        menu_id = menu_id,
        value = BotWeapons._data[character] or 4,
        priority = 96 - i
     })
    end
    
  end)

  -- Build the menu and add it to the Mod Options menu
  Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_BotWeapons", function(menu_manager, nodes)
    nodes[menu_id] = MenuHelper:BuildMenu(menu_id)
    MenuHelper:AddMenuItem(MenuHelper:GetMenu("lua_mod_options_menu"), menu_id, "BotWeapons_menu_name", "BotWeapons_menu_desc")
  end)
end