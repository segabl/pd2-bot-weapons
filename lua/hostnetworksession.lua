dofile(ModPath .. "lua/botweapons.lua")

local chk_drop_in_peer_original = HostNetworkSession.chk_drop_in_peer
function HostNetworkSession:chk_drop_in_peer(dropin_peer)
  BotWeapons._replace_guns = not dropin_peer._has_bot_weapons
  chk_drop_in_peer_original(self, dropin_peer)
end