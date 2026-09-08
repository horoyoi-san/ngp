-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobBankDrillShelfPanelStore.lua
-- Decompiled from: 00920_RobBankDrillShelfPanelStore.lua_9f958f8b5207.luajit

C_RobBankDrillShelfPanelStore = DefClass("C_RobBankDrillShelfPanelStore", C_RobBankDrillShelfPanelStore, C_StoreGroup)
GroupName2Class.RobBankDrillShelfPanelStore = C_RobBankDrillShelfPanelStore
local M = C_RobBankDrillShelfPanelStore

M.ctor = function(self)
	self.isOnceDrillShelfFinished = false
	self.drillShelfState = {
		[":A\\x9f\\x87\\x90I"] = 2,
		["S&q^"] = 0,
		["~\\xba\\xa3\\xbd\\xa2"] = 1
	}
	self.robBandDrillShelf = 2
	self.drillShelfCommonInteract = 85
	self.msgEvents = {
		[gEventConstants.ROB_BANK_DRILL_SHELF_BEGIN] = self.CreateAction(self, self.RobBankDrillShelfBegin)
	}
	self.pressTime = 0
	self.finishAnimName = "S_Vx_TimelineClickTimeScalePanel_Finish"
	self.maxPressTime = LTConfig.PoiGameConfig.DrillShelfTime
	self.beginPress = false
end

M.OnAwake = function(self)
	self.bindData.clickBtn.luaPress = self.CreateAction(self, self.OnClickBtnPress)
	self.bindData.clickBtn.luaRelease = self.CreateAction(self, self.OnClickBtnRelease)
	self.bindData.quitBtn.luaClick = self.CreateAction(self, self.OnClickQuitBtnClick)
	self.bindData.btnStore.luaPress = self.CreateAction(self, self.OnClickBtnPress)
	self.bindData.btnStore.luaRelease = self.CreateAction(self, self.OnClickBtnRelease)
end

M.OnShow = function(self, panelId, data)
	self.isOnceDrillShelfFinished = false
	self.btnStore = self:GetBtnStore(self.bindData.btnStore)

	self.bindData.btnStore.gameObject:SetActive(false)

	self.btnStore.progressImage.fillAmount = 0
	self.registerOperationId = gStoreButtonMgr:RegisterOperation({
		["\\xca\\xcf\t\r\\xf5"] = 5,
		["O\\xba\\xac\\x86\\xb2"] = 0,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 1,
		groupId = LTConfig.HudDescGroupConfig.HACKERCAMERA
	})
end

M.OnClose = function(self)
	self.isOnceDrillShelfFinished = false

	gStoreButtonMgr:UnRegisterOperation(self.registerOperationId)
end

M.OnUpdate = function(self)
	if gLuaDataManager.isLoadingPanelOn then
		self.CloseDrillPanel(self)

		return
	end

	self.btnStore.progressImage.fillAmount = Mathf.Clamp(self.pressTime / self.maxPressTime, 0, 1)

	if not self.beginPress then
		return
	end

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillShelfState.Start)

	self.pressTime = self.pressTime + gLogicTime.deltaTime

	if self.maxPressTime < self.pressTime then
		self.FinishOneDrillShelf(self)
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.FinishOneDrillShelf = function(self)
	if not self.beginRobBank then
		return
	end

	self.pressTime = 0
	self.isOnceDrillShelfFinished = true
	self.beginRobBank = false
	self.beginPress = false

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillShelfState.Finish)
	L50.L50App.Scene.DrillShelfGameplayManager:DrillShelfBeginPick()
	gCS.LuaUtils.GetAnimationTime(self.btnStore.animation, self.finishAnimName)
	gCS.LuaUtils.PlayAnimationByName(self.btnStore.animation, self.finishAnimName)
end

M.OnClickBtnPress = function(self)
	if not self.beginRobBank then
		return
	end

	self.beginPress = true
	self.isOnceDrillShelfFinished = false
end

M.OnClickBtnRelease = function(self)
	if not self.beginRobBank then
		return
	end

	self.pressTime = 0
	self.beginPress = false

	if not self.isOnceDrillShelfFinished then
		gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillShelfState.Idle)
	end
end

M.RobBankDrillShelfBegin = function(self)
	self.beginRobBank = true

	self.bindData.btnStore.gameObject:SetActive(true)
	gCS.LuaUtils.SetAnimProcess(self.btnStore.animation, self.finishAnimName, 0)
	gCS.LuaUtils.SampleTargetAnimation(self.btnStore.animation, self.finishAnimName, 0)
end

M.OnClickQuitBtnClick = function(self)
	if not self.beginRobBank then
		return
	end

	self.CloseDrillPanel(self)
end

M.CloseDrillPanel = function(self)
	self.beginPress = false
	self.beginRobBank = false

	gInteractionManager:CommonInteractBreak(self.drillShelfCommonInteract)
	gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StopGameplayByName("RobBankDrillShelf")
	gSpoonClientMgr:ReleaseContextEvent(L50.L50App.Scene.DrillShelfGameplayManager.CurrentGadgetId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.MessageTrigger, {
		message = gEventConstants.ROB_BANK_DRILL_SHELF_CLOSE
	})
end

M.GetBtnStore = function(self, widget)
	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end
