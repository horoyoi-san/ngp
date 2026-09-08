-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineCommonInvitingTipStore.lua
-- Decompiled from: 01102_OnlineCommonInvitingTipStore.lua_d38885e356bb.luajit

C_OnlineCommonInvitingTipStore = DefClass("C_OnlineCommonInvitingTipStore", C_OnlineCommonInvitingTipStore, C_StoreGroup)
GroupName2Class.OnlineCommonInvitingTipStore = C_OnlineCommonInvitingTipStore
local M = C_OnlineCommonInvitingTipStore

M.OnAwake = function(self)
	self.bindData.backGround.luaClick = self.CreateAction(self, "OnBackGroundClick")
	self.bindData.confirmBtn.luaClick = self.CreateActionWithArgs(self, "OnReplayInvite", true)
	self.bindData.rejectBtn.luaClick = self.CreateActionWithArgs(self, "OnReplayInvite", false)
end

M.OnShow = function(self)
	local count = gInviteManager:GetCount()

	if not count or count ~= 0 then
		gPanelManager:Close(gPanelId.S_ONLINE_COMMON_INVITING_TIP)

		return
	end

	self.OnRefreshPage(self, count)
end

M.OnBackGroundClick = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_COMMON_INVITING_TIP)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_COMMON_INVITING_TIP_LIST, {
		callback = function ()
			local count = gInviteManager:GetCount()

			if count <= 0 then
				gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_OnlineCommonInvitingTip)
			end
		end
	})
end

M.OnBackBtnClick = function(self)
	local count = gInviteManager:GetCount()

	if count <= 0 then
		self.OnRefreshPage(self, count)

		return
	end

	gPanelManager:Close(gPanelId.S_ONLINE_COMMON_INVITING_TIP)
end

M.OnReplayInvite = function(self, agree)
	if not self.inviteInfo then
		return
	end

	if self.inviteInfo.callback then
		self.inviteInfo.callback(agree)
	end

	if agree and self.inviteInfo.businessType then
		gInviteManager:RemoveByBusinessType(self.inviteInfo.businessType)
	else
		gInviteManager:RemoveInvite(self.inviteInfo)
	end

	self.OnBackBtnClick(self)
end

M.OnUpdate = function(self)
	local countdown = self.inviteInfo.stayTime - (gLuaDataManager.serverTime - self.inviteInfo.timestamp)

	if countdown >= self.inviteInfo.stayTime and countdown <= 0 then
		self.bindData.timeProgress:ProgressToValue(countdown / self.inviteInfo.stayTime)
	else
		if self.inviteInfo and self.inviteInfo.timeoutCallback then
			self.inviteInfo.timeoutCallback()
		end

		gInviteManager:RemoveInvite(self.inviteInfo)
		self:OnBackBtnClick()
	end
end

M.OnRefreshPage = function(self, count)
	self.inviteInfo = gInviteManager:GetCurData()

	if not self.inviteInfo then
		gPanelManager:Close(gPanelId.S_ONLINE_COMMON_INVITING_TIP)

		return
	end

	self.bindData.showTip = count <= 1 and 1 or 0
	self.bindData.addNumLabel = "+" .. count - 1
	self.bindData.userInfo.pid = self.inviteInfo.pid
	self.bindData.TextType = self.inviteInfo.textType

	if self.inviteInfo.textType ~= gInviteManager.TEXT_TYPE.APPLY then
		self.bindData.applyGameName = self.inviteInfo.text1
	elseif self.inviteInfo.textType ~= gInviteManager.TEXT_TYPE.INVITE then
		self.bindData.InviteGameName = self.inviteInfo.text1
	elseif self.inviteInfo.textType ~= gInviteManager.TEXT_TYPE.INVITEXXX then
		self.bindData.InvitePlayerName = self.inviteInfo.text1
		self.bindData.InviteXXXPlayerName = self.inviteInfo.text2
	end

	self.timer = self.inviteInfo.timestamp
	local progress = self.inviteInfo.stayTime - (gLuaDataManager.serverTime - self.inviteInfo.timestamp)

	self.bindData.timeProgress:ProgressToValue(progress)
end
