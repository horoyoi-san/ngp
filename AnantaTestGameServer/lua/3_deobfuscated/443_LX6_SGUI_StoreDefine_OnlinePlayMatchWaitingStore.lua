C_OnlinePlayMatchWaitingStore = DefClass("C_OnlinePlayMatchWaitingStore", C_OnlinePlayMatchWaitingStore, C_StoreGroup)
GroupName2Class.OnlinePlayMatchWaitingStore = C_OnlinePlayMatchWaitingStore
local M = C_OnlinePlayMatchWaitingStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.msgEvents = {
		[gEventConstants.LINK_SEARCHING_REFRESH] = self:CreateAction(self.OnRefreshSearching)
	}
end

function M:OnAwake()
	self.bindData.cancelBtn.luaClick = self:CreateAction("OnCancelBtnClick")
	self.bindData.detailBtn.luaClick = self:CreateAction("OnDetailBtnClick")
end

function M:OnEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnDisable()
	self:ClearMessageEvents()
end

function M:OnCancelBtnClick()
	gLinkManager:AskMatchCancel(self:CreateAction("CloseSelf"))
end

function M:OnDetailBtnClick()
	self:CloseSelf()
	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL)
end

function M:CloseSelf()
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL)
end

function M:OnShow(panelId, data)
	self:OnRefreshSearching()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnRefreshSearching()
	self.bindData.timeLabel = gLinkManager.baseTime ~= 0 and gTimeUtils:FormatTime(Time.unscaledTime - gLinkManager.baseTime) or ""
	self.bindData.isFold = BOOL2CTL[gClientUtils.CheckMainPhoneIsShowing()]
end
