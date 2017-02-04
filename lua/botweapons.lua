if _G.BotWeapons == nil then
  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath
  BotWeapons._data = {}
  
  function BotWeapons:Save()
    local file = io.open(self._data_path .. "bot_weapons_data.txt", "w+")
    if file then
      file:write(json.encode(self._data))
      file:close()
    end
  end

  function BotWeapons:Load()
    local file = io.open(self._data_path .. "bot_weapons_data.txt", "r")
    if file then
      self._data = json.decode(file:read("*all"))
      file:close()
    end
  end
  
  function BotWeapons:init()
    self:Load()
  
    self.version = "0.00"
    local file = io.open(BotWeapons._path .. "mod.txt", "r")
    if file then
      local data = json.decode(file:read("*all"))
      file:close()
      self.version = string.format("%.2f", data and data.updates and data.updates[1] and data.updates[1].revision or 0)
    end
    log("[BotWeapons] Version " .. self.version)
  
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
    
    self.masks = {
      { menu_name = "bm_msk_character_locked" },
      { menu_name = "item_same_as_me" }
    }
  
    -- difficulty multiplier
    self.multiplier = {
      normal = 0.4,
      hard = 0.55,
      overkill = 0.7,
      overkill_145 = 0.85,
      easy_wish = 1,
      overkill_290 = 1.3,
      sm_wish = 1.6
    }
  
    -- load weapon definitions
    local file = io.open(BotWeapons._path .. "weapons.json", "r")
    if file then
      self.weapons = json.decode(file:read("*all"))
      file:close()
    end
    self.weapons = self.weapons or {}
    
    -- load user overrides
    local file = io.open(BotWeapons._data_path .. "bot_weapons_overrides.json", "r")
    if file then
      log("[BotWeapons] Found custom weapon override file, loading it")
      local overrides = json.decode(file:read("*all"))
      file:close()
      if overrides then
        for _, weapon in ipairs(self.weapons) do
          if overrides[weapon.tweak_data] then
            weapon.online_name = overrides[weapon.tweak_data].online_name or weapon.online_name
            weapon.blueprint = overrides[weapon.tweak_data].blueprint or weapon.blueprint
          end
        end
      end
    end
  end
  
  function BotWeapons:get_menu_list(tbl)
    local menu_list = {}
    local names = {}
    local item_name
    local localized_name
    for _, v in ipairs(tbl) do
      item_name = v.menu_name:gsub("^bm_w", "item")
      table.insert(menu_list, item_name)
      localized_name = managers.localization:text(v.menu_name):upper()
      names[item_name] = localized_name:gsub(" PISTOLS?$", ""):gsub(" REVOLVER$", ""):gsub(" RIFLE$", ""):gsub(" SHOTGUN$", ""):gsub(" GUNS?$", ""):gsub(" LIGHT MACHINE$", ""):gsub(" SUBMACHINE$", ""):gsub(" ASSAULT$", ""):gsub(" SNIPER$", "")
    end
    table.insert(menu_list, "item_random")
    managers.localization:add_localized_strings(names)
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
  
  function BotWeapons:set_accuracy_multiplicator(weapon, mul)
    if not Global.game_settings then
      return
    end
    local old = weapon._old_acc_mul or 1
    for i, v in ipairs(weapon.FALLOFF) do
      local f = (#weapon.FALLOFF + 1 - i) / #weapon.FALLOFF
      v.acc[1] = math.max(math.min((v.acc[1] / old) * mul, 1), 0)
      v.acc[2] = math.max(math.min((v.acc[2] / old) * mul, 1), 0)
    end
    weapon._old_acc_mul = mul
  end
  
  function BotWeapons:set_single_fire_mode(weapon, rec1, rec2, rec3)
    if not Global.game_settings then
      return
    end
    weapon.FALLOFF[1].recoil = rec1 or weapon.FALLOFF[1].recoil
    weapon.FALLOFF[2].recoil = rec2 or weapon.FALLOFF[2].recoil
    weapon.FALLOFF[3].recoil = rec3 or weapon.FALLOFF[3].recoil
  end
  
  function BotWeapons:set_auto_fire_mode(weapon, mode1, mode2, mode3)
    if not Global.game_settings then
      return
    end
    weapon.FALLOFF[1].mode = mode1 or weapon.FALLOFF[1].mode
    weapon.FALLOFF[2].mode = mode2 or weapon.FALLOFF[2].mode
    weapon.FALLOFF[3].mode = mode3 or weapon.FALLOFF[3].mode
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
  
  function BotWeapons:set_mask(unit, mask_id, blueprint)
    if not unit or not alive(unit) then
      return
    end
    if unit:inventory() then
      unit:inventory():set_mask(mask_id, blueprint)
    end
  end
  
  function BotWeapons:sync_armor_and_equipment(unit, armor_index, equipment_index)
    if not unit or not alive(unit) or not unit:base() or not unit:base()._tweak_table then
      return
    end
    if not Global.game_settings.single_player and LuaNetworking:IsHost() then
      -- armor
      managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, "var_model_0" .. (armor_index or 1))
      -- equipment
      local name = unit:base()._tweak_table
      DelayedCalls:Add("bot_weapons_sync_equipment_" .. name, 1, function ()
        LuaNetworking:SendToPeers("bot_weapons_equipment", name .. "," .. (equipment_index or 1))
      end)
    end
  end
  
  function BotWeapons:build_mask_string(mask_id, blueprint)
    local s = "" .. (mask_id or " ")
    if not blueprint then
      return s
    end
    s = s .. "," .. (blueprint.color.id or " ") .. "," .. (blueprint.pattern.id or " ") .. "," .. (blueprint.material.id or " ")
    return s
  end
  
  function BotWeapons:sync_mask(unit, mask_id, blueprint)
    if not unit or not alive(unit) or not unit:base() or not unit:base()._tweak_table then
      return
    end
    if not Global.game_settings.single_player and LuaNetworking:IsHost() then
      -- mask
      local name = unit:base()._tweak_table
      DelayedCalls:Add("bot_weapons_sync_mask_" .. name, 1, function () 
        LuaNetworking:SendToPeers("bot_weapons_mask", name .. "," .. self:build_mask_string(mask_id, blueprint))
      end)
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
      LuaNetworking:SendToPeer(1, "bot_weapons_active", version)
    end
  end)

  Hooks:Add("NetworkReceivedData", "NetworkReceivedDataBotWeapons", function(sender, id, data)
    local peer = LuaNetworking:GetPeers()[sender]
    local params = string.split(data or "", ",", true)
    if id == "bot_weapons_active" and peer then
      if #params == 1 then
        if params[1] == BotWeapons.version then
          peer._has_bot_weapons = true
        else
          log("[BotWeapons] Client version mismatch")
        end
      end
    elseif id == "bot_weapons_equipment" and managers.criminals then
      if #params == 2 then
        local name = params[1]
        local equipment = tonumber(params[2])
        BotWeapons:set_equipment(managers.criminals:character_unit_by_name(name), equipment)
      end
    elseif id == "bot_weapons_mask" and managers.criminals then
      if #params >= 2 then
        local name = params[1]
        local mask_id = params[2]
        local blueprint
        if #params == 5 then
          blueprint = {
            color = {id = params[3]},
            pattern = {id = params[4]},
            material = {id = params[5]}
          }
        end
        BotWeapons:set_mask(managers.criminals:character_unit_by_name(name), mask_id, blueprint)
      end
    end
  end)

  -- Load settings
  BotWeapons:init()
end