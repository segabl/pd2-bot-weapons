if _G.BotWeapons == nil then
  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath .. "bot_weapons_data.txt"
  BotWeapons._data = {}
  
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
    { name = "item_beretta92", unit = "wpn_fps_pis_b92fs_npc", type = "pistol" },
    { name = "item_c45", unit = "wpn_fps_pis_g17_npc", type = "pistol" },
    { name = "item_raging_bull", unit = "wpn_fps_pis_rage_npc", type = "pistol" },
    { name = "item_m4", unit = "wpn_fps_ass_m4_npc", type = "rifle" },
    { name = "item_ak47", unit = "wpn_fps_ass_74_npc", type = "rifle" },
    { name = "item_r870", unit = "wpn_fps_shot_r870_npc", type = "shotgun" },
    { name = "item_mossberg", unit = "wpn_fps_shot_huntsman_npc", type = "shotgun" },
    { name = "item_mp5", unit = "wpn_fps_smg_mp5_npc", type = "smg" },
    { name = "item_mp5_tactical", unit = "wpn_fps_smg_mp5_npc", type = "smg" },
    { name = "item_mp9", unit = "wpn_fps_smg_mp9_npc", type = "smg" },
    { name = "item_mac11", unit = "wpn_fps_smg_mac10_npc", type = "smg" },
    { name = "item_m249", unit = "wpn_fps_lmg_m249_npc", type = "lmg" },
    { name = "item_benelli", unit = "wpn_fps_sho_ben_npc", type = "shotgun" },
    { name = "item_g36", unit = "wpn_fps_ass_g36_npc", type = "rifle" },
    { name = "item_ump", unit = "wpn_fps_ass_g36_npc", type = "smg" },
    { name = "item_scar_murky", unit = "wpn_fps_ass_scar_npc", type = "rifle" },
    { name = "item_asval", unit = "wpn_fps_ass_asval_npc", type = "rifle" },
    { name = "item_sr2", unit = "wpn_fps_smg_sr2_npc", type = "smg" },
    { name = "item_akmsu", unit = "wpn_fps_smg_akmsu_npc", type = "smg" },
    { name = "item_rpk", unit = "wpn_fps_lmg_rpk_npc", type = "lmg" },
    { name = "item_saiga", unit = "wpn_fps_shot_saiga_npc", type = "shotgun" },
    { name = "item_famas", unit = "wpn_fps_ass_famas_npc", type = "rifle" },
    { name = "item_m14", unit = "wpn_fps_ass_m14_npc", type = "rifle" },
    { name = "item_p90", unit = "wpn_fps_smg_p90_npc", type = "smg" },
    { name = "item_judge", unit = "wpn_fps_pis_judge_npc", type = "shotgun" },
    { name = "item_boot", unit = "wpn_fps_sho_boot_npc", type = "shotgun" },
    { name = "item_x_c45", unit = "wpn_fps_pis_x_g17_npc", type = "pistol" },
    { name = "item_x_mp5", unit = "wpn_fps_smg_x_mp5_npc", type = "smg" },
    { name = "item_x_akmsu", unit = "wpn_fps_smg_x_akmsu_npc", type = "smg" },
    { name = "item_ksg", unit = "wpn_fps_sho_ksg_npc", type = "shotgun" },
    { name = "item_l85a2", unit = "wpn_fps_ass_l85a2_npc", type = "rifle" },
    { name = "item_sterling", unit = "wpn_fps_smg_sterling_npc", type = "smg" },
    { name = "item_s552", unit = "wpn_fps_ass_s552_npc", type = "rifle" },
    { name = "item_deagle", unit = "wpn_fps_pis_deagle_npc", type = "pistol" },
    { name = "item_x_sr2", unit = "wpn_fps_smg_x_sr2_npc", type = "smg" },
    { name = "item_hk21", unit = "wpn_fps_lmg_hk21_npc", type = "lmg" },
    { name = "item_tecci", unit = "wpn_fps_ass_tecci_npc", type = "rifle" },
    { name = "item_g18c", unit = "wpn_fps_pis_g18c_npc", type = "pistol" },
    { name = "item_spas12", unit = "wpn_fps_sho_spas12_npc", type = "shotgun" },
    { name = "item_m1928", unit = "wpn_fps_smg_thompson_npc", type = "smg" },
    { name = "item_vhs", unit = "wpn_fps_ass_vhs_npc", type = "rifle" },
    { name = "item_x_beretta92", unit = "wpn_fps_x_b92fs_npc", type = "pistol" },
    -- random
    { name = "item_random" }
  }
  
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