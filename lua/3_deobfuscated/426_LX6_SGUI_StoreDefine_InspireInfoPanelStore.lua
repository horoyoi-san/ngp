C_InspireInfoPanelStore = DefClass("C_InspireInfoPanelStore", C_InspireInfoPanelStore, C_StoreGroup)
GroupName2Class.InspireInfoPanelStore = C_InspireInfoPanelStore
local M = C_InspireInfoPanelStore

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnExitBtnClick)
	self.bindData.exitBtn2.luaClick = self:CreateAction(self.OnExitBtnClick)
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	local explainCfg = LTConfig.MessageExplainConfig.GetConfig(data.id)
	local showList = gUIUtils:ParseMessageExplain(explainCfg.Content)
	self.bindData.title = explainCfg.Title or ""

	self.bindData.list:InitSimpleList()

	for i = 1, #showList do
		self.bindData.list:AddSimpleLabel(0, showList[i].title)
		self.bindData.list:AddSimpleLabel(1, showList[i].content)
	end

	self.bindData.list:RefreshList()
end

function M:OnExitBtnClick()
	gPanelManager:Close(self.panelId)
end

function M:OnDestroy()
	self.panelId = nil
end
