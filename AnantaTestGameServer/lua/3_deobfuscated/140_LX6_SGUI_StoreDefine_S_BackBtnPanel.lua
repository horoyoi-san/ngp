C_S_BackBtnPanel = DefClass("C_S_BackBtnPanel", C_S_BackBtnPanel, C_StoreGroup)
GroupName2Class.S_BackBtnPanel = C_S_BackBtnPanel
local M = C_S_BackBtnPanel

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.bindData.exitNode:SetActive(false)
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

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ON_ROBBERY_INTERACT_STATE_CHANGE] = self:CreateAction("OnInteractStateChange"),
		[gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE] = self:CreateAction("OnExitStateChange")
	}
end

function M:RegisterWidget()
	self.bindData.exitButton.luaClick = self:CreateAction("OnClickExitButton")
end

function M:OnInteractStateChange(_, forbidInteract)
	self.bindData.exitNode:SetActive(not forbidInteract)
end

function M:OnExitStateChange(_, showExitButton)
	self.bindData.exitButton:SetActive(showExitButton)
end

function M:OnClickExitButton()
	gMessageManager:SendMessage(gEventConstants.ON_ROBBERY_BOARD_EXIT_INTERACTION)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end
