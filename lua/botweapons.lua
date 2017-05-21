if not _G.BotWeapons then

  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath
  BotWeapons._data = {}

  function BotWeapons:log(message, condition)
    if condition or condition == nil then
      log("[BotWeapons] " .. message)
    end
  end
  
  function BotWeapons:init()
    self._revision = 0
    local file = io.open(BotWeapons._path .. "mod.txt", "r")
    if file then
      local data = json.decode(file:read("*all"))
      file:close()
      self._revision = data and data.updates and data.updates[1] and data.updates[1].revision or 0
    end
    self:log("Revision " .. self._revision)
  
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
      self:log("Found custom weapon override file, loading it")
      local overrides = json.decode(file:read("*all"))
      file:close()
      if overrides then
        for _, weapon in ipairs(self.weapons) do
          if weapon.tweak_data and weapon.tweak_data.name and overrides[weapon.tweak_data.name] then
            weapon.blueprint = overrides[weapon.tweak_data.name].blueprint or weapon.blueprint
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
    self:load()
  end
  
  function BotWeapons:get_menu_list(tbl)
    local menu_list = {}
    local names = {}
    local item_name
    local localized_name
    for _, v in ipairs(tbl) do
      item_name = v.menu_name:gsub("^bm_w_", "item_")
      localized_name = managers.localization:text(v.menu_name):upper()     
      if v.menu_name:match("^bm_w_.+") then
        localized_name = localized_name:gsub(" PISTOLS?$", ""):gsub(" REVOLVERS?$", ""):gsub(" RIFLES?$", ""):gsub(" SHOTGUNS?$", ""):gsub(" GUNS?$", ""):gsub(" LIGHT MACHINE$", ""):gsub(" SUBMACHINE$", ""):gsub(" ASSAULT$", ""):gsub(" SNIPER$", "")
      end
      table.insert(menu_list, item_name)
      names[item_name] = localized_name
    end
    table.insert(menu_list, "item_random")
    managers.localization:add_localized_strings(names)
    return menu_list
  end
  
  function BotWeapons:set_single_fire_mode(weapon, rec)
    for _, v in ipairs(weapon.FALLOFF) do
      v.recoil = rec
    end
  end
  
  function BotWeapons:set_auto_fire_mode(weapon, mode)
    for _, v in ipairs(weapon.FALLOFF) do
      v.mode = mode
    end
  end
  
  function BotWeapons:create_interpolated_falloff_data(presets, steps)
    self:log("Interpolating FALLOFF in " .. steps .. " steps for gang presets")
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
    if not Global.game_settings.single_player and LuaNetworking:IsHost() and Utils:IsInGameState() then
      managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, "var_model_0" .. (armor_index or 1))
      -- run heist specific sequence
      if level_sequence then
        managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, level_sequence)
      end
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
    if not Global.game_settings.single_player and LuaNetworking:IsHost() and Utils:IsInGameState() then
      local name = unit:base()._tweak_table
      DelayedCalls:Add("bot_weapons_sync_equipment_" .. name, 1, function ()
        LuaNetworking:SendToPeers("bot_weapons_equipment", name .. "," .. (equipment_index or 1))
      end)
    end
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
  
  function BotWeapons:get_loadout(char_name, original_loadout)
    local loadout = deep_clone(original_loadout)
    if LuaNetworking:IsHost() then
    
      -- choose mask
      if loadout.mask == "character_locked" then
        loadout.mask_slot = nil
        
        local masks_data = self:get_masks_data()
        local index = self._data[char_name .. "_mask"] or 1
        if self._data.toggle_override_masks then
          index = self._data.override_masks or (#self.masks + 1)
        end
        
        if index > #self.masks then
          loadout.mask = masks_data.masks[math.random(#masks_data.masks)]
          if math.random() < (self._data.slider_mask_customized_chance or 0.5) then
            loadout.mask_blueprint = {
              color = {id = masks_data.colors[math.random(#masks_data.colors)]},
              pattern = {id = masks_data.patterns[math.random(#masks_data.patterns)]},
              material = {id = masks_data.materials[math.random(#masks_data.materials)]}
            }
          end
        elseif self.masks[index].menu_name == "item_same_as_me" then
          local player_mask = managers.blackmarket:equipped_mask()
          if player_mask then
            loadout.mask = player_mask.mask_id
            loadout.mask_blueprint = player_mask.blueprint
          end
        elseif self.masks[index][char_name] or self.masks[index].pool then
          local selection = self.masks[index][char_name] or self.masks[index].pool[math.random(#self.masks[index].pool)]
          loadout.mask = selection.id
          loadout.mask_blueprint = selection.blueprint
        end
      end
      
      -- choose weapon
      if not loadout.primary then
        loadout.primary_slot = nil
        
        local weapon_index = self._data[char_name .. "_weapon"] or 1
        if self._data.toggle_override_weapons then
          weapon_index = self._data.override_weapons or (#self.weapons + 1)
        end
        if weapon_index > #self.weapons then
          weapon_index = math.random(#self.weapons)
        end
        local weapon = self.weapons[weapon_index]
        loadout.primary = weapon.factory_name
        loadout.primary_blueprint = weapon.blueprint
      end
      
      -- choose armor models
      local armor_index = BotWeapons._data[char_name .. "_armor"] or 1
      if BotWeapons._data.toggle_override_armor then
        armor_index = BotWeapons._data.override_armor or (#BotWeapons.armor + 1)
      end
      if armor_index > #BotWeapons.armor then
        armor_index = math.random(#BotWeapons.armor)
      end
      loadout.armor_index = armor_index
      -- choose equipment models
      local equipment_index = BotWeapons._data[char_name .. "_equipment"] or 1
      if BotWeapons._data.toggle_override_equipment then
        equipment_index = BotWeapons._data.override_equipment or (#BotWeapons.equipment + 1)
      end
      if equipment_index > #BotWeapons.equipment then
        equipment_index = math.random(#BotWeapons.equipment)
      end
      loadout.equipment_index = equipment_index
      
    end
    return loadout
  end

  Hooks:Add("NetworkReceivedData", "NetworkReceivedDataBotWeapons", function(sender, id, data)
    local peer = LuaNetworking:GetPeers()[sender]
    local params = string.split(data or "", ",", true)
    if id == "bot_weapons_equipment" and managers.criminals then
      if #params == 2 then
        local name = params[1]
        local equipment = tonumber(params[2])
        BotWeapons:set_equipment(managers.criminals:character_unit_by_name(name), equipment)
      end
    end
  end)

  function BotWeapons:save()
    local file = io.open(self._data_path .. "bot_weapons_data.txt", "w+")
    if file then
      file:write(json.encode(self._data))
      file:close()
    end
  end

  function BotWeapons:load()
    local file = io.open(self._data_path .. "bot_weapons_data.txt", "r")
    if file then
      self._data = json.decode(file:read("*all"))
      file:close()
    end
  end
  
  -- initialize
  BotWeapons:init()
  
end