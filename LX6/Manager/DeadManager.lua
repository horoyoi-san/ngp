-- Original chunk: @Lua\LuaFiles\LX6\Manager\DeadManager.lua
-- Decompiled from: 00697_DeadManager.lua_074dd4a8fb2e.luajit

local RaidConfig = LTConfig.RaidConfig
local RaidTypeConfig = LTConfig.RaidRaidTypeConfig
local DieType = UX.Game.DieType
local ReviveType = UX.Game.ReviveType
local CreationConfig = LTConfig.CreationConfig
local MessageConfig = LTConfig.MessageConfig
local GameConfig = LTConfig.GameConfig
local HUDManager = LX6.GUI.HUDNew.HUDManager
local DeadPanelTypeType = LTConfig.LinkMultiPlayerConfig.DeadPanelTypeType
local M = gDeadManager or {
	["[\\xb5\\x8b\\x82E"] = false,
	["\\x8e.\\xfe\\xa8a-\\xc5T\\xcc\\xc91BR\\xce\\xb5\\xc6"] = 0,
	["/%!\\xe0z\\x96\\xf0\\xa1!\\xef\\xe1\\xeeq\\xff"] = false,
	["3\\xf2\"<ʔ\\xaa缣ざ߬\\x85'ç%\\x94\\xbb;\\x8d\\xdb$\\xe2"] = false,
	["/\\x82\\xff\\xae\\xa9\\xfc\\x94\\xbf\\x9e\\xd4\\xf47\\xe5\\x955\\x91\\xf6"] = 0,
	["\\xea\\x9b\t\\xde\\xef\r\\xef\\xab\\xe2\\x97.<"] = 0
}
local DeadType = {
	["vt됽7\\x93-\\xe5\\xc4"] = 2,
	["\\Qw"] = 1,
	["b\\x9a\\x8a\\x8a\\x84"] = 4,
	["!\\xd1z\r>\\xf93\\x98~\\x8a\\x9c\\x9a"] = 3
}

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self.OnLoadingFinished)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
end

M.OnLoadingFinished = function()
	M.loadingFinished = true
end

M.OnBeforeSwitchScene = function()
	M:RefreshReviveCount()

	M.lastRecordGroundTime = 0
end

M.GetActiveBtns = function(self)
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

M.Revive = function(self, reviveType, openLoading, succeedCallBack)
	if reviveType ~= nil then
		return
	end

	gClientToGameSceneDelegate:RequestRevive(reviveType).Callback = function (err)
		gPanelManager:Close(gPanelId.S_PLAYER_DEAD_PANEL)
		HUDManager.SetUIVisibility(true)

		if err ~= MessageConfig.Ok then
			if succeedCallBack then
				succeedCallBack()
			end
		elseif err ~= MessageConfig.PlayerNotAlive and succeedCallBack then
			succeedCallBack()
		end
	end
end

M.GetClientDeadType = function(self, type, sourceTemplateId, sourceCreationId)
	if type ~= DieType.FallOffCliff then
		return DeadType.FALL
	elseif type ~= DieType.Normal then
		local enemy = LTConfig.AgentConfig.GetConfig(sourceTemplateId)
		local creation = CreationConfig.GetConfig(sourceCreationId)

		if enemy == nil and sourceTemplateId == 40810000 then
			return DeadType.ENEMY_KILL
		elseif creation == nil and sourceTemplateId ~= 40810000 then
			return DeadType.CREATION_KILL
		else
			return DeadType.OTHER
		end
	else
		return DeadType.OTHER
	end
end

M.GetDeadReasonAndDes = function(self, data)
	local deadPanelType = gLinkManager:GetDeadPanelType()

	if deadPanelType ~= DeadPanelTypeType.outRace then
		return RaidConfig.DeathGameDieName, RaidConfig.DeathGameDieDescription, RaidConfig.DeathGameDieIcon
	end

	local serverDeadType = data[1].Type
	local sourceTemplateId = data[1].SourceTemplateId
	local sourceCreationId = data[1].SourceCreationId
	local deadType = M:GetClientDeadType(serverDeadType, sourceTemplateId, sourceCreationId)

	if deadType ~= DeadType.FALL then
		local reason = RaidConfig.FallDieName
		local des = RaidConfig.FallDieDescription
		local icon = RaidConfig.FallDieIcon

		return reason, des, icon
	elseif deadType ~= DeadType.ENEMY_KILL then
		local reason = RaidConfig.EnemyKillName
		local des = RaidConfig.EnemyKillDescription
		local icon = RaidConfig.EnemyKillIcon

		return reason, des, icon
	elseif deadType ~= DeadType.CREATION_KILL then
		local reason = RaidConfig.EnvironmentKillName
		local des = RaidConfig.EnvironmentKillDescription
		local icon = RaidConfig.EnvironmentKillIcon
		local creation = CreationConfig.GetConfig(sourceCreationId)

		if creation and #creation.EnvironmentKillDescription <= 0 then
			reason = creation.EnvironmentKillName
			des = creation.EnvironmentKillDescription
		end

		return reason, des, icon
	elseif deadType ~= DeadType.OTHER then
		local reason = RaidConfig.OtherDieName
		local des = RaidConfig.OtherDieDescription
		local icon = RaidConfig.OtherDieIcon

		return reason, des, icon
	end
end

M.CheckShowRevivePanel = function(self, info)
	if not gTaskUtils:CheckShowDeadPanel() then
		return
	end

	if not gLinkManager:CheckShowDeadPanel() then
		return
	end

	local cfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidType = RaidTypeConfig.GetConfig(cfg.RaidType)

	if raidType then
		if raidType.DeathUIType ~= RaidTypeConfig.DeathUITypeType.raid then
			gMessageManager:SendMessage(gEventConstants.FINISH_COUNT_DOWN, {})

			local showPanelDelay = RaidConfig.GetConfig(gRaidDataManager.RaidId).EndUIDelayShowTime

			if showPanelDelay ~= nil then
				showPanelDelay = GameConfig.DeathUiDelayTime
			end

			gSettlementMgr.delayShowRaidTimer = Timer.New(function ()
				if not gLinkManager:CheckShowDeadPanel() then
					gSettlementMgr.delayShowRaidTimer = nil

					return
				end

				gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
				gMessageManager:SendMessage(gEventConstants.MESSAGE_CLEAR)

				gSettlementMgr.delayShowRaidTimer = nil

				gSettlementMgr:ShowResultPanel()
			end, showPanelDelay):Start()
		elseif raidType.DeathUIType ~= RaidTypeConfig.DeathUITypeType.seasonraid then
			print("赛季面板不弹通用死亡面板")
		else
			gLuaTimeMgrUtils.Delay(function ()
				self:CheckShowPlayerDeadPanel(info)
			end, GameConfig.DeathUiDelayTime)
		end
	end

	HUDManager.SetUIVisibility(false)
end

M.CheckShowPlayerDeadPanel = function(self, info)
	if not gTaskUtils:CheckShowDeadPanel() then
		return
	end

	if not gLinkManager:CheckShowDeadPanel() then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_PLAYER_DEAD_PANEL, {
		info
	})
end

M.RefreshReviveCount = function(self, nowReviveCount)
	local cfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	self.maxReviveCount = -1

	if cfg then
		self.maxReviveCount = cfg.RaidReviveChances
	end

	self.currentReviveCount = nowReviveCount or self.maxReviveCount
end

gDeadManager = M
