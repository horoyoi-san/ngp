-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonTabSingleStore_Main.lua
-- Decompiled from: 01539_CommonTabSingleStore_Main.lua_2dbd53e657d7.luajit

C_CommonTabSingleStore_Main = DefClass("C_CommonTabSingleStore_Main", C_CommonTabSingleStore_Main, C_StoreGroup)
GroupName2Class.CommonTabSingleStore_Main = C_CommonTabSingleStore_Main
local M = C_CommonTabSingleStore_Main

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.isSingleEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isSingleEnum = nil
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
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTabList)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end
end

M.OnSimpleClickTabList = function(self, btn, index)
end
