if not _G.BotWeapons then

  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath
  BotWeapons._data = {}

  function BotWeapons:init()
    self._revision = 0
    local file = io.open(BotWeapons._path .. "mod.txt", "r")
    if file then
      local data = json.decode(file:read("*all"))
      file:close()
      self._revision = data and data.updates and data.updates[1] and data.updates[1].revision or 0
    end
    log("[BotWeapons] Revision " .. self._revision)
  
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
  
    -- load weapon definitions
    file = io.open(BotWeapons._path .. "weapons.json", "r")
    if file then
      self.weapons = json.decode(file:read("*all"))
      file:close()
    end
    self.weapons = self.weapons or {}
    
    -- load user overrides
    file = io.open(BotWeapons._data_path .. "bot_weapons_overrides.json", "r")
    if file then
      log("[BotWeapons] Found custom weapon override file, loading it")
      local overrides = json.decode(file:read("*all"))
      file:close()
      if overrides then
        for _, weapon in ipairs(self.weapons) do
          if overrides[weapon.tweak_data] then
            weapon.blueprint = overrides[weapon.tweak_data].blueprint or weapon.blueprint
          end
        end
      end
    end
    
    -- load mask sets
    file = io.open(BotWeapons._path .. "masks.json", "r")
    if file then
      self.masks = json.decode(file:read("*all"))
      file:close()
    end
    self.masks = self.masks or {}
    
    -- load settings
    self:Load()
  end
  
  function BotWeapons:get_menu_list(tbl)
    local menu_list = {}
    local names = {}
    local item_name
    local localized_name
    for _, v in ipairs(tbl) do
      item_name = v.menu_name:gsub("^bm_w_", "item_")
      localized_name = managers.localization:text(v.menu_name):upper()     
      if v.menu_name:gmatch("^bm_w_.+") then
        localized_name = localized_name:gsub(" PISTOLS?$", ""):gsub(" REVOLVERS?$", ""):gsub(" RIFLES?$", ""):gsub(" SHOTGUNS?$", ""):gsub(" GUNS?$", ""):gsub(" LIGHT MACHINE$", ""):gsub(" SUBMACHINE$", ""):gsub(" ASSAULT$", ""):gsub(" SNIPER$", "")
      end
      table.insert(menu_list, item_name)
      names[item_name] = localized_name
    end
    table.insert(menu_list, "item_random")
    managers.localization:add_localized_strings(names)
    return menu_list
  end
  
  function BotWeapons:set_single_fire_mode(weapon, rec1, rec2)
    weapon.FALLOFF[1].recoil = rec1 or weapon.FALLOFF[1].recoil
    weapon.FALLOFF[#weapon.FALLOFF].recoil = rec2 or weapon.FALLOFF[#weapon.FALLOFF].recoil
  end
  
  function BotWeapons:set_auto_fire_mode(weapon, mode1, mode2)
    weapon.FALLOFF[1].mode = mode1 or weapon.FALLOFF[1].mode
    weapon.FALLOFF[#weapon.FALLOFF].mode = mode2 or weapon.FALLOFF[#weapon.FALLOFF].mode
  end
  
  function BotWeapons:create_interpolated_falloff_data(presets, steps)
    log("[BotWeapons] Interpolating FALLOFF in " .. steps .. " steps for gang presets")
    for _, weapon in pairs(presets) do
      if not weapon._interpolation_done then
        local first = weapon.FALLOFF[1]
        local last = weapon.FALLOFF[#weapon.FALLOFF]
        local data = {}
        local falloff, blend
        for i = 1, steps + 1 do
          falloff = deep_clone(last)
          table.insert(data, 1, falloff)
          blend = (i - 1) / steps
          falloff.r = math.lerp(last.r, first.r, blend)
          falloff.acc = { 
            math.lerp(last.acc[1], first.acc[1], blend),
            math.lerp(last.acc[2], first.acc[2], blend)
          }
          falloff.recoil = {
            math.lerp(last.recoil[1], first.recoil[1], blend),
            math.lerp(last.recoil[2], first.recoil[2], blend)
          }
        end
        weapon.FALLOFF = data
        weapon._interpolation_done = true
      end
    end
  end
  
  function BotWeapons:get_level_sequence()
    local current_level = managers.job and managers.job:current_level_id()
    if current_level then
      local sequence = tweak_data.levels[current_level] and tweak_data.levels[current_level].player_sequence
      if sequence then
        return sequence
      end
    end
  end
  
  function BotWeapons:set_armor(unit, armor_index)
    if not unit or not alive(unit) or not armor_index then
      return
    end
    unit:damage():run_sequence_simple("var_model_0" .. armor_index)
    -- run heist specific sequence
    local level_sequence = self:get_level_sequence()
    if level_sequence then
      unit:damage():run_sequence_simple(level_sequence)
    end
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
    unit:inventory():set_mask(mask_id, blueprint)
  end
  
  function BotWeapons:sync_armor_and_equipment(unit, armor_index, equipment_index)
    if not unit or not alive(unit) or not unit:base() or not unit:base()._tweak_table then
      return
    end
    if not Global.game_settings.single_player and LuaNetworking:IsHost() then
      -- armor
      managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, "var_model_0" .. (armor_index or 1))
      -- run heist specific sequence
      local level_sequence = self:get_level_sequence()
      if level_sequence then
        managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, level_sequence)
      end
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
  
  function BotWeapons:chk_create_sync_index()
    if self._weapon_indices then
      return
    end
    local weapon_list = {}
    for id, data in pairs(tweak_data.weapon.factory) do
      if id ~= "parts" and data.unit then
        table.insert(weapon_list, id)
      end
    end
    table.sort(weapon_list, function(a, b)
      return a < b
    end)
    self._weapon_indices = {}
    local start_index = #tweak_data.character.weap_unit_names
    for i, factory_id in ipairs(weapon_list) do
      self._weapon_indices[factory_id] = start_index + i
    end
  end
    
  function BotWeapons:sync_index_by_name(wanted_weap_name)
    if type_name(wanted_weap_name) == "Idstring" then
      for i, test_weap_name in ipairs(tweak_data.character.weap_unit_names) do
        if test_weap_name == wanted_weap_name then
          return i
        end
      end
    end
    self:chk_create_sync_index()
    return self._weapon_indices[wanted_weap_name]
  end
    
  function BotWeapons:replacement_by_index(index)
    if index <= #tweak_data.character.weap_unit_names then
      return index
    end
    local type_replacements = {
      pistol = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45"),
      rifle = Idstring("units/payday2/weapons/wpn_npc_m4/wpn_npc_m4"),
      shotgun = Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870"),
      smg = Idstring("units/payday2/weapons/wpn_npc_mp5/wpn_npc_mp5"),
      lmg = Idstring("units/payday2/weapons/wpn_npc_lmg_m249/wpn_npc_lmg_m249"),
    }
    for _, weapon in ipairs(self.weapons) do
      if self:sync_index_by_name(weapon.factory_name) == index then
        if weapon.online_name then
          return self:sync_index_by_name(Idstring(weapon.online_name))
        elseif type_replacements[weapon.type] then
          return self:sync_index_by_name(type_replacements[weapon.type])
        else
          return self:sync_index_by_name(type_replacements.rifle)
        end
      end
    end
    return self:sync_index_by_name(type_replacements.rifle)
  end
  
  function BotWeapons:get_masks_data()
    if not self._masks_data then
      self._masks_data = {}
      self._masks_data.masks = {}
      for k, v in pairs(tweak_data.blackmarket.masks) do
        if not v.inaccessible then
          table.insert(self._masks_data.masks, k)
        end
      end
      self._masks_data.colors = {}
      for k, _ in pairs(tweak_data.blackmarket.colors) do
        table.insert(self._masks_data.colors, k)
      end
      self._masks_data.patterns = {}
      for k, _ in pairs(tweak_data.blackmarket.textures) do
        table.insert(self._masks_data.patterns, k)
      end
      self._masks_data.materials = {}
      for k, _ in pairs(tweak_data.blackmarket.materials) do
        table.insert(self._masks_data.materials, k)
      end
    end
    return self._masks_data
  end
  
  Hooks:Add("BaseNetworkSessionOnLoadComplete", "BaseNetworkSessionOnLoadCompleteBotWeapons", function()
    if LuaNetworking:IsClient() then
      LuaNetworking:SendToPeer(1, "bot_weapons_active", BotWeapons._revision)
    end
  end)

  Hooks:Add("NetworkReceivedData", "NetworkReceivedDataBotWeapons", function(sender, id, data)
    local peer = LuaNetworking:GetPeers()[sender]
    local params = string.split(data or "", ",", true)
    if id == "bot_weapons_active" and peer then
      if #params == 1 then
        if tonumber(params[1]) == BotWeapons._revision then
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
  
  -- initialize
  BotWeapons:init()
  
end