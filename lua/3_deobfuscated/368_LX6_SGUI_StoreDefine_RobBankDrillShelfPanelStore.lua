C_RobBankDrillShelfPanelStore = DefClass("C_RobBankDrillShelfPanelStore", C_RobBankDrillShelfPanelStore, C_StoreGroup)
GroupName2Class.RobBankDrillShelfPanelStore = C_RobBankDrillShelfPanelStore
local M = C_RobBankDrillShelfPanelStore

function M:ctor()
	self.isOnceDrillShelfFinished = false
	self.drillShelfState = {
		Finish = 2,
		Idle = 0,
		Start = 1
	}
	self.robBandDrillShelf = 2
	self.drillShelfCommonInteract = 85
	self.msgEvents = {
		[gEventConstants.ROB_BANK_DRILL_SHELF_BEGIN] = self:CreateAction(self.RobBankDrillShelfBegin)
	}
	self.pressTime = 0
	self.finishAnimName = "S_Vx_TimelineClickTimeScalePanel_Finish"
	self.maxPressTime = LTConfig.PoiGameConfig.DrillShelfTime
	self.beginPress = false
end

function M:OnAwake()
	self.bindData.clickBtn.luaPress = self:CreateAction(self.OnClickBtnPress)
	self.bindData.clickBtn.luaRelease = self:CreateAction(self.OnClickBtnRelease)
	self.bindData.quitBtn.luaClick = self:CreateAction(self.OnClickQuitBtnClick)
end

function M:OnShow(panelId, data)
	self.isOnceDrillShelfFinished = false
	self.btnStore = self:GetBtnStore(self.bindData.btnStore)
	self.btnStore.progressImage.fillAmount = 0
end

function M:OnClose()
	self.isOnceDrillShelfFinished = false
end

function M:OnUpdate()
	self.btnStore.progressImage.fillAmount = Mathf.Clamp(self.pressTime / self.maxPressTime, 0, 1)

	if not self.beginPress then
		return
	end

	self.pressTime = self.pressTime + gLogicTime.deltaTime

	if self.maxPressTime <= self.pressTime then
		self:FinishOneDrillShelf()
	end
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:FinishOneDrillShelf()
	if not self.beginRobBank then
		return
	end

	self.pressTime = 0
	self.isOnceDrillShelfFinished = true
	self.beginRobBank = false
	self.beginPress = false

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillShelfState.Finish)
	gInteractionManager:DrillShelfBeginPick()
	gCS.LuaUtils.GetAnimationTime(self.btnStore.animation, self.finishAnimName)
	gCS.LuaUtils.PlayAnimationByName(self.btnStore.animation, self.finishAnimName)
end

function M:OnClickBtnPress()
	if not self.beginRobBank then
		return
	end

	self.beginPress = true
	self.isOnceDrillShelfFinished = false

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillShelfState.Start)
end

function M:OnClickBtnRelease()
	if not self.beginRobBank then
		return
	end

	self.pressTime = 0
	self.beginPress = false

	if not self.isOnceDrillShelfFinished then
		gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillShelfState.Idle)
	end
end

function M:RobBankDrillShelfBegin()
	self.beginRobBank = true

	gCS.LuaUtils.SetAnimProcess(self.btnStore.animation, self.finishAnimName, 0)
	gCS.LuaUtils.SampleTargetAnimation(self.btnStore.animation, self.finishAnimName, 0)
end

function M:OnClickQuitBtnClick()
	if not self.beginRobBank then
		return
	end

	gInteractionManager:CommonInteractBreak(self.drillShelfCommonInteract)
	gPanelManager:Close(gPanelId.ROB_BANK_DRILL_SHELF_PANEL)
end

function M:GetBtnStore(widget)
	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end
