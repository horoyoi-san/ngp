C_PlayerInfoLastData = DefClass("C_PlayerInfoLastData", C_PlayerInfoLastData, C_PlayerDataBase)
local M = C_PlayerInfoLastData

function M:InitPlayerInfo()
	gSKeyManager:OnLogin()
	gImageManager:Init()

	if not gCS.NetworkManager.IsReconnect then
		gTimeNotificationManager:RegisterConfigNewDay(self.OnNewDay)
		gUnitStateManager:Init()

		local panelId = gClientUtils.GetMainPhonePanelId()

		gLuaUIMgr:AddEnterGamePrompt(panelId, nil, 4, function ()
			return
		end)
	end
end

function M.OnNewDay()
	gPlayerManager.infoItem.pack.itemUseTimes = {}
end
