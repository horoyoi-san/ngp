-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LoginAgeWarnPanelStore.lua
-- Decompiled from: 01787_LoginAgeWarnPanelStore.lua_9d67e01ee3ee.luajit

local MessageExplainConfig = LTConfig.MessageExplainConfig
C_LoginAgeWarnPanelStore = DefClass("C_LoginAgeWarnPanelStore", C_LoginAgeWarnPanelStore, C_StoreGroup)
GroupName2Class.LoginAgeWarnPanelStore = C_LoginAgeWarnPanelStore
local M = C_LoginAgeWarnPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(gPanelId.AGE_WARN_PANEL)
end

M.OnShow = function(self, panelId, data)
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

M.OnClose = function(self)
	if self.callback then
		self.callback()
	end
end
