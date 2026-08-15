C_ChengGanTiaoGamePanelStore = DefClass("C_ChengGanTiaoGamePanelStore", C_ChengGanTiaoGamePanelStore, C_StoreGroup)
GroupName2Class.ChengGanTiaoGamePanelStore = C_ChengGanTiaoGamePanelStore
local M = C_ChengGanTiaoGamePanelStore
local MyPlayerManager = gCS.MyPlayerManager
local LogicStateMachineManager = gCS.LogicStateMachineManager
local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig

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
	self.closeTime = 0
	self.maxWaitTime = data.maxWaitTime
	self.curWaitTime = 0
	self.curTime = 0
	self.curNormalizeTime = 0
	self.bindData.progress.value = 0
	self.qteEnd = false
	self.holdTrigger = false
	self.holdVMBegin = false
	local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(false)
	end

	self.bindData.effectActive = false
	self.bindData.result = 3
	self.bindData.fill.renderOpacity = 1
end

function M:OnClose()
	local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(true)
	end

	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnUpdate()
	if self.qteEnd then
		return
	end

	if self.holdTrigger then
		if self.holdVMBegin then
			if self.closeTime > 0 then
				self.curTime = self.curTime + Time.deltaTime
				self.curNormalizeTime = self.curTime / self.closeTime

				if self.curNormalizeTime > 1 then
					self.curNormalizeTime = 1
					self.bindData.progress.value = self.curNormalizeTime

					self:TriggerEnd(gGaoQiaoManager.GAO_QIAO_END_TYPE.HOLD_MAX)
				else
					self.bindData.progress.value = self.curNormalizeTime
				end
			else
				self.curNormalizeTime = 1

				self:TriggerEnd(gGaoQiaoManager.GAO_QIAO_END_TYPE.HOLD_MAX)
			end
		end
	else
		self.curWaitTime = self.curWaitTime + Time.deltaTime

		if self.maxWaitTime <= self.curWaitTime then
			self:TriggerEnd(gGaoQiaoManager.GAO_QIAO_END_TYPE.NO_PRESS_HOLD_BUTTON)
		end
	end
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.qteBtn.luaPress = self:CreateAction("OnPressQteBtn")
	self.bindData.qteBtn.luaRelease = self:CreateAction("OnReleaseQteBtn")
end

function M:OnPressQteBtn()
	self.holdTrigger = true

	LogicStateMachineManager.Send3CEvent(MyPlayerManager.PlayerUnit, ABPCCCEventConfig.ChengGanTiaoBegin, 0)
end

function M:OnReleaseQteBtn()
	self:TriggerEnd(gGaoQiaoManager.GAO_QIAO_END_TYPE.RELEASE_HOLD)
end

function M:TriggerEnd(type)
	if not self.qteEnd then
		self.qteEnd = true

		gGaoQiaoManager:TriggerChengGanTiaoEnd(type, self.curNormalizeTime)

		if type == gGaoQiaoManager.GAO_QIAO_END_TYPE.HOLD_MAX then
			if not self.closeTimer then
				self.bindData.fill.renderOpacity = 0
				self.bindData.effectActive = true
				self.bindData.result = 0
				self.closeTimer = Timer.New(function ()
					gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
				end, 0.5):Start()
			end
		else
			gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
		end
	end
end

function M:BeginHoldProcessByVMotion(remainTime)
	self.closeTime = remainTime
	self.holdVMBegin = true
end
