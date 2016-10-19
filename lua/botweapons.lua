if _G.BotWeapons == nil then
  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath .. "bot_weapons_data.txt"
  BotWeapons._data = {}

  -- load custom models
  if ModCore then
    ModCore:init(BotWeapons._path .. "config.xml", true, true)
  end
  
  BotWeapons.armor = {
    { name = "bm_armor_level_1" },
    { name = "bm_armor_level_2" },
    { name = "bm_armor_level_3" },
    { name = "bm_armor_level_4" },
    { name = "bm_armor_level_5" },
    { name = "bm_armor_level_6" },
    { name = "bm_armor_level_7" },
    { name = "item_random" }
  }
  
  BotWeapons.equipment = {
    { name = "item_none", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
    { name = "bm_equipment_ammo_bag", parts = { g_ammobag = true, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
    { name = "bm_equipment_armor_kit", parts = { g_ammobag = false, g_armorbag = true, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
    { name = "bm_equipment_bodybags_bag", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = true, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
    { name = "bm_equipment_doctor_bag", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = true, g_sentrybag = false, g_toolbag = false }},
    { name = "bm_equipment_ecm_jammer", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = true }},
    { name = "bm_equipment_first_aid_kit", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = true, g_medicbag = false, g_sentrybag = false, g_toolbag = false }},
    { name = "bm_equipment_sentry_gun", parts = { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = true, g_toolbag = false }},
    { name = "item_random" }
  }
  
  BotWeapons.weapons = {
    { name = "item_beretta92", unit = Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92"), type = "pistol" },
    { name = "item_c45", unit = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45"), type = "pistol" },
    { name = "item_raging_bull", unit = Idstring("units/payday2/weapons/wpn_npc_raging_bull/wpn_npc_raging_bull"), type = "pistol" },
    { name = "item_m4", unit = Idstring("units/payday2/weapons/wpn_npc_m4/wpn_npc_m4"), type = "rifle" },
    { name = "item_ak47", unit = Idstring("units/payday2/weapons/wpn_npc_ak47/wpn_npc_ak47"), type = "rifle" },
    { name = "item_r870", unit = Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870"), type = "shotgun" },
    { name = "item_mossberg", unit = Idstring("units/payday2/weapons/wpn_npc_sawnoff_shotgun/wpn_npc_sawnoff_shotgun"), type = "shotgun" },
    { name = "item_mp5", unit = Idstring("units/payday2/weapons/wpn_npc_mp5/wpn_npc_mp5"), type = "smg" },
    { name = "item_mp5_tactical", unit = Idstring("units/payday2/weapons/wpn_npc_mp5_tactical/wpn_npc_mp5_tactical"), type = "smg" },
    { name = "item_mp9", unit = Idstring("units/payday2/weapons/wpn_npc_smg_mp9/wpn_npc_smg_mp9"), type = "smg" },
    { name = "item_mac11", unit = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11"), type = "smg" },
    { name = "item_m249", unit = Idstring("units/payday2/weapons/wpn_npc_lmg_m249/wpn_npc_lmg_m249"), type = "lmg" },
    { name = "item_benelli", unit = Idstring("units/payday2/weapons/wpn_npc_benelli/wpn_npc_benelli"), type = "shotgun" },
    { name = "item_g36", unit = Idstring("units/payday2/weapons/wpn_npc_g36/wpn_npc_g36"), type = "rifle" },
    { name = "item_ump", unit = Idstring("units/payday2/weapons/wpn_npc_ump/wpn_npc_ump"), type = "smg" },
    { name = "item_scar_murky", unit = Idstring("units/payday2/weapons/wpn_npc_scar_murkywater/wpn_npc_scar_murkywater"), type = "rifle" },
    { name = "item_asval", unit = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_asval/wpn_npc_asval"), type = "rifle" },
    { name = "item_sr2", unit = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_sr2/wpn_npc_sr2"), type = "smg" },
    { name = "item_akmsu", unit = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_akmsu/wpn_npc_akmsu"), type = "smg" },
    { name = "item_rpk", unit = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_rpk/wpn_npc_rpk"), type = "lmg" },
    -- weapons disabled in mp from here on
    { name = "item_saiga", unit = Idstring("units/payday2/weapons/wpn_npc_saiga/wpn_npc_saiga"), type = "shotgun" },
    -- own weapons from here on
    { name = "item_famas", unit = Idstring("units/payday2/weapons/wpn_npc_famas/wpn_npc_famas"), type = "rifle" },
    { name = "item_m14", unit = Idstring("units/payday2/weapons/wpn_npc_m14/wpn_npc_m14"), type = "rifle" },
    { name = "item_p90", unit = Idstring("units/payday2/weapons/wpn_npc_p90/wpn_npc_p90"), type = "smg" },
    { name = "item_judge", unit = Idstring("units/payday2/weapons/wpn_npc_judge/wpn_npc_judge"), type = "shotgun" },
    { name = "item_boot", unit = Idstring("units/payday2/weapons/wpn_npc_boot/wpn_npc_boot"), type = "shotgun" },
    { name = "item_x_c45", unit = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_x_c45"), type = "pistol" },
    { name = "item_x_mp5", unit = Idstring("units/payday2/weapons/wpn_npc_mp5/wpn_npc_x_mp5"), type = "smg" },
    { name = "item_x_akmsu", unit = Idstring("units/payday2/weapons/wpn_npc_akmsu/wpn_npc_x_akmsu"), type = "smg" },
    { name = "item_ksg", unit = Idstring("units/payday2/weapons/wpn_npc_ksg/wpn_npc_ksg"), type = "shotgun" },
    { name = "item_l85a2", unit = Idstring("units/payday2/weapons/wpn_npc_l85a2/wpn_npc_l85a2"), type = "rifle" },
    { name = "item_sterling", unit = Idstring("units/payday2/weapons/wpn_npc_sterling/wpn_npc_sterling"), type = "smg" },
    { name = "item_s552", unit = Idstring("units/payday2/weapons/wpn_npc_s552/wpn_npc_s552"), type = "rifle" },
    { name = "item_deagle", unit = Idstring("units/payday2/weapons/wpn_npc_deagle/wpn_npc_deagle"), type = "pistol" },
    { name = "item_x_sr2", unit = Idstring("units/payday2/weapons/wpn_npc_sr2/wpn_npc_x_sr2"), type = "smg" },
    { name = "item_hk21", unit = Idstring("units/payday2/weapons/wpn_npc_hk21/wpn_npc_hk21"), type = "lmg" },
    { name = "item_tecci", unit = Idstring("units/payday2/weapons/wpn_npc_tecci/wpn_npc_tecci"), type = "rifle" },
    { name = "item_g18c", unit = Idstring("units/payday2/weapons/wpn_npc_g18c/wpn_npc_g18c"), type = "pistol" },
    { name = "item_spas12", unit = Idstring("units/payday2/weapons/wpn_npc_spas12/wpn_npc_spas12"), type = "shotgun" },
    { name = "item_m1928", unit = Idstring("units/payday2/weapons/wpn_npc_m1928/wpn_npc_m1928"), type = "smg" },
    { name = "item_vhs", unit = Idstring("units/payday2/weapons/wpn_npc_vhs/wpn_npc_vhs"), type = "rifle" },
    { name = "item_x_beretta92", unit = Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_x_beretta92"), type = "pistol" },
    -- random
    { name = "item_random" }
  }
  
  -- index of the last weapon that is allowed in mp
  BotWeapons.mp_disabled_index = 20
  
  -- vanilla replacements
  BotWeapons.replacements = {}
  for i = 1, BotWeapons.mp_disabled_index, 1 do
    local weapon = BotWeapons.weapons[i]
    BotWeapons.replacements[weapon.type] = BotWeapons.replacements[weapon.type] or {}
    table.insert(BotWeapons.replacements[weapon.type], i)
  end
  
  -- difficulty multiplier
  BotWeapons.multiplier = {
    normal = 0.5,
    hard = 0.75,
    overkill = 0.875,
    overkill_145 = 1,
    easy_wish = 1.125,
    overkill_290 = 1.25,
    sm_wish = 1.5
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
    if not unit or not alive(unit) or not armor_index or not equipment_index then
      return
    end
    if not Global.game_settings.single_player and LuaNetworking:IsHost() then
      -- armor
      managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, "var_model_0" .. armor_index)
      -- equipment
      local name = managers.criminals:character_name_by_unit(unit)
      LuaNetworking:SendToPeers("bot_weapons_equipment", name .. "/" .. equipment_index)
    end
  end
  
  function BotWeapons:custom_weapons_allowed()
    if Global.game_settings.single_player then
      return true
    end
    if not Global.game_settings.team_ai then
      return true
    end
    if Global.game_settings.permission ~= "private" then
      return false
    end
    for _, peer in pairs(LuaNetworking:GetPeers()) do
      if not peer._has_bot_weapons then
        return false
      end
    end
    return false -- should be "true" once syncing of custom weapons is possible
  end
  
  Hooks:Add("BaseNetworkSessionOnLoadComplete", "BaseNetworkSessionOnLoadCompleteBotWeapons", function()
    if LuaNetworking:IsClient() then
      log("[BotWeapons] Sending usage info to host")
      LuaNetworking:SendToPeer(1, "bot_weapons_active", "")
    end
  end)

  Hooks:Add("NetworkReceivedData", "NetworkReceivedDataBotWeapons", function(sender, id, data)
    if id == "bot_weapons_active" then
      local peer = LuaNetworking:GetPeers()[sender]
      if peer then
        peer._has_bot_weapons = true
      end
    elseif id == "bot_weapons_equipment" and managers.criminals then
      if data:find("/") ~= nil then
        local name = data:sub(1, data:find("/") - 1)
        local equipment = tonumber(data:sub(data:find("/") + 1))
        BotWeapons:set_equipment(managers.criminals:character_unit_by_name(name), equipment)
      end
    end
  end)

  -- Load settings
  BotWeapons:Load()
end