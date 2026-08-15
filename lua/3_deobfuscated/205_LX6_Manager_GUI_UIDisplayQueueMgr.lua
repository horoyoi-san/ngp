local M = {
	nowShowPanelId = 0,
	queue = {}
}

function M:OnInit()
	gMessageManager:RegisterEventHandlers(self.EventHandlers)
end

function M:ShowNextPanel()
	if #self.queue > 0 then
		local entry = self.queue[1]
		self.nowShowPanelId = entry.panelId

		gPanelManager:CheckShow(entry.panelId, entry.param)
	end
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		for i = #self.queue, 1, -1 do
			if not self.queue[i].leaveSceneRetain then
				table.remove(self.queue, i)
			end
		end

		self.nowShowPanelId = 0
	end

	if switchType == gSwitchSceneType.KickToLogin then
		self.queue = {}
		self.nowShowPanelId = 0
	end
end

function M:OnEnterRaid()
	if #self.queue > 0 and self.nowShowPanelId == 0 then
		self:ShowNextPanel()
	end
end

M.EventHandlers = {
	[gEventConstants.AFTER_SWITCH_SCENE] = function (eventId, switchType)
		if switchType == gSwitchSceneType.Reconnect then
			return
		end

		M:OnEnterRaid()
	end,
	[gEventConstants.PANEL_ON_CLOSE] = function (eventId, data)
		if data == M.nowShowPanelId then
			M.nowShowPanelId = 0

			if #M.queue > 0 then
				table.remove(M.queue, 1)
				M:ShowNextPanel()
			end
		end
	end
}
gUIDisplayQueueMgr = M
