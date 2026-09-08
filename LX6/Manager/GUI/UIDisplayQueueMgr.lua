-- Original chunk: @Lua\LuaFiles\LX6\Manager\GUI\UIDisplayQueueMgr.lua
-- Decompiled from: 00571_UIDisplayQueueMgr.lua_5430da04af27.luajit

local M = {
	nowShowPanelId = 0,
	queue = {}
}

M.OnInit = function(self)
	gMessageManager:RegisterEventHandlers(self.EventHandlers)
end

M.ShowNextPanel = function(self)
	if #self.queue <= 0 then
		local entry = self.queue[1]
		self.nowShowPanelId = entry.panelId

		gPanelManager:CheckShow(entry.panelId, entry.param)
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		for i = #self.queue, 1, -1 do
			if not self.queue[i].leaveSceneRetain then
				table.remove(self.queue, i)
			end
		end

		self.nowShowPanelId = 0
	end

	if switchType ~= gSwitchSceneType.KickToLogin then
		self.queue = {}
		self.nowShowPanelId = 0
	end
end

M.OnEnterRaid = function(self)
	if #self.queue <= 0 and self.nowShowPanelId ~= 0 then
		self.ShowNextPanel(self)
	end
end

M.EventHandlers = {
	[gEventConstants.L50_AFTER_SWITCH_SCENE] = function (eventId, switchSceneEventParams)
		local switchType = switchSceneEventParams.switchSceneType

		if switchType ~= gSwitchSceneType.Reconnect then
			return
		end

		M:OnEnterRaid()
	end,
	[gEventConstants.PANEL_ON_CLOSE] = function (eventId, data)
		if data ~= M.nowShowPanelId then
			M.nowShowPanelId = 0

			if #M.queue <= 0 then
				table.remove(M.queue, 1)
				M:ShowNextPanel()
			end
		end
	end
}
gUIDisplayQueueMgr = M
