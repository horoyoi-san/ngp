-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineReadyPanelStore.lua
-- Decompiled from: 01059_OnlineReadyPanelStore.lua_244fa5918fe3.luajit

local ProgressConfig = LTConfig.LinkProgressConfig
C_OnlineReadyPanelStore = DefClass("C_OnlineReadyPanelStore", C_OnlineReadyPanelStore, C_StoreGroup)
GroupName2Class.OnlineReadyPanelStore = C_OnlineReadyPanelStore
local M = C_OnlineReadyPanelStore

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.OnMemberInfoChange)
	}
	self.groupId = ProgressConfig.fullConfirm
	self.mgr = gLinkManager
end

M.OnAwake = function(self)
	self.bindData.acceptBtn.luaClick = self.CreateAction(self, self.OnAcceptBtnClick)
	self.bindData.rejectBtn.luaClick = self.CreateAction(self, self.OnRejectBtnClick)
	self.bindData.memberList.luaSimpleRenderItem = self.CreateAction(self, self.OnMemberRenderItem)
	self.bindData.memberList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnMemberRenderItem)

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnMemberRenderItem = function(self, btn, index)
	local data = self.mgr.currentLinkGame.Members[index + 1]

	self.mgr:OnMemberRenderItem(btn, index, data, true, nil, true)
end

M.OnMemberInfoChange = function(self)
	if self.mgr:CheckPlayerIsReady() then
		self.bindData.acceptBtn.interactable = false
		self.bindData.rejectBtn.interactable = false
	end

	self.bindData.memberList:RefreshLogicList()
end

M.OnAcceptBtnClick = function(self)
	self.mgr.progressMgr:OnProgressConfirm(self.groupId, 1)
end

M.OnRejectBtnClick = function(self)
	self.mgr.progressMgr:OnProgressCancel(self.groupId, 1, true)
end

M.OnShow = function(self, panelId, data)
	self.bindData.memberList:SetSimpleList(#self.mgr.currentLinkGame.Members)
	self.mgr.progressMgr:OnRenderProgress(self.groupId, self, self.bindData.countDown)
	LX6.SDK.TaskbarFlash.FlashUntilFocus()
end

M.OnClose = function(self)
	self:ClearMessageEvents()
	self.mgr.progressMgr:ClearProgress(self.groupId)
	LX6.SDK.TaskbarFlash.Stop()
end
