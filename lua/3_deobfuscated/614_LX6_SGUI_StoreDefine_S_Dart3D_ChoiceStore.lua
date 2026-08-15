C_S_Dart3D_ChoiceStore = DefClass("C_S_Dart3D_ChoiceStore", C_S_Dart3D_ChoiceStore, C_StoreGroup)
GroupName2Class.S_Dart3D_ChoiceStore = C_S_Dart3D_ChoiceStore
local M = C_S_Dart3D_ChoiceStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.BtnMode01.luaClick = self:CreateAction("OnBtnMode01")
	self.bindData.BtnModeHighScore.luaClick = self:CreateAction("OnBtnModeHighScore")
	self.bindData.BtnInfo.luaClick = self:CreateAction("OnBtnInfo")
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
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoConfirmAISetting()
	end
end

function M:OnClose()
	return
end

function M:OnBtnMode01(btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_ModeStorePanel)
end

function M:OnBtnModeHighScore(btn, itemData)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(1)
end

function M:OnBtnInfo(btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_InfoStorePanel, gPanelId.S_Dart3D_ChoiceStorePanel)
end
