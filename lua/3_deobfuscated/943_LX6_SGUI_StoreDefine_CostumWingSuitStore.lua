local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig
C_CostumWingSuitStore = DefClass("C_CostumWingSuitStore", C_CostumWingSuitStore, C_StoreGroup)
GroupName2Class.CostumWingSuitStore = C_CostumWingSuitStore
local M = C_CostumWingSuitStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.wingSuitState = {
		isinAir = false,
		isHeightSatisfied = false
	}
	self.wingFlyVisible = false
	self.wingFlyInteractable = false
	self.started = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})

	if self.started then
		self:RefreshWingSuitState()
	end
end

function M:OnStart()
	self.started = true
	self.wingFlyStore = self:GetStoreByWidget(self.bindData.wingFlyBtn)

	self:RefreshWingSuitState()
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	return
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

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ON_CAN_WING_FLY] = self:CreateAction("SetCanWingSuitFly"),
		[gEventConstants.ON_PLAYER_STATE_CHANGE] = self:CreateAction("SetPlayerWingSuitState")
	}
end

function M:RegisterWidget()
	self.bindData.wingFlyBtn.luaClick = self:CreateAction("OnClickWingFlyBtn")
end

function M:OnClickWingFlyBtn()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, ABPCCCEventConfig.Wingsuitflystart)
end

function M:RefreshWingSuitState()
	local visible = true
	local interactable = true

	if not self.wingSuitState.isinAir then
		visible = false
		interactable = false
	end

	if not self.wingSuitState.isHeightSatisfied then
		interactable = false
	end

	self.wingFlyStore.btnHideCtrl = visible and 0 or 1

	self.bindData.wingFlyBtn:SetPCKeyTipShowTip(visible)

	self.bindData.wingFlyBtn.interactable = interactable
end

function M:SetCanWingSuitFly(eventId, heightSatisfied)
	self.wingSuitState.isHeightSatisfied = heightSatisfied

	self:RefreshWingSuitState()
end

function M:SetPlayerWingSuitState(eventId, activeStates)
	if activeStates[gParkourPlayerStateType.AIR] ~= nil and self.wingSuitState.isinAir ~= activeStates[gParkourPlayerStateType.AIR] then
		self.wingSuitState.isinAir = activeStates[gParkourPlayerStateType.AIR]

		self:RefreshWingSuitState()
	end
end
