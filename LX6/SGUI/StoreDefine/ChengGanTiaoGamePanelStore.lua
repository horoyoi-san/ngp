-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChengGanTiaoGamePanelStore.lua
-- Decompiled from: 01426_ChengGanTiaoGamePanelStore.lua_be9492428006.luajit

C_ChengGanTiaoGamePanelStore = DefClass("C_ChengGanTiaoGamePanelStore", C_ChengGanTiaoGamePanelStore, C_StoreGroup)
GroupName2Class.ChengGanTiaoGamePanelStore = C_ChengGanTiaoGamePanelStore
local M = C_ChengGanTiaoGamePanelStore
local MyPlayerManager = gCS.MyPlayerManager
local LogicStateMachineManager = gCS.LogicStateMachineManager
local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.closeTime = 0
	self.maxWaitTime = data.maxWaitTime
	self.curWaitTime = 0
	self.curTime = 0
	self.curNormalizeTime = 0
	self.bindData.progress.value = 0
	self.qteEnd = false
	self.holdTrigger = false
	self.holdVMBegin = false
	self.bindData.effectActive = false
	self.bindData.result = 3
	self.bindData.fill.renderOpacity = 1
	self.isInGameplayHud = data.isInGameplayHud

	if self.isInGameplayHud then
		local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

		if store and store.bindData.btnExit then
			store.bindData.btnExit:SetActive(false)
		end
	end
end

M.OnClose = function(self)
	if self.isInGameplayHud then
		local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

		if store and store.bindData.btnExit then
			store.bindData.btnExit:SetActive(true)
		end
	end

	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
	if self.qteEnd then
		return
	end

	if self.holdTrigger then
		if self.holdVMBegin then
			if self.closeTime <= 0 then
				self.curTime = self.curTime + Time.deltaTime
				self.curNormalizeTime = self.curTime / self.closeTime

				if self.curNormalizeTime <= 1 then
					self.curNormalizeTime = 1
					self.bindData.progress.value = self.curNormalizeTime

					self.TriggerEnd(self, gGaoQiaoManager.GAO_QIAO_END_TYPE.HOLD_MAX)
				else
					self.bindData.progress.value = self.curNormalizeTime
				end
			else
				self.curNormalizeTime = 1

				self.TriggerEnd(self, gGaoQiaoManager.GAO_QIAO_END_TYPE.HOLD_MAX)
			end
		end
	else
		self.curWaitTime = self.curWaitTime + Time.deltaTime

		if self.maxWaitTime < self.curWaitTime then
			self.TriggerEnd(self, gGaoQiaoManager.GAO_QIAO_END_TYPE.NO_PRESS_HOLD_BUTTON)
		end
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = self.CreateAction(self, "OnGamePlayOutWardSignal")
	}
end

M.OnGamePlayOutWardSignal = function(self, eventId, data)
	local signalId = data.GetCfgId(data)

	if signalId ~= 37002 then
		local pid = data.GetPid(data)

		if pid ~= MyPlayerManager.PlayerUnit.Pid and self.holdTrigger then
			FrameTimer.New(function ()
				LogicStateMachineManager.Send3CEvent(MyPlayerManager.PlayerUnit, ABPCCCEventConfig.ChengGanTiaoBegin, 0)
			end, 1):Start()
		end
	end
end

M.RegisterWidget = function(self)
	self.bindData.qteBtn.luaPress = self.CreateAction(self, "OnPressQteBtn")
	self.bindData.qteBtn.luaRelease = self.CreateAction(self, "OnReleaseQteBtn")
end

M.OnPressQteBtn = function(self)
	self.holdTrigger = true

	LogicStateMachineManager.Send3CEvent(MyPlayerManager.PlayerUnit, ABPCCCEventConfig.ChengGanTiaoBegin, 0)
end

M.OnReleaseQteBtn = function(self)
	self.TriggerEnd(self, gGaoQiaoManager.GAO_QIAO_END_TYPE.RELEASE_HOLD)
end

M.TriggerEnd = function(self, type)
	if not self.qteEnd then
		self.qteEnd = true

		gGaoQiaoManager:TriggerChengGanTiaoEnd(type, self.curNormalizeTime)

		if type ~= gGaoQiaoManager.GAO_QIAO_END_TYPE.HOLD_MAX then
			if not self.closeTimer then
				self.bindData.fill.renderOpacity = 0
				self.bindData.effectActive = true
				self.bindData.result = 0
				self.closeTimer = Timer.New(function ()
					if self.isInGameplayHud then
						gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
					else
						gPanelManager:Close(gPanelId.CHENGGANTIAO_GAM_PANEL)
					end
				end, 0.5):Start()
			end
		elseif self.isInGameplayHud then
			gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
		else
			gPanelManager:Close(gPanelId.CHENGGANTIAO_GAM_PANEL)
		end
	end
end

M.BeginHoldProcessByVMotion = function(self, remainTime)
	self.closeTime = remainTime
	self.holdVMBegin = true
end
