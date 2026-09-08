-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WaitingMsgPanelStore.lua
-- Decompiled from: 01149_WaitingMsgPanelStore.lua_9fd965810461.luajit

local MessageConfig = LTConfig.MessageConfig
C_WaitingMsgPanelStore = DefClass("C_WaitingMsgPanelStore", C_WaitingMsgPanelStore, C_StoreGroup)
GroupName2Class.WaitingMsgPanelStore = C_WaitingMsgPanelStore
local M = C_WaitingMsgPanelStore

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.SHOW_WAITING_PANEL] = self.CreateAction(self, "_OnShow"),
		[gEventConstants.HIDE_WAITING_PANEL] = self.CreateAction(self, "_OnHide")
	}
end

local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

M.OnAwake = function(self)
	self.defaultContent = MessageConfig.GetConfig(MessageConfig.Waiting_Tip).Content

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M._OnShow = function(self, _, msg)
	self.bindData.contentLabel = msg and msg or self.defaultContent

	LX6.Manager.GameInputManager.SetDisableInput(gBanId.WAIT_MESSAGE, true, true, true)

	self.bindData.isHide = BOOL2CTL[false]
end

M._OnHide = function(self)
	LX6.Manager.GameInputManager.SetEnableInput(gBanId.WAIT_MESSAGE, true, true, true)

	self.bindData.isHide = BOOL2CTL[true]
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnLanguageChange = function(self, lang)
	self.defaultContent = MessageConfig.GetConfig(MessageConfig.Waiting_Tip).Content
	self.bindData.contentLabel = self.defaultContent
end
