-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_BackBtnPanel.lua
-- Decompiled from: 01384_S_BackBtnPanel.lua_a3210c372ae3.luajit

C_S_BackBtnPanel = DefClass("C_S_BackBtnPanel", C_S_BackBtnPanel, C_StoreGroup)
GroupName2Class.S_BackBtnPanel = C_S_BackBtnPanel
local M = C_S_BackBtnPanel

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
	self.RegisterMessageEvents(self, self.msgEvents)
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
	self.bindData.exitNode:SetActive(false)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_ROBBERY_INTERACT_STATE_CHANGE] = self.CreateAction(self, "OnInteractStateChange"),
		[gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE] = self.CreateAction(self, "OnExitStateChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnClickExitButton")
end

M.OnInteractStateChange = function(self, _, forbidInteract)
	self.bindData.exitNode:SetActive(not forbidInteract)
end

M.OnExitStateChange = function(self, _, showExitButton)
	self.bindData.exitButton:SetActive(showExitButton)
end

M.OnClickExitButton = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_ROBBERY_BOARD_EXIT_INTERACTION)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end
