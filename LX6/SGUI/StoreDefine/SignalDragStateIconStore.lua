-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SignalDragStateIconStore.lua
-- Decompiled from: 01340_SignalDragStateIconStore.lua_352362309b14.luajit

C_SignalDragStateIconStore = DefClass("C_SignalDragStateIconStore", C_SignalDragStateIconStore, C_StoreGroup)
GroupName2Class.SignalDragStateIconStore = C_SignalDragStateIconStore
local M = C_SignalDragStateIconStore

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
	local store = gStoreManager:GetStoreGroup("OnlineSignalCircleFullScreenPanelStore")

	if store then
		self.bindData.icon = store.GetCurDragIconId(store)
	end

	local uiPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRT, store:GetDragStartPosition())

	self.bindData.iconWidget.transform:SetLocalPosition(uiPos)
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
end
