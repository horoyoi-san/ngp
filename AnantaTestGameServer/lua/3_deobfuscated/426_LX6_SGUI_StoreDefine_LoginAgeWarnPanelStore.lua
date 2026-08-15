local MessageExplainConfig = LTConfig.MessageExplainConfig
C_LoginAgeWarnPanelStore = DefClass("C_LoginAgeWarnPanelStore", C_LoginAgeWarnPanelStore, C_StoreGroup)
GroupName2Class.LoginAgeWarnPanelStore = C_LoginAgeWarnPanelStore
local M = C_LoginAgeWarnPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
end

function M:OnCloseBtnClick()
	gPanelManager:Close(gPanelId.AGE_WARN_PANEL)
end

function M:OnShow(panelId, data)
	local id = data and data.id or MessageExplainConfig.ShiLingTiXing
	self.callback = data and data.callback
	local cfg = MessageExplainConfig.GetConfig(id)

	if not cfg then
		return
	end

	local str = cfg.Content
	self.bindData.titleLabel = cfg.Title
	local showList = gUIUtils:parseTitlesAndContents(str)

	self.bindData.contentList:InitSimpleList()

	for i = 1, #showList do
		self.bindData.contentList:AddSimpleLabel(0, showList[i].title)
		self.bindData.contentList:AddSimpleLabel(1, showList[i].content)
	end

	self.bindData.contentList:RefreshList()
end

function M:OnClose()
	if self.callback then
		self.callback()
	end
end
