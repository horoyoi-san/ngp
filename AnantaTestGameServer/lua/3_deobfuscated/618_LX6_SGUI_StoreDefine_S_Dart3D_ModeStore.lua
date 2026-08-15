C_S_Dart3D_ModeStore = DefClass("C_S_Dart3D_ModeStore", C_S_Dart3D_ModeStore, C_StoreGroup)
GroupName2Class.S_Dart3D_ModeStore = C_S_Dart3D_ModeStore
local M = C_S_Dart3D_ModeStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.Btn301.luaClick = self:CreateAction("OnBtn301")
	self.bindData.Btn501.luaClick = self:CreateAction("OnBtn501")
	self.bindData.Btn701.luaClick = self:CreateAction("OnBtn701")
	self.bindData.Btn901.luaClick = self:CreateAction("OnBtn901")
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
	return
end

function M:OnClose()
	return
end

function M:OnExitBtn(btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_OpponentStorePanel)
end

function M:OnBtn301(btn)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(2, 301)
end

function M:OnBtn501(btn, itemData)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(2, 501)
end

function M:OnBtn701(btn, itemData)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(2, 701)
end

function M:OnBtn901(btn, itemData)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(2, 901)
end

function M:OnBtnInfo(btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_InfoStorePanel, gPanelId.S_Dart3D_ModeStorePanel)
end
