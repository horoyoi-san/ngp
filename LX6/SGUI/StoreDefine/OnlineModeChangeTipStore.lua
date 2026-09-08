-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineModeChangeTipStore.lua
-- Decompiled from: 01130_OnlineModeChangeTipStore.lua_cc7ba3eddee4.luajit

C_OnlineModeChangeTipStore = DefClass("C_OnlineModeChangeTipStore", C_OnlineModeChangeTipStore, C_StoreGroup)
GroupName2Class.OnlineModeChangeTipStore = C_OnlineModeChangeTipStore
local M = C_OnlineModeChangeTipStore

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
	if data.name then
		self.bindData.name = data.name
	end

	if data.desc then
		self.bindData.des = data.desc
	end

	local delay = data.delay or 3
	self.timer = Timer.New(function ()
		gPanelManager:Close(self.m_Id)
	end, delay):Start()
end

M.OnClose = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
