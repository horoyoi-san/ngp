-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlinePlayMatchWaitingStore.lua
-- Decompiled from: 01116_OnlinePlayMatchWaitingStore.lua_7f70fab02f48.luajit

C_OnlinePlayMatchWaitingStore = DefClass("C_OnlinePlayMatchWaitingStore", C_OnlinePlayMatchWaitingStore, C_StoreGroup)
GroupName2Class.OnlinePlayMatchWaitingStore = C_OnlinePlayMatchWaitingStore
local M = C_OnlinePlayMatchWaitingStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, "OnCancelBtnClick")
	self.bindData.detailBtn.luaClick = self.CreateAction(self, "OnDetailBtnClick")
	self.msgEvents = {
		[gEventConstants.LINK_SEARCHING_REFRESH] = self.CreateAction(self, self.OnRefreshSearching),
		[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, self.OnPanelVisibleStateChange),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, self.OnPanelVisibleStateChange),
		[gEventConstants.ON_ENTER_INTERACTION_WORLD_UI] = self.CreateAction(self, self.OnPanelVisibleStateChange),
		[gEventConstants.ON_EXIT_INTERACTION_WORLD_UI] = self.CreateAction(self, self.OnPanelVisibleStateChange)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
end

M.OnDisable = function(self)
end

M.OnCancelBtnClick = function(self)
	if self.cancelCallback then
		self.cancelCallback()
		self.CloseSelf(self)

		return
	end

	gLinkManager:AskMatchCancel(self:CreateAction("CloseSelf"))
end

M.OnDetailBtnClick = function(self)
	if self.detailCallback then
		self.CloseSelf(self)
		self.detailCallback()

		return
	end

	self:CloseSelf()
	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL)
end

M.CloseSelf = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL)
end

M.OnShow = function(self, panelId, data)
	self.cancelCallback = data and data.cancelCallback or nil
	self.detailCallback = data and data.detailCallback or nil
	self.baseTime = data and data.baseTime or nil
	local gameId = data and data.gameId
	self.bindData.descLabel = gLinkManager:GetPlayModeName(gameId)

	self:OnRefreshSearching()
	self:SetPanelVisible()
end

M.OnPanelVisibleStateChange = function(self, _, panelId)
	if self.CheckIsConflictPanelId(self, panelId) then
		self.SetPanelVisible(self)
	end
end

M.SetPanelVisible = function(self)
	local conflictPanelIdList = self.GetConflictPanelIdList(self)
	local isConflict = false

	for _, conflictPanelId in ipairs(conflictPanelIdList) do
		if gPanelManager:IsPanelVisible(conflictPanelId) then
			isConflict = true

			break
		end
	end

	gPanelManager:SetActiveById(self.m_Id, not isConflict)
end

M.CheckIsConflictPanelId = function(self, panelId)
	local conflictPanelIdList = self.GetConflictPanelIdList(self)

	return table.find(conflictPanelIdList, panelId)
end

M.GetConflictPanelIdList = function(self)
	return {
		gPanelId.ROBBERY_BOARD_SI_BAI_KE_HOTEL_PANEL,
		gPanelId.ANANTARKOV_MAIN_PANEL
	}
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnRefreshSearching = function(self)
	local baseTime = self.baseTime or gLinkManager.baseTime
	self.bindData.timeLabel = baseTime == 0 and gTimeUtils:FormatTime(Time.unscaledTime - baseTime) or ""
	self.bindData.isFold = BOOL2CTL[gClientUtils.CheckMainPhoneIsShowing()]
end
