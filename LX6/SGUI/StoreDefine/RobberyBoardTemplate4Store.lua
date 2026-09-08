-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobberyBoardTemplate4Store.lua
-- Decompiled from: 00915_RobberyBoardTemplate4Store.lua_890b3410dcec.luajit

C_RobberyBoardTemplate4Store = DefClass("C_RobberyBoardTemplate4Store", C_RobberyBoardTemplate4Store, C_StoreGroup)
GroupName2Class.RobberyBoardTemplate4Store = C_RobberyBoardTemplate4Store
local M = C_RobberyBoardTemplate4Store

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
	self.bindData.leftButton.luaClick = self.CreateAction(self, "OnClickLeftButton")
	self.bindData.rightButton.luaClick = self.CreateAction(self, "OnClickRightButton")
end

M.OnClickLeftButton = function(self)
end

M.OnClickRightButton = function(self)
end
