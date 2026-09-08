-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobberyBoardTimeLineTask1.lua
-- Decompiled from: 00913_RobberyBoardTimeLineTask1.lua_3fb4ff70e0fe.luajit

C_RobberyBoardTimeLineTask1 = DefClass("C_RobberyBoardTimeLineTask1", C_RobberyBoardTimeLineTask1, C_StoreGroup)
GroupName2Class.RobberyBoardTimeLineTask1 = C_RobberyBoardTimeLineTask1
local M = C_RobberyBoardTimeLineTask1

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

M.OnShow = function(self, _, args)
	local uiPivot = args.uiPivot

	if gClientUtils.IsNil(uiPivot) then
		return
	end

	self.rootGo.transform:ChangeLayersRecursively(Layer.Default)

	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
