-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonTabSingleStore_Sub.lua
-- Decompiled from: 01540_CommonTabSingleStore_Sub.lua_b2bdacebd255.luajit

C_CommonTabSingleStore_Sub = DefClass("C_CommonTabSingleStore_Sub", C_CommonTabSingleStore_Sub, C_StoreGroup)
GroupName2Class.CommonTabSingleStore_Sub = C_CommonTabSingleStore_Sub
local M = C_CommonTabSingleStore_Sub

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
	self.bindData.leftBtn.luaClick = self.CreateAction(self, self.OnClickLeftBtn)
	self.bindData.rightBtn.luaClick = self.CreateAction(self, self.OnClickRightBtn)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTabList)
end

M.OnClickLeftBtn = function(self)
end

M.OnClickRightBtn = function(self)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end
end

M.OnSimpleClickTabList = function(self, btn, index)
end
