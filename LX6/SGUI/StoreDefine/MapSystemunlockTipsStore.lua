-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MapSystemunlockTipsStore.lua
-- Decompiled from: 00965_MapSystemunlockTipsStore.lua_570fcfb1093c.luajit

C_MapSystemunlockTipsStore = DefClass("C_MapSystemunlockTipsStore", C_MapSystemunlockTipsStore, C_StoreGroup)
GroupName2Class.MapSystemunlockTipsStore = C_MapSystemunlockTipsStore
local M = C_MapSystemunlockTipsStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = {
		["BU~l]\n?"] = 0,
		["I\\x9f\\x9a\\x86E"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = nil
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
	self.bindData.backBtn.luaClick = function()
		gPanelManager:Close(gPanelId.MAP_SYTEMUNLOCK_TIPS)
	end
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.timer = Timer.New(function ()
		self:_OnExit()
	end, 5):Start()
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

M._OnExit = function(self)
	gPanelManager:Close(self.m_Id)

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end
