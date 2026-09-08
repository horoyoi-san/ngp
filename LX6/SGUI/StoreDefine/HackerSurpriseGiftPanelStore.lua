-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerSurpriseGiftPanelStore.lua
-- Decompiled from: 02013_HackerSurpriseGiftPanelStore.lua_75e95f9b1426.luajit

C_HackerSurpriseGiftPanelStore = DefClass("C_HackerSurpriseGiftPanelStore", C_HackerSurpriseGiftPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.HackerSurpriseGiftPanelStore = C_HackerSurpriseGiftPanelStore
local M = C_HackerSurpriseGiftPanelStore

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
	self.bindData.rotateButton.luaClick = self.CreateAction(self, self.OnClickRotateButton)
	self.bindData.releaseButton.luaClick = self.CreateAction(self, self.OnClickReleaseButton)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.OnClickRotateButton = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_HACKER_SURPRISE_GIFT_ROTATE)
end

M.OnClickReleaseButton = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_HACKER_SURPRISE_GIFT_RELEASE)
end
