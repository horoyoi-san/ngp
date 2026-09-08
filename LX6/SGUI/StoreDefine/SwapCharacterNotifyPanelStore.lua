-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SwapCharacterNotifyPanelStore.lua
-- Decompiled from: 01302_SwapCharacterNotifyPanelStore.lua_05d9fa68a7d4.luajit

C_SwapCharacterNotifyPanelStore = DefClass("C_SwapCharacterNotifyPanelStore", C_SwapCharacterNotifyPanelStore, C_StoreGroup)
GroupName2Class.SwapCharacterNotifyPanelStore = C_SwapCharacterNotifyPanelStore
local M = C_SwapCharacterNotifyPanelStore

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
	self.bindData.activeButtonCtrl = 0
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.switchBtn.luaBeginLongPress = function()
	end

	self.bindData.switchBtn.luaEndLongPress = function()
	end
end
