-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\KeSiControllerStore.lua
-- Decompiled from: 01772_KeSiControllerStore.lua_ab20c127018e.luajit

C_KeSiControllerStore = DefClass("C_KeSiControllerStore", C_KeSiControllerStore, C_StoreGroup)
GroupName2Class.KeSiControllerStore = C_KeSiControllerStore
local M = C_KeSiControllerStore

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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self.CreateAction(self, "OnKeSiChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnTabRectRender = function(self, index, widget)
	self.curKeSiStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curKeSiStore then
		self.curKeSiStore:OnShow(nil, self.data)
	end
end

M.OnKeSiChange = function(self, eventId, isKeSiMode)
	if not self.STATE_EnableOnce then
		return
	end

	if self.curKeSiStore then
		self.curKeSiStore:OnClose()

		self.curKeSiStore = nil
	end

	if gCS.MyPlayerManager.PlayerUnit.ClientData.cardId == 15022030 then
		self.bindData.tabRect.selectedIndex = -1

		return
	end

	self.bindData.tabRect.selectedIndex = isKeSiMode and 0 or -1
end
