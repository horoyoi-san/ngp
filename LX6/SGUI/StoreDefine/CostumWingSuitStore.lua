-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CostumWingSuitStore.lua
-- Decompiled from: 01502_CostumWingSuitStore.lua_e347d8c3e47b.luajit

local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig
local HudDescConfig = LTConfig.HudDescConfig
C_CostumWingSuitStore = DefClass("C_CostumWingSuitStore", C_CostumWingSuitStore, C_StoreGroup)
GroupName2Class.CostumWingSuitStore = C_CostumWingSuitStore
local M = C_CostumWingSuitStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.wingSuitState = {
		["\\xd0\\xc8?-\\xe3"] = false,
		["}\\xef\\xe9 0'\\xd7R!\\xc1B\\x9f\nK\\xc3\\xe2"] = false
	}
	self.wingFlyVisible = false
	self.wingFlyInteractable = false
	self.started = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})

	if self.started then
		self.RefreshWingSuitState(self)
	end
end

M.OnStart = function(self)
	self.started = true
	self.wingFlyStore = self.GetStoreByWidget(self, self.bindData.wingFlyBtn)
	self.wingFlyStore.btnId = HudDescConfig.WING_FLY_BTN

	if self.bindData.wingRushBtn then
		self.wingRushStore = self.GetStoreByWidget(self, self.bindData.wingRushBtn)
		self.wingRushStore.btnId = HudDescConfig.WING_RUSH_BTN
	end

	self:RefreshWingSuitState()
	gCoreHudUIManager:OnRefreshSkillBtn(gCoreHudUIManager.skillType.WingSuitDash, true)
	gCoreHudTipManager:InitButtonInfoForTabRect(self.bindData.wingRushBtn, gCoreHudTipManager.btnInfoEnum.WingSuitDash)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
	self.ClearDataSetEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_CAN_WING_FLY] = self.CreateAction(self, "SetCanWingSuitFly"),
		[gEventConstants.ON_PLAYER_STATE_CHANGE] = self.CreateAction(self, "SetPlayerWingSuitState")
	}
	self.dataSetEvents = {
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.WingSuitDash,
			self.CreateAction(self, "UpdateBtnState")
		}
	}
end

M.RegisterWidget = function(self)
	self.bindData.wingFlyBtn.luaBeginLongPress = self.CreateAction(self, "OnClickWingFlyBtn")

	if self.bindData.wingRushBtn then
		self.bindData.wingRushBtn.luaBeginLongPress = self.CreateAction(self, "OnWingRushBtnBeginLongPress")
		self.bindData.wingRushBtn.luaEndLongPress = self.CreateAction(self, "OnWingRushBtnEndLongPress")
	end

	gCoreHudUIManager:SetupDragButtons(self.bindData, {
		"\\x88=.8J\\x88R\\xd1\\xbe\\xb7"
	})
end

M.OnClickWingFlyBtn = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, ABPCCCEventConfig.Wingsuitflystart)
end

M.RefreshWingSuitState = function(self)
	local visible = true
	local interactable = true

	if not self.wingSuitState.isinAir then
		visible = false
		interactable = false
	end

	if not self.wingSuitState.isHeightSatisfied then
		interactable = false
	end

	self.wingFlyStore:Commit("btnHideCtrl", visible and 0 or 1)
	self.bindData.wingFlyBtn:SetPCKeyTipShowTip(visible)

	self.bindData.wingFlyBtn.interactable = interactable
end

M.SetCanWingSuitFly = function(self, eventId, heightSatisfied)
	self.wingSuitState.isHeightSatisfied = heightSatisfied

	self.RefreshWingSuitState(self)
end

M.SetPlayerWingSuitState = function(self, eventId, activeStates)
	if activeStates[gParkourPlayerStateType.AIR] == nil and self.wingSuitState.isinAir == activeStates[gParkourPlayerStateType.AIR] then
		self.wingSuitState.isinAir = activeStates[gParkourPlayerStateType.AIR]

		self.RefreshWingSuitState(self)
	end
end

M.UpdateBtnState = function(self, data)
	local skillType = data.key
	local state = data.value

	if skillType ~= gCoreHudUIManager.skillType.WingSuitDash then
		if not self.wingRushStore or not self.bindData.wingRushBtn then
			return
		end

		gStoreButtonMgr:SetButtonVisibleBase(self.wingRushStore, state[1])
		self.bindData.wingRushBtn:SetActive(state[2])
	end
end

M.OnWingRushBtnBeginLongPress = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashPress)
end

M.OnWingRushBtnEndLongPress = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashRelease)
end
