local HudDescConfig = LTConfig.HudDescConfig
C_UniqueSkillJiaMuStore = DefClass("C_UniqueSkillJiaMuStore", C_UniqueSkillJiaMuStore, C_StoreGroup)
GroupName2Class.UniqueSkillJiaMuStore = C_UniqueSkillJiaMuStore
local M = C_UniqueSkillJiaMuStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.summonWheelState = {
		[gParkourPlayerStateType.AIR] = false,
		[gParkourPlayerStateType.WALL] = false,
		[gParkourPlayerStateType.WATER] = false
	}
end

function M:DefineAllEnumsAutoGen()
	self.btnHideCtrlEnum = {
		_false = 0,
		_true = 1
	}
	self.wordsCtrlEnum = {
		False = 0,
		True = 1
	}
	self.qteVxCtrlEnum = {
		_false = 0,
		_true = 1
	}
end

function M:ClearAllEnumsAutoGen()
	self.btnHideCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.qteVxCtrlEnum = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnGroupEnable()
	self.summonWheelBtn = self:GetStoreByWidget(self.bindData.summonWheelBtn)
	self.summonWheelBtn.btnId = HudDescConfig.SUMMON_WHEEL_BTN
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnEnable()
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

function M:OnShow(panelId, data)
	self:SetSummonWheelState(_, gCoreHudUIManager.activePlayerStates)
	self:RefreshButtonState()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ON_SYNC_URBAN_BADGEINFO] = self:CreateAction("RefreshButtonState"),
		[gEventConstants.ON_PLAYER_STATE_CHANGE] = self:CreateAction("SetSummonWheelState")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:RegisterWidget()
	self.bindData.summonWheelBtn.luaPress = self:CreateAction("OnPressSummonWheelBtn")
	self.bindData.summonWheelBtn.luaRelease = self:CreateAction("OnReleaseSummonWheelBtn")
end

function M:OnPressSummonWheelBtn()
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):OpenSummonCircle()
end

function M:OnReleaseSummonWheelBtn()
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):CloseCircle()
end

function M:RefreshButtonState()
	local visible = true
	local interactable = true
	local enable = gSpiritJobManager:CheckCurSpiritContainBadge(19004100)

	if self.summonWheelState[gParkourPlayerStateType.AIR] or not enable then
		interactable = false
	elseif self.summonWheelState[gParkourPlayerStateType.WATER] or self.summonWheelState[gParkourPlayerStateType.WALL] then
		visible = false
		interactable = false
	end

	gStoreButtonMgr:SetButtonVisibleBase(self.summonWheelBtn, visible)
	gStoreButtonMgr:SetButtonInteractableBase(self.summonWheelBtn, interactable)
	self.bindData.summonWheelBtn:SetPCKeyTipShowTip(visible)
	self:Log("visible", visible, "interactable", interactable)
end

function M:SetSummonWheelState(eventId, activeStates)
	local needRefresh = false

	for stateType, field in pairs(activeStates) do
		if self.summonWheelState[stateType] ~= field then
			self.summonWheelState[stateType] = field
			needRefresh = true
		end
	end

	if needRefresh then
		self:RefreshButtonState()
	end
end

function M:Log(...)
	if gMainMenuMgr.ShowTestMsg then
		print_warn("[UniqueSkillJiaMuStore]", ...)
	end
end
