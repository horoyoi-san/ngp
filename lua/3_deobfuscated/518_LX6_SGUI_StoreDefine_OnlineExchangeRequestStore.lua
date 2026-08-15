C_OnlineExchangeRequestStore = DefClass("C_OnlineExchangeRequestStore", C_OnlineExchangeRequestStore, C_StoreGroup)
GroupName2Class.OnlineExchangeRequestStore = C_OnlineExchangeRequestStore
local M = C_OnlineExchangeRequestStore

function M:ctor()
	self.currentRequest = {}
end

function M:OnAwake()
	self.bindData.cancelBtn.luaClick = self:CreateActionWithArgs("OnReplyRequest", false)
	self.bindData.confirmBtn.luaClick = self:CreateActionWithArgs("OnReplyRequest", true)
end

function M:OnReplyRequest(isAgree)
	gLinkManager:AskReplyDutySwap(self.currentRequest.SourcePid, isAgree, function ()
		self:OnExit()
	end)
end

function M:OnExit()
	self.currentRequest = gLinkManager:GetRequestDuty()

	if not self.currentRequest then
		gPanelManager:Close(gPanelId.ONLINE_EXCHANGE_REQUEST)

		return
	end

	self:RefreshPage()
end

function M:OnShow(panelId, data)
	self.playOneStore = self:GetStoreByWidget(self.bindData.player1Widget)
	self.playTwoStore = self:GetStoreByWidget(self.bindData.player2Widget)

	self:OnExit()
end

function M:OnClose()
	return
end

function M:RefreshPage()
	self:RefreshStoreByPid(self.playOneStore, self.currentRequest.SourcePid, self.currentRequest.SourceDuty)
	self:RefreshStoreByPid(self.playTwoStore, self.currentRequest.TargetPid, self.currentRequest.TargetDuty)
end

function M:RefreshStoreByPid(store, pid, dutyId)
	if not store then
		return
	end

	local memeberInfo = gLinkManager:GetRequestMemberInfo(pid, dutyId)

	if not memeberInfo then
		return
	end

	store.userInfo.pid = memeberInfo.pid
	store.indexLabel = memeberInfo.index
	store.resNameLabel = memeberInfo.dutyName
	store.resIconId = memeberInfo.dutyIcon
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
