-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoLastData.lua
-- Decompiled from: 00107_PlayerInfoLastData.lua_ebd88ce85b9a.luajit

C_PlayerInfoLastData = DefClass("C_PlayerInfoLastData", C_PlayerInfoLastData, C_PlayerDataBase)
local M = C_PlayerInfoLastData

M.InitPlayerInfo = function(self)
	gImageManager:Init()

	if not gCS.NetworkManager.IsReconnect then
		slot1 = gTimeNotificationManager

		slot1:RegisterConfigNewDay(self.OnNewDay)

		slot1 = gUnitStateManager

		slot1:Init()

		local panelId = gClientUtils.GetMainPhonePanelId()
		slot2 = gLuaUIMgr

		slot2:AddEnterGamePrompt(panelId, nil, 4, function ()
		end)
	end
end

M.OnNewDay = function()
	gPlayerManager.infoItem.pack.itemUseTimes = {}
end
