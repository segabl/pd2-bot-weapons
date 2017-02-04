if _G.BotWeapons == nil then
  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath .. "bot_weapons_data.txt"
  BotWeapons._data = {}
  
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
  
  function BotWeapons:init()
    self:Load()
  
    self.armor = {
      { menu_name = "bm_armor_level_1" },
      { menu_name = "bm_armor_level_2" },
      { menu_name = "bm_armor_level_3" },
      { menu_name = "bm_armor_level_4" },
      { menu_name = "bm_armor_level_5" },
      { menu_name = "bm_armor_level_6" },
      { menu_name = "bm_armor_level_7" }
    }
  
    self.equipment = {
      { menu_name = "item_none", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
      { menu_name = "bm_equipment_ammo_bag", parts = { g_ammobag = true, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
      { menu_name = "bm_equipment_armor_kit", parts = { g_ammobag = false, g_armorbag = true, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
      { menu_name = "bm_equipment_bodybags_bag", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = true, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
      { menu_name = "bm_equipment_doctor_bag", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = true, g_sentrybag = false, g_toolbag = false }},
      { menu_name = "bm_equipment_ecm_jammer", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = true }},
      { menu_name = "bm_equipment_first_aid_kit", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = true, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
      { menu_name = "bm_equipment_sentry_gun", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = true, g_toolbag = false }}
    }
  
    -- difficulty multiplier
    self.multiplier = {
      normal = 0.5,
      hard = 0.75,
      overkill = 0.875,
      overkill_145 = 1,
      easy_wish = 1.125,
      overkill_290 = 1.25,
      sm_wish = 1.5
    }
  
    -- load weapon definitions
    local file = io.open(BotWeapons._path .. "weapons.json", "r")
    if file then
      self.weapons = json.decode(file:read("*all"))
      file:close()
    end
    self.weapons = self.weapons or {}
  end
  
  function BotWeapons:get_menu_list(tbl)
    local menu_list = {}
    for _, v in ipairs(tbl) do
      table.insert(menu_list, v.menu_name)
    end
    table.insert(menu_list, "item_random")
    return menu_list
  end
  
  function BotWeapons:set_damage_multiplicator(weapon, mul, falloff)
    if not BotWeapons._data.toggle_adjust_damage or not Global.game_settings or not self.multiplier[Global.game_settings.difficulty] then
      return
    end
    for i, v in ipairs(weapon.FALLOFF) do
      local f = (#weapon.FALLOFF + 1 - i) / #weapon.FALLOFF
      v.dmg_mul = self.multiplier[Global.game_settings.difficulty] * mul * (falloff and f or 1)
    end
  end
  
  function BotWeapons:set_armor(unit, armor_index)
    if not unit or not alive(unit) or not armor_index then
      return
    end
    unit:damage():run_sequence_simple("var_model_0" .. armor_index)
  end
  
  function BotWeapons:set_equipment(unit, equipment_index)
    if not unit or not alive(unit) or not equipment_index then
      return
    end
    for k, v in pairs(self.equipment[equipment_index].parts) do
      local mesh_obj = unit:get_object(Idstring(k))
      if mesh_obj then
        mesh_obj:set_visibility(v)
      end
    end
  end
  
  function BotWeapons:sync_armor_and_equipment(unit, armor_index, equipment_index)
    if not unit or not alive(unit) then
      return
    end
    if not Global.game_settings.single_player and LuaNetworking:IsHost() then
      -- armor
      managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, "var_model_0" .. (armor_index or 1))
      -- equipment
      local name = managers.criminals:character_name_by_unit(unit)
      DelayedCalls:Add("bot_weapons_sync_equipment_" .. name, 1, function () LuaNetworking:SendToPeers("bot_weapons_equipment", name .. "," .. (equipment_index or 1)) end)
    end
  end
  
  function BotWeapons:custom_weapons_allowed()
    if Global.game_settings.single_player then
      return true
    end
    if not Global.game_settings.team_ai then
      return false
    end
    if Global.game_settings.permission ~= "private" then
      return false
    end
    for _, peer in pairs(LuaNetworking:GetPeers()) do
      if not peer._has_bot_weapons then
        return false
      end
    end
    return true
  end
  
  Hooks:Add("BaseNetworkSessionOnLoadComplete", "BaseNetworkSessionOnLoadCompleteBotWeapons", function()
    if LuaNetworking:IsClient() then
      LuaNetworking:SendToPeer(1, "bot_weapons_active", "")
    end
  end)

  Hooks:Add("NetworkReceivedData", "NetworkReceivedDataBotWeapons", function(sender, id, data)
    local peer = LuaNetworking:GetPeers()[sender]
    if id == "bot_weapons_active" then
      if peer then
        peer._has_bot_weapons = true
      end
    elseif id == "bot_weapons_equipment" and managers.criminals then
      if data:find(",") ~= nil then
        local name = data:sub(1, data:find(",") - 1)
        local equipment = tonumber(data:sub(data:find(",") + 1))
        BotWeapons:set_equipment(managers.criminals:character_unit_by_name(name), equipment)
      end
    end
  end)

  -- Load settings
  BotWeapons:init()
end