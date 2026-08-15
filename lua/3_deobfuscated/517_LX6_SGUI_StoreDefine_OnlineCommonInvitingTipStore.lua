C_OnlineCommonInvitingTipStore = DefClass("C_OnlineCommonInvitingTipStore", C_OnlineCommonInvitingTipStore, C_StoreGroup)
GroupName2Class.OnlineCommonInvitingTipStore = C_OnlineCommonInvitingTipStore
local M = C_OnlineCommonInvitingTipStore

function M:OnAwake()
	self.bindData.backGround.luaClick = self:CreateAction("OnBackGroundClick")
	self.bindData.confirmBtn.luaClick = self:CreateActionWithArgs("OnReplayInvite", true)
	self.bindData.rejectBtn.luaClick = self:CreateActionWithArgs("OnReplayInvite", false)
end

function M:OnShow()
	local count = gInviteManager:GetCount()

	self:OnRefreshPage(count)
end

function M:OnBackGroundClick()
	gPanelManager:Close(gPanelId.S_ONLINE_COMMON_INVITING_TIP)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_COMMON_INVITING_TIP_LIST, {
		callback = function ()
			local count = gInviteManager:GetCount()

			if count > 0 then
				gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_OnlineCommonInvitingTip)
			end
		end
	})
end

function M:OnBackBtnClick()
	local count = gInviteManager:GetCount()

	if count > 0 then
		self:OnRefreshPage(count)

		return
	end

	gPanelManager:Close(gPanelId.S_ONLINE_COMMON_INVITING_TIP)
end

function M:OnReplayInvite(agree)
	if not self.inviteInfo then
		return
	end

	if self.inviteInfo.callback then
		self.inviteInfo.callback(agree)
	end

	gInviteManager:RemoveInvite(self.inviteInfo)
	self:OnBackBtnClick()
end

function M:OnUpdate()
	local countdown = self.inviteInfo.stayTime - (gLuaDataManager.serverTime - self.inviteInfo.timestamp)

	if countdown < self.inviteInfo.stayTime and countdown > 0 then
		self.bindData.timeProgress:ProgressToValue(countdown / self.inviteInfo.stayTime)
	else
		self:OnBackBtnClick()
	end
end

function M:OnRefreshPage(count)
	self.inviteInfo = gInviteManager:GetCurData()
	self.bindData.showTip = count > 0 and 1 or 0
	self.bindData.addNumLabel = "+" .. count
	self.bindData.userInfo.pid = self.inviteInfo.pid
	self.bindData.TextType = self.inviteInfo.textType

	if self.inviteInfo.textType == gInviteManager.TEXT_TYPE.APPLY then
		self.bindData.applyGameName = self.inviteInfo.text1
	elseif self.inviteInfo.textType == gInviteManager.TEXT_TYPE.INVITE then
		self.bindData.InviteGameName = self.inviteInfo.text1
	elseif self.inviteInfo.textType == gInviteManager.TEXT_TYPE.INVITEXXX then
		self.bindData.InvitePlayerName = self.inviteInfo.text1
		self.bindData.InviteXXXPlayerName = self.inviteInfo.text2
	end

	self.timer = self.inviteInfo.timestamp
	local progress = self.inviteInfo.stayTime - (gLuaDataManager.serverTime - self.inviteInfo.timestamp)

	self.bindData.timeProgress:ProgressToValue(progress)
end
