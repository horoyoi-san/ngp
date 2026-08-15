local ProgressConfig = LTConfig.LinkProgressConfig
C_OnlineReadyPanelStore = DefClass("C_OnlineReadyPanelStore", C_OnlineReadyPanelStore, C_StoreGroup)
GroupName2Class.OnlineReadyPanelStore = C_OnlineReadyPanelStore
local M = C_OnlineReadyPanelStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self:CreateAction(self.OnMemberInfoChange)
	}
	self.groupId = ProgressConfig.fullConfirm
	self.mgr = gLinkManager
end

function M:OnAwake()
	self.bindData.acceptBtn.luaClick = self:CreateAction(self.OnAcceptBtnClick)
	self.bindData.rejectBtn.luaClick = self:CreateAction(self.OnRejectBtnClick)
	self.bindData.memberList.luaSimpleRenderItem = self:CreateAction(self.OnMemberRenderItem)

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnMemberRenderItem(btn, index)
	local data = self.mgr.matchMemberList[index + 1]

	self.mgr:OnMemberRenderItem(btn, index, data)
end

function M:OnMemberInfoChange()
	if self.mgr:CheckPlayerIsReady() then
		self.bindData.acceptBtn.interactable = false
		self.bindData.rejectBtn.interactable = false
	end

	self.bindData.memberList:RefreshLogicList()
end

function M:OnAcceptBtnClick()
	self.mgr.progressMgr:OnProgressConfirm(self.groupId)
end

function M:OnRejectBtnClick()
	self.mgr.progressMgr:OnProgressCancel(self.groupId)
end

function M:OnShow(panelId, data)
	self.bindData.memberList:SetSimpleList(#self.mgr.matchMemberList)
	self.mgr.progressMgr:OnRenderProgress(self.groupId, self, self.bindData.countDown)
end

function M:OnClose()
	self:ClearMessageEvents()
	self.mgr.progressMgr:ClearProgress(self.groupId)
end
