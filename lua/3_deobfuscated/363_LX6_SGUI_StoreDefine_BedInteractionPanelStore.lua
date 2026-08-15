C_BedInteractionPanelStore = DefClass("C_BedInteractionPanelStore", C_BedInteractionPanelStore, C_StoreGroup)
GroupName2Class.BedInteractionPanelStore = C_BedInteractionPanelStore
local M = C_BedInteractionPanelStore

function M:ctor()
	return
end

function M:GetParent()
	return gStoreManager:GetStoreGroup("GameplayHudPanelStore")
end

function M:OnAwake()
	self.bindData.sleepBtn.luaClick = self:CreateAction("PlaySleep", gHomeInteractionManager)
	self.bindData.turnOverBtn.luaClick = self:CreateAction("PlayBedTurnOver", gHomeInteractionManager)
	self.bindData.switchSideBtn.luaClick = self:CreateAction("PlayBedSwitchSide", gHomeInteractionManager)
	self.bindData.exerciseBtn.luaClick = self:CreateAction("PlayExercise", gHomeInteractionManager)
	self.bindData.wakeUpBtn.luaClick = self:CreateAction("PlayGetUp", gHomeInteractionManager)
end

function M:OnShow(panelId, data)
	gHomeInteractionManager:RegisterStore(self)

	self.bindData.isBedDouble = gHomeInteractionManager:CheckIsSingleBed() and 0 or 1

	self:RefreshInteraction()
end

function M:RefreshInteraction()
	local inInteraction = gHomeInteractionManager.actionSignals == 0
	self.bindData.isHouseAction = inInteraction and 1 or 0

	self:GetParent():SetBtnBackState(inInteraction)
end

function M:OnClose()
	gHomeInteractionManager:UnRegisterStore()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
