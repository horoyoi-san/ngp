-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InspireInfoPanelStore.lua
-- Decompiled from: 01830_InspireInfoPanelStore.lua_5c6ee4df4c74.luajit

C_InspireInfoPanelStore = DefClass("C_InspireInfoPanelStore", C_InspireInfoPanelStore, C_StoreGroup)
GroupName2Class.InspireInfoPanelStore = C_InspireInfoPanelStore
local M = C_InspireInfoPanelStore

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)

	if self.bindData.exitBtn2 then
		self.bindData.exitBtn2.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	end
end

M.OnShow = function(self, panelId, data)
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

M.OnExitBtnClick = function(self)
	if self.m_Id ~= nil or self.m_Id ~= 0 then
		print_error("这个界面没有 ID", gUtils.GetFindPath(self.rootWidget))

		return
	end

	gPanelManager:Close(self.m_Id)
end
