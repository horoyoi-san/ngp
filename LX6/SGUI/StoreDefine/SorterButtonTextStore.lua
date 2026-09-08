-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SorterButtonTextStore.lua
-- Decompiled from: 01290_SorterButtonTextStore.lua_1cd1ce39adea.luajit

C_SorterButtonTextStore = DefClass("C_SorterButtonTextStore", C_SorterButtonTextStore, C_StoreGroup)
GroupName2Class.SorterButtonTextStore = C_SorterButtonTextStore
local M = C_SorterButtonTextStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.isAscending = true
	self.onOrderChanged = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.sortCtrlEnum = {
		["BTol@?"] = 0,
		["W_ݾ\\x81\\xbc\r\\xc7\\xef"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.sortCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.RefreshSortCtrl(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.onOrderChanged = nil
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
	self.bindData.leftArrowButton.luaClick = self.CreateAction(self, self.OnClickLeftArrowButton)
	self.bindData.rightArrowButton.luaClick = self.CreateAction(self, self.OnClickRightArrowButton)
end

M.OnClickLeftArrowButton = function(self)
	self.ToggleOrder(self)
end

M.OnClickRightArrowButton = function(self)
	self.ToggleOrder(self)
end

M.ToggleOrder = function(self)
	self.SetAscending(self, not self.isAscending)
end

M.SetAscending = function(self, isAscending)
	self.isAscending = isAscending

	self.RefreshSortCtrl(self)

	if self.onOrderChanged then
		self.onOrderChanged(self.isAscending)
	end
end

M.RefreshSortCtrl = function(self)
	self.bindData.sortCtrl = self.isAscending and self.sortCtrlEnum.ascending or self.sortCtrlEnum.descending
end

M.IsAscending = function(self)
	return self.isAscending
end

M.SetOrderChangedCallback = function(self, callback)
	self.onOrderChanged = callback
end
