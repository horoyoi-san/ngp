-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceTrialSelectPanelStore.lua
-- Decompiled from: 02051_PoliceTrialSelectPanelStore.lua_221929c4a7ae.luajit

C_PoliceTrialSelectPanelStore = DefClass("C_PoliceTrialSelectPanelStore", C_PoliceTrialSelectPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceTrialSelectPanelStore = C_PoliceTrialSelectPanelStore
local M = C_PoliceTrialSelectPanelStore

M.ctor = function(self)
	self.mgr = gPoliceJobManager.panelMgr
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.InitData(self, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.InitView = function(self, data)
	self.InitData(self, data)
end

M.OnExecuteExitAction = function(self)
	self.mgr:CloseCurrentPanel()
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnClickExitBtn")
	self.bindData.rpsBtn.luaClick = self.CreateAction(self, "OnClickRpsBtn")
	self.bindData.aiBtn.luaClick = self.CreateAction(self, "OnClickAiBtn")
end

M.OnClickExitBtn = function(self)
	self.OnExitClick(self)
end

M.OnClickRpsBtn = function(self)
	gPoliceJobManager.panelMgr:StartTrialGameplay(self.caseId, true)
end

M.OnClickAiBtn = function(self)
	gPoliceJobManager.panelMgr:StartTrialGameplay(self.caseId, false)
end

M.InitData = function(self, data)
	self.fromApp = data and data.fromApp
	self.caseId = data and data.caseId

	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
end
