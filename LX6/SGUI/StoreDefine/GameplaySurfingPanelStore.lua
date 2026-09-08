-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GameplaySurfingPanelStore.lua
-- Decompiled from: 01748_GameplaySurfingPanelStore.lua_836329946eb6.luajit

C_GameplaySurfingPanelStore = DefClass("C_GameplaySurfingPanelStore", C_GameplaySurfingPanelStore, C_StoreGroup)
GroupName2Class.GameplaySurfingPanelStore = C_GameplaySurfingPanelStore
local M = C_GameplaySurfingPanelStore

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
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.waveBtn.luaClick = self.CreateAction(self, self.OnClickWave)
end

M.OnClickWave = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.CXQ4_SurfGreetPress)
end
