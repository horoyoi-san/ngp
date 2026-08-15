local houseCfg = LTConfig.HouseConfig
local GameplayHudDescGroupConfig = LTConfig.GameplayHudDescGroupConfig
local bit = require("bit")
local StaticProps = {
	SIGNAL = {
		LEFT_GET_UP = 6,
		MID_TURN = 3,
		LEFT_TURN = 1,
		RIGHT_TURN = 2,
		SIT_UP = 8,
		ENTER_BED = 0,
		LEFT_SIDE = 4,
		RIGHT_GET_UP = 7,
		RIGHT_SIDE = 5
	},
	HomeGamePlayType = {
		SINGLE_BED = 2,
		TV = 3,
		DOUBLE_BED = 1
	}
}
C_HomeInteractionManager = DefClass("C_HomeInteractionManager", C_HomeInteractionManager, nil, StaticProps)
local M = C_HomeInteractionManager
local ENTER_POINT = {
	LEFT = 1,
	RIGHT = 2
}
local LIE_TYPE = {
	MID_LIE = 3,
	LEFT_LIE = 1,
	RIGHT_LIE = 2
}
local HomeType2GamePlayType = {
	[M.HomeGamePlayType.DOUBLE_BED] = GameplayHudDescGroupConfig.DOUBLE_BED,
	[M.HomeGamePlayType.SINGLE_BED] = GameplayHudDescGroupConfig.SINGLE_BED,
	[M.HomeGamePlayType.TV] = GameplayHudDescGroupConfig.TV
}
local HomeType2ExitAction = {
	[M.HomeGamePlayType.DOUBLE_BED] = "PlayGetUp",
	[M.HomeGamePlayType.SINGLE_BED] = "PlayGetUp",
	[M.HomeGamePlayType.TV] = "PlayExitTV"
}

function M:ctor()
	self:OnInit()
end

function M:OnInit()
	self.actionSignals = 0
	self.interactionStore = nil
	self.gameplayType = 0
	self.entityInstanceId = nil
	self.bedType = 0
	self.enterPoint = 0
	self.preBedType = 0
	self.tvState = false
end

function M:OnSwitchTVState(isOpen)
	self.tvState = isOpen

	self:RefreshInteraction()
end

function M:OnBeginPlay(gamePlayType, entity)
	self.gameplayType = gamePlayType
	self.entityInstanceId = entity
	self.bedType = LIE_TYPE.MID_LIE

	gGamePlayTransitionMgr:EnterGamePlay(gGamePlayTransitionMgr.GamePlayType.Home)
	self:OnRefreshMap()
end

function M:OnEndOfPlay()
	if HomeType2ExitAction[self.gameplayType] then
		local action = self:CreateAction(HomeType2ExitAction[self.gameplayType])

		if action then
			action()
		end
	end
end

function M:OnBeginOfPlay()
	if self.interactionStore and self.interactionStore.STATE_EnableOnce then
		local inInteraction = self.actionSignals == 0

		self.interactionStore:SetBtnBackState(inInteraction)
	end
end

function M:OnRefreshMap()
	local gamePlayType = HomeType2GamePlayType[self.gameplayType]

	if not gamePlayType then
		return
	end

	if gamePlayType == GameplayHudDescGroupConfig.SINGLE_BED or gamePlayType == GameplayHudDescGroupConfig.DOUBLE_BED then
		self:SetSignalState(M.SIGNAL.ENTER_BED)
	end

	gPanelManager:CheckShow(gPanelId.GAMEPLAY_HUD_PRO_PANEL, {
		groupId = gamePlayType,
		backCallback = self:CreateAction("OnEndOfPlay"),
		showCallback = self:CreateAction("OnBeginOfPlay")
	})

	self.interactionStore = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")
end

function M:OnExitPlay()
	self.actionSignals = 0

	gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)

	self.interactionStore = nil
	self.entityInstanceId = nil

	gGamePlayTransitionMgr:EndGamePlay(gGamePlayTransitionMgr.GamePlayType.Home)
end

function M:OnActionEnd(cfg)
	if cfg.StartAniGroup ~= houseCfg.HouseBedActionGroup then
		return
	end

	if cfg.StartAniType == houseCfg.HouseBedLeftUpAction then
		self.enterPoint = ENTER_POINT.LEFT
	elseif cfg.StartAniType == houseCfg.HouseBedRightUpAction then
		self.enterPoint = ENTER_POINT.RIGHT
	end

	if table.contains(houseCfg.HouseBedLoopAction, cfg.TargetAniType) then
		self.actionSignals = 0

		self:RefreshInteraction()

		return
	end

	if table.contains(houseCfg.HouseBedLoopAction, cfg.StartAniType) and (self:CheckSignalState(M.SIGNAL.LEFT_GET_UP) or self:CheckSignalState(M.SIGNAL.RIGHT_GET_UP)) then
		self:OnExitPlay()

		return
	end
end

function M:SetSignalState(state)
	if self.actionSignals ~= 0 then
		return false
	end

	self.actionSignals = bit.bor(self.actionSignals, bit.lshift(1, state))

	gGamePlayTransitionMgr:CheckSwitchAction()

	return true
end

function M:CheckSignalState(state)
	return bit.band(self.actionSignals, bit.lshift(1, state)) > 0
end

function M:PlaySleep()
	local args = {
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Time
	}

	gPanelManager:CheckShow(gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL, args)
end

local LIE_TYPE_2_SIGNAL = {
	[LIE_TYPE.LEFT_LIE] = M.SIGNAL.LEFT_TURN,
	[LIE_TYPE.RIGHT_LIE] = M.SIGNAL.RIGHT_TURN,
	[LIE_TYPE.MID_LIE] = M.SIGNAL.MID_TURN
}

function M:PlayBedTurnOver()
	local bedType = 0

	if self.bedType == LIE_TYPE.LEFT_LIE then
		bedType = LIE_TYPE.MID_LIE
	elseif self.bedType == LIE_TYPE.MID_LIE then
		bedType = self.preBedType == LIE_TYPE.LEFT_LIE and LIE_TYPE.RIGHT_LIE or LIE_TYPE.LEFT_LIE
		self.preBedType = bedType
	elseif self.bedType == LIE_TYPE.RIGHT_LIE then
		bedType = LIE_TYPE.MID_LIE
	end

	if self:SetSignalState(LIE_TYPE_2_SIGNAL[bedType]) then
		self:RefreshInteraction()

		self.bedType = bedType
	end
end

function M:PlayBedSwitchSide()
	local signal = 0
	local enterPoint = 0

	if self.enterPoint == ENTER_POINT.LEFT then
		enterPoint = ENTER_POINT.RIGHT
		signal = M.SIGNAL.LEFT_SIDE
	else
		enterPoint = ENTER_POINT.LEFT
		signal = M.SIGNAL.RIGHT_SIDE
	end

	if self:SetSignalState(signal) then
		self:RefreshInteraction()

		self.enterPoint = enterPoint
		self.bedType = LIE_TYPE.MID_LIE
	end
end

function M:PlayGetUp()
	local signal = 0

	if self.enterPoint == ENTER_POINT.LEFT then
		signal = M.SIGNAL.LEFT_GET_UP
	else
		signal = M.SIGNAL.RIGHT_GET_UP
	end

	if self:SetSignalState(signal) then
		self:RefreshInteraction()
	end
end

function M:PlayExercise()
	if self:SetSignalState(M.SIGNAL.SIT_UP) then
		self:RefreshInteraction()

		self.bedType = LIE_TYPE.MID_LIE
	end
end

function M:CheckIsSingleBed()
	return self.gameplayType == M.HomeGamePlayType.SINGLE_BED
end

function M:CheckIsInHomeAction()
	return self.actionSignals == 0
end

function M:PlayChangeTVState()
	if not self.entityInstanceId then
		return
	end

	if self.tvState then
		gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, "TurnOffTV")
	else
		gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, "TurnOnTV")
	end

	self.tvState = not self.tvState

	self:RefreshInteraction()
end

function M:PlayExitTV()
	if not self.entityInstanceId then
		return
	end

	gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, "StopWatchingTV")
	self:OnExitPlay()
end

function M:PlayChangeTV()
	if not self.entityInstanceId then
		return
	end

	gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, "ChangeTVChannel")
end

function M:RefreshInteraction()
	if self.interactionStore and self.interactionStore.STATE_EnableOnce then
		local inInteraction = self.actionSignals == 0

		self.interactionStore:SetBtnBackState(inInteraction)
		self.interactionStore:RefreshBtnState()
	end
end

gHomeInteractionManager = gHomeInteractionManager or C_HomeInteractionManager.new()
