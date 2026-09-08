-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceArrestTipsStore.lua
-- Decompiled from: 00784_PoliceArrestTipsStore.lua_a29e97ae6de3.luajit

C_PoliceArrestTipsStore = DefClass("C_PoliceArrestTipsStore", C_PoliceArrestTipsStore, C_StoreGroup)
GroupName2Class.PoliceArrestTipsStore = C_PoliceArrestTipsStore
local M = C_PoliceArrestTipsStore

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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if data ~= gPoliceJobManager.ARREST_NOTIFY_ID.SEARCH then
		self.bindData.stateCtrl = self.stateCtrlEnum.arresting
	elseif data ~= gPoliceJobManager.ARREST_NOTIFY_ID.WANTED then
		self.bindData.stateCtrl = self.stateCtrlEnum.wanted
	end

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
