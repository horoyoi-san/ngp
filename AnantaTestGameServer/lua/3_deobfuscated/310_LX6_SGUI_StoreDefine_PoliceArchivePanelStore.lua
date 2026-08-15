local RedDotMgr = SGUI.RedDotMgr
C_PoliceArchivePanelStore = DefClass("C_PoliceArchivePanelStore", C_PoliceArchivePanelStore, C_StoreGroup)
GroupName2Class.PoliceArchivePanelStore = C_PoliceArchivePanelStore
local M = C_PoliceArchivePanelStore
local STATE = {
	TRACE = 2,
	NONE = 3,
	LOCK = 1,
	UNLOCK = 0
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.mgr = gPoliceJobManager.panelMgr
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self:RefreshPage()
end

function M:OnClose()
	self.mgr:RemoveAllUnRead()

	self.normalList = nil
	self.mainFakeList = nil
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.POLICE_NEW_FAKE_FILE] = self:CreateAction(self.RefreshPage)
	}
end

function M:RegisterWidget()
	self.bindData.mainList.luaSimpleRenderItem = self:CreateAction(self.OnRenderMainListItem)
	self.bindData.normalList.luaSimpleRenderItem = self:CreateAction(self.OnRenderNormalListItem)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnBackBtnClick)
end

function M:OnRenderMainListItem(btn, index)
	local data = self.mainFakeList[index + 1]

	if not data then
		return
	end

	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local info = self.mgr:GetMainFakeInfo(data.id)
	local curInfo = self.mgr:GetCurrentFakeFileInfo()
	store.numLabel = data.id
	store.state = info.isSubmit and STATE.UNLOCK or STATE.LOCK
	store.searchBtn.interactable = info.isUnlock and curInfo.CurFakeFileId == data.id

	if info.isUnlock then
		store.state = STATE.TRACE
	end

	if curInfo.CurFakeFileId < data.id then
		store.state = STATE.NONE
	end

	if store.state ~= STATE.UNLOCK then
		store.progress.maxValue = info.maxProgress
		store.progress.value = curInfo and curInfo.ClueValue or 0
	else
		store.descLabel = info.desc

		self:_RenderAgentInfo(info.agentId, store)
	end

	store.searchBtn.luaClick = self:CreateActionWithArgs("AskPoliceFakeFileAcceptEvent", data.id, self.mgr)
end

function M:OnRenderNormalListItem(btn, index)
	local data = self.normalList[index + 1]

	if not data then
		return
	end

	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local info = self.mgr:GetNormalFakeInfo(data.id)

	self:_RenderAgentInfo(info.agentId, store)

	store.clue = info.isImport and 1 or 0

	RedDotMgr.LuaSetRedDot(not info.isRead, "PoliceArchivePanelStore.NormalList:" .. data.id)
end

function M:_RenderAgentInfo(agentId, store)
	local agentInfo = self.mgr:GetAgentInfo(agentId)

	if table.isNilOrEmpty(agentInfo) then
		return
	end

	store.nameLabel = agentInfo.name
	store.headIcon = agentInfo.icon
end

function M:OnBackBtnClick()
	gPanelManager:Close(self.m_Id)
end

function M:RefreshPage()
	self.mainFakeList = self.mgr:GetMainFakeList()

	self.bindData.mainList:SetSimpleList(#self.mainFakeList)

	self.normalList = self.mgr:GetNormalFakeList()
	self.bindData.isEmpty = BOOL2CTL[table.isNilOrEmpty(self.normalList)]

	self.bindData.normalList:SetSimpleList(#self.normalList)
end
