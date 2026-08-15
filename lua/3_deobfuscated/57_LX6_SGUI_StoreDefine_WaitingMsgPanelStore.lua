local MessageConfig = LTConfig.MessageConfig
C_WaitingMsgPanelStore = DefClass("C_WaitingMsgPanelStore", C_WaitingMsgPanelStore, C_StoreGroup)
GroupName2Class.WaitingMsgPanelStore = C_WaitingMsgPanelStore
local M = C_WaitingMsgPanelStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.SHOW_WAITING_PANEL] = self:CreateAction("_OnShow"),
		[gEventConstants.HIDE_WAITING_PANEL] = self:CreateAction("_OnHide")
	}
end

local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:OnAwake()
	self.defaultContent = MessageConfig.GetConfig(MessageConfig.Waiting_Tip).Content

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:_OnShow(_, msg)
	self.bindData.contentLabel = msg and msg or self.defaultContent

	LX6.Manager.GameInputManager.SetDisableInput(gBanId.WAIT_MESSAGE, true, true, true)

	self.bindData.isHide = BOOL2CTL[false]
end

function M:_OnHide()
	LX6.Manager.GameInputManager.SetEnableInput(gBanId.WAIT_MESSAGE, true, true, true)

	self.bindData.isHide = BOOL2CTL[true]
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
