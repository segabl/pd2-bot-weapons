local _create_table_structureORIG = WeaponTweakData._create_table_structure

function WeaponTweakData:_create_table_structure()
  log("[BotWeapons] Setting up additional npc weapon usages")
  _create_table_structureORIG(self)
  
  self.g36_npc.usage = "g36"
  self.benelli_npc.usage = "benelli"
  self.m249_npc.usage = "m249"
  self.scar_npc.usage = "scar"
end