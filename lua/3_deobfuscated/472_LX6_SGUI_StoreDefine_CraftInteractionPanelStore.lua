C_CraftInteractionPanelStore = DefClass("C_CraftInteractionPanelStore", C_CraftInteractionPanelStore, C_StoreGroup)
GroupName2Class.CraftInteractionPanelStore = C_CraftInteractionPanelStore
local M = C_CraftInteractionPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnLongPress")
	self.bindData.exitBtn.luaLongPress = self:CreateAction("OnExitBtnLongPress")
end

function M:OnShow(panelId, data)
	return
end

function M:OnExitBtnLongPress()
	gProduceManager:UnRegisterMachine()
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
