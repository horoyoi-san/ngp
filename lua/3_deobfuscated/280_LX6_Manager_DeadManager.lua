local RaidConfig = LTConfig.RaidConfig
local RaidTypeConfig = LTConfig.RaidRaidTypeConfig
local DieType = UX.Game.DieType
local ReviveType = UX.Game.ReviveType
local CreationConfig = LTConfig.CreationConfig
local MessageConfig = LTConfig.MessageConfig
local GameConfig = LTConfig.GameConfig
local HUDManager = LX6.GUI.HUDNew.HUDManager
local M = gDeadManager or {
	isDead = false,
	lastRecordGroundTime = 0,
	loadingFinished = false,
	autoCloseDeadPanelAndRevive = false,
	currentReviveCount = 0,
	maxReviveCount = 0
}
local DeadType = {
	ENEMY_KILL = 2,
	FALL = 1,
	OTHER = 4,
	CREATION_KILL = 3
}
local ButtonEvent = {
	FlashPointRespwan = 4,
	Rechallenge = 5,
	Exit = 1,
	Revival = 2,
	CheckPointRespwan = 3
}

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self.OnLoadingFinished)
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
end

function M.OnLoadingFinished()
	M.loadingFinished = true
end

function M.OnBeforeSwitchScene()
	M:RefreshReviveCount()

	M.lastRecordGroundTime = 0
end

function M:GetActiveBtns()
	local cfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidType = RaidTypeConfig.GetConfig(cfg.RaidType)
	local btns = {
		0,
		0,
		0,
		0,
		0
	}
	local btnCount = 0
	M.currentReviveType = nil

	if raidType.showrebirth then
		btns[1] = 1
		btnCount = btnCount + 1
		M.currentReviveType = ReviveType.Revive
	end

	if raidType.showrebirthfromteleport then
		btns[2] = 1
		btnCount = btnCount + 1
		M.currentReviveType = ReviveType.TeleportRevive
	end

	if raidType.showleave then
		btns[3] = 1
		btnCount = btnCount + 1
	end

	if raidType.showhallengeagain then
		btns[4] = 1
		btnCount = btnCount + 1
	end

	if raidType.showrebirthfromsave then
		btns[5] = 1
		btnCount = btnCount + 1
		M.currentReviveType = ReviveType.TaskRevive
	end

	return btns, btnCount
end

function M:Revive(reviveType, openLoading, succeedCallBack)
	if reviveType == nil then
		return
	end

	local loadingInfoIndex = gLoadingManager:Quick_Revive(openLoading, function ()
		gCS.MyPlayerManager.PlayerUnit:SetCCMoveEnable(true)
	end)

	gClientToGameSceneDelegate:RequestRevive(reviveType).Callback = function (err)
		gPanelManager:Close(gPanelId.S_PLAYER_DEAD_PANEL)
		HUDManager.SetUIVisibility(true)

		if err == MessageConfig.Ok then
			if succeedCallBack then
				succeedCallBack()
			end
		elseif err == MessageConfig.PlayerNotAlive then
			gLoadingManager:StopLoading(loadingInfoIndex, false)

			if succeedCallBack then
				succeedCallBack()
			end
		end
	end
end

function M:GetClientDeadType(type, sourceTemplateId, sourceCreationId)
	if type == DieType.FallOffCliff then
		return DeadType.FALL
	elseif type == DieType.Normal then
		local enemy = LTConfig.AgentConfig.GetConfig(sourceTemplateId)
		local creation = CreationConfig.GetConfig(sourceCreationId)

		if enemy ~= nil and sourceTemplateId ~= 40810000 then
			return DeadType.ENEMY_KILL
		elseif creation ~= nil and sourceTemplateId == 40810000 then
			return DeadType.CREATION_KILL
		else
			return DeadType.OTHER
		end
	else
		return DeadType.OTHER
	end
end

function M:GetDeadReasonAndDes(data)
	local serverDeadType = data[1].Type
	local sourceTemplateId = data[1].SourceTemplateId
	local sourceCreationId = data[1].SourceCreationId
	local deadType = M:GetClientDeadType(serverDeadType, sourceTemplateId, sourceCreationId)

	if deadType == DeadType.FALL then
		local reason = RaidConfig.FallDieName
		local des = RaidConfig.FallDieDescription
		local icon = RaidConfig.FallDieIcon

		return reason, des, icon
	elseif deadType == DeadType.ENEMY_KILL then
		local reason = RaidConfig.EnemyKillName
		local des = RaidConfig.EnemyKillDescription
		local icon = RaidConfig.EnemyKillIcon

		return reason, des, icon
	elseif deadType == DeadType.CREATION_KILL then
		local reason = RaidConfig.EnvironmentKillName
		local des = RaidConfig.EnvironmentKillDescription
		local icon = RaidConfig.EnvironmentKillIcon
		local creation = CreationConfig.GetConfig(sourceCreationId)

		if creation and #creation.EnvironmentKillDescription > 0 then
			reason = creation.EnvironmentKillName
			des = creation.EnvironmentKillDescription
		end

		return reason, des, icon
	elseif deadType == DeadType.OTHER then
		local reason = RaidConfig.OtherDieName
		local des = RaidConfig.OtherDieDescription
		local icon = RaidConfig.OtherDieIcon

		return reason, des, icon
	end
end

function M:CheckShowRevivePanel(info)
	if not gTaskUtils:CheckShowDeadPanel() then
		return
	end

	local cfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidType = RaidTypeConfig.GetConfig(cfg.RaidType)

	if raidType then
		if raidType.DeathUIType == RaidTypeConfig.DeathUITypeType.raid then
			gMessageManager:SendMessage(gEventConstants.FINISH_COUNT_DOWN, {})

			local showPanelDelay = RaidConfig.GetConfig(gRaidDataManager.RaidId).EndUIDelayShowTime

			if showPanelDelay == nil then
				showPanelDelay = GameConfig.DeathUiDelayTime
			end

			gSettlementMgr.delayShowRaidTimer = Timer.New(function ()
				gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
				gMessageManager:SendMessage(gEventConstants.MESSAGE_CLEAR)

				gSettlementMgr.delayShowRaidTimer = nil

				gSettlementMgr:ShowResultPanel()
			end, showPanelDelay):Start()
		elseif raidType.DeathUIType == RaidTypeConfig.DeathUITypeType.seasonraid then
			print("赛季面板不弹通用死亡面板")
		else
			gLuaTimeMgrUtils.Delay(function ()
				gPanelManager:CheckShow(gPanelId.S_PLAYER_DEAD_PANEL, {
					info
				})
			end, GameConfig.DeathUiDelayTime)
		end
	end

	HUDManager.SetUIVisibility(false)
end

function M:RefreshReviveCount(nowReviveCount)
	local cfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	self.maxReviveCount = -1

	if cfg then
		self.maxReviveCount = cfg.RaidReviveChances
	end

	self.currentReviveCount = nowReviveCount or self.maxReviveCount
end

gDeadManager = M
