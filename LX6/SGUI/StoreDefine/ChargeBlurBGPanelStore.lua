-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChargeBlurBGPanelStore.lua
-- Decompiled from: 01477_ChargeBlurBGPanelStore.lua_9064c389f399.luajit

C_ChargeBlurBGPanelStore = DefClass("C_ChargeBlurBGPanelStore", C_ChargeBlurBGPanelStore, C_StoreGroup)
GroupName2Class.ChargeBlurBGPanelStore = C_ChargeBlurBGPanelStore
local M = C_ChargeBlurBGPanelStore

M.ctor = function(self)
	self.autoCloseTimer = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearAutoCloseTimer(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
	self.ClearAutoCloseTimer(self)
end

M.StartAutoCloseTimer = function(self)
	self:ClearAutoCloseTimer()

	self.autoCloseTimer = Timer.New(function ()
		self.autoCloseTimer = nil

		gPanelManager:Close(self.m_Id)
	end, 30):Start()
end

M.ClearAutoCloseTimer = function(self)
	if self.autoCloseTimer then
		self.autoCloseTimer:Stop()

		self.autoCloseTimer = nil
	end
end
