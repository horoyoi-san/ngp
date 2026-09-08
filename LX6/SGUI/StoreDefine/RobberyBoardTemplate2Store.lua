-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobberyBoardTemplate2Store.lua
-- Decompiled from: 00917_RobberyBoardTemplate2Store.lua_7d86d29928dc.luajit

C_RobberyBoardTemplate2Store = DefClass("C_RobberyBoardTemplate2Store", C_RobberyBoardTemplate2Store, C_StoreGroup)
GroupName2Class.RobberyBoardTemplate2Store = C_RobberyBoardTemplate2Store
local M = C_RobberyBoardTemplate2Store

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
	self.bindData.optionList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderOptionListItem")
	self.bindData.optionList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickOptionList")
end

M.OnSimpleRenderOptionListItem = function(self, btn, index)
end

M.OnSimpleClickOptionList = function(self, btn, index)
end
