-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PopupSystemStore.lua
-- Decompiled from: 00798_PopupSystemStore.lua_22c2b206a9d3.luajit

local SystemUnlockConfig = LTConfig.SystemUnlockConfig
C_PopupSystemStore = DefClass("C_PopupSystemStore", C_PopupSystemStore, C_StoreGroup)
GroupName2Class.PopupSystemStore = C_PopupSystemStore
local M = C_PopupSystemStore

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

M.OnExit = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnShow = function(self, panelId, data)
	local cfg = SystemUnlockConfig.GetConfig(data and data.id or 0)
	self.bindData.systemName = cfg.Description
	self.bindData.PopupPic = data and data.PopupPic
	self.bindData.contentName = data and data.PopupName
	local duration = LTConfig.DropConfig.SpecialDropShowTime
	self.timer = Timer.New(function ()
		self:OnExit()
	end, duration):Start()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
