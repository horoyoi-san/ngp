C_S_Dart3D_OpponentStore = DefClass("C_S_Dart3D_OpponentStore", C_S_Dart3D_OpponentStore, C_StoreGroup)
GroupName2Class.S_Dart3D_OpponentStore = C_S_Dart3D_OpponentStore
local M = C_S_Dart3D_OpponentStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.BtnInfo.luaClick = self:CreateAction("OnBtnInfo")
	self.bindData.BtnEasy.luaClick = self:CreateAction("OnBtnEasy")
	self.bindData.BtnNormal.luaClick = self:CreateAction("OnBtnNormal")
	self.bindData.BtnHard.luaClick = self:CreateAction("OnBtnHard")
	self.bindData.BtnMaster.luaClick = self:CreateAction("OnBtnMaster")
end

function M:OnEnable()
	gDartsGameManager:ShowOrHideQuad(false)
end

function M:OnStart()
	return
end

function M:OnDisable()
	gDartsGameManager:ShowOrHideQuad(true)
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

function M:OnBtnInfo(btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_InfoStorePanel, gPanelId.S_Dart3D_OpponentStorePanel)
end

function M:OnBtnEasy()
	self:SetHardLevelAndShowNext(100)
end

function M:OnBtnNormal()
	self:SetHardLevelAndShowNext(101)
end

function M:OnBtnHard()
	self:SetHardLevelAndShowNext(102)
end

function M:OnBtnMaster()
	self:SetHardLevelAndShowNext(103)
end

function M:SetHardLevelAndShowNext(aiConfigId)
	gDartsGameManager:SetAiConfig(aiConfigId)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_ChoiceStorePanel)
end
