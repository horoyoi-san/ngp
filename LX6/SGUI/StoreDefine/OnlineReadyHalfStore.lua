-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineReadyHalfStore.lua
-- Decompiled from: 01073_OnlineReadyHalfStore.lua_3dbb6595a3d5.luajit

local ProgressConfig = LTConfig.LinkProgressConfig
C_OnlineReadyHalfStore = DefClass("C_OnlineReadyHalfStore", C_OnlineReadyHalfStore, C_StoreGroup)
GroupName2Class.OnlineReadyHalfStore = C_OnlineReadyHalfStore
local M = C_OnlineReadyHalfStore

M.ctor = function(self)
	self.mgr = gLinkManager
	self.groupId = ProgressConfig.halfConfirm
end

M.OnAwake = function(self)
	self.bindData.acceptBtn.luaClick = self.CreateAction(self, self.OnAcceptBtnClick)
	self.bindData.rejectBtn.luaClick = self.CreateAction(self, self.OnRejectBtnClick)
	self.bindData.memberList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderPlayerListItem)
	self.memberList = {}
	self.msgEvents = {
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.OnMemberInfoChange),
		[gEventConstants.LINK_VOTE_STATE_CHANGE] = self.CreateAction(self, self.OnVoteStateChange)
	}
end

M.OnShow = function(self, _, data)
	self.groupId = data and data.groupId or ProgressConfig.halfConfirm
	local cfg = ProgressConfig.GetConfig(self.groupId)

	if self.groupId ~= ProgressConfig.halfConfirm then
		self.bindData.memberList:SetSimpleList(#self.mgr.currentLinkGame.Members)
	else
		for k, v in pairs(self.mgr.LinkMemberInfo) do
			table.insert(self.memberList, k)
		end

		self.bindData.memberList:SetSimpleList(#self.memberList)
	end

	self.bindData.descLabel = cfg and cfg.TitleLabel or ""

	self.mgr.progressMgr:OnRenderProgress(self.groupId, self, self.bindData.countDown)
end

M.OnClose = function(self)
	self.mgr.progressMgr:ClearProgress(self.groupId)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnAcceptBtnClick = function(self)
	self.mgr.progressMgr:OnProgressConfirm(self.groupId)
end

M.OnRejectBtnClick = function(self)
	self.mgr.progressMgr:OnProgressCancel(self.groupId)
end

M.OnSimpleRenderPlayerListItem = function(self, btn, index)
	if self.groupId ~= ProgressConfig.halfConfirm then
		local data = self.mgr.currentLinkGame.Members[index + 1]

		self.mgr:OnMemberRenderItem(btn, index, data)
	elseif self.groupId ~= ProgressConfig.InGameVote then
		local pid = self.memberList[index + 1]

		self.mgr:OnRenderVotePlayer(btn, index, pid)
	end
end

M.OnVoteStateChange = function(self)
	if self.groupId == ProgressConfig.InGameVote then
		return
	end

	if self.mgr:CheckSelfIsSurrender() then
		self.bindData.acceptBtn.interactable = false
		self.bindData.rejectBtn.interactable = false
	end

	self.bindData.memberList:RefreshLogicList()
end

M.OnMemberInfoChange = function(self)
	if self.groupId == ProgressConfig.halfConfirm then
		return
	end

	if self.mgr:CheckPlayerIsReady() then
		self.bindData.acceptBtn.interactable = false
		self.bindData.rejectBtn.interactable = false
	end

	self.bindData.memberList:RefreshLogicList()
end
