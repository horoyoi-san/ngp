-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Raiden2FinalPanelStore.lua
-- Decompiled from: 00897_Raiden2FinalPanelStore.lua_5e2b870a0cf2.luajit

C_Raiden2FinalPanelStore = DefClass("C_Raiden2FinalPanelStore", C_Raiden2FinalPanelStore, C_StoreGroup)
GroupName2Class.Raiden2FinalPanelStore = C_Raiden2FinalPanelStore
local M = C_Raiden2FinalPanelStore

M.ctor = function(self)
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
	self.bindData.panelAnimation:Play("S_Vx_Raiden2_FinalPanel_in")
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backButton.luaClick = self.CreateAction(self, self.OnClickBackButton)
end

M.OnClickBackButton = function(self)
	gPanelManager:Close(self.m_Id)
end
