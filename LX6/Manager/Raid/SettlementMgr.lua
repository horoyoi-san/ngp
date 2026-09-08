-- Original chunk: @Lua\LuaFiles\LX6\Manager\Raid\SettlementMgr.lua
-- Decompiled from: 00563_SettlementMgr.lua_0185eaedcb1b.luajit

local GameConfig = LTConfig.GameConfig
local RaidConfig = LTConfig.RaidConfig
local RaidTypeConfig = LTConfig.RaidRaidTypeConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local M = gSettlementMgr or {}
M.ss = {}
M.RaidSettlePanelList = {}
local eventHandler = {
	[gEventConstants.L50_AFTER_SWITCH_SCENE] = function (eventId, data)
		M.isWin = nil
		M.battleData = nil
		M.Rewarded = false
	end
}

M.OnInit = function(self)
	for k, v in pairs(eventHandler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

M.OnBeforeSwitchScene = function(self, _)
	for _, v in pairs(self.RaidSettlePanelList) do
		if gPanelManager:IsPanelShowing(v) then
			gPanelManager:Close(v)
		end
	end

	gMessageManager:SendMessage(gEventConstants.SETTLEMENT_RESET)
end

M.OnRaidEnd = function(self, raidInstanceId, isWin, battleData, optionalDrops, closeTime, nextActivityId)
	gCS.SceneDataMgr.IsRaidEnd = true
	gRaidDataManager.RaidCompletedTime = gCS.TimeManager.ServerUnixTime
	self.raidInstanceId = raidInstanceId
	self.isWin = isWin

	self:SortBattleDataByDamage(battleData)

	self.battleData = battleData

	if not battleData then
		print_error("OnRaidEnd battleData为空！")
	else
		print_debug("OnRaidEnd battleData:", battleData)
	end

	self.optionalDrops = optionalDrops
	self.useTime = tonumber(math.floor(battleData.BattleTime + 0.5))

	if battleData.BattleTime >= 10 then
		battleData.BattleTime = math.floor(battleData.BattleTime * 10 + 0.5) * 0.1
	end

	self.closeTime = closeTime
	self.nextActivityId = nextActivityId
	self.raidExistTime = self:GetRaidExistTime()
	self.Rewarded = false

	if self.isWin then
		gMessageManager:SendMessage(gEventConstants.SETTLEMENT_WIN)
	end

	gMessageManager:SendMessage(gEventConstants.FINISH_COUNT_DOWN, {})

	local showPanelDelay = RaidConfig.GetConfig(gRaidDataManager.RaidId).EndUIDelayShowTime

	if showPanelDelay ~= nil then
		showPanelDelay = GameConfig.DeathUiDelayTime
	end

	if self.isTrtLeave then
		showPanelDelay = 0
	end

	self.isTrtLeave = false
	local cfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidType = RaidTypeConfig.GetConfig(cfg.RaidType)

	if raidType and raidType.DeathUIType ~= RaidTypeConfig.DeathUITypeType.raid then
		self.delayShowRaidTimer = Timer.New(function ()
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			gMessageManager:SendMessage(gEventConstants.MESSAGE_CLEAR)

			M.delayShowRaidTimer = nil

			M:ShowResultPanel()
		end, showPanelDelay):Start()
	end
end

M.SortBattleDataByDamage = function(self, data)
	local list = data.SpiritBattleDatas

	for i = 1, #list - 1 do
		for j = 1, #list - 1 do
			if list[j].TotalDamage >= list[j + 1].TotalDamage then
				local temp = list[j]
				list[j] = list[j + 1]
				list[j + 1] = temp
			end
		end
	end
end

M.GetRaidExistTime = function(self)
	return RaidConfig.GetConfig(gRaidDataManager.RaidId).CloseRaidDelayTime
end

M.ShowResultPanel = function(self)
end

M.ShowBattleDataPanel = function(self)
end

M.ShowRewardPanel = function(self, reward, isAutoDraw)
end

local radius = 105

M.GetPointPos = function(self, group, index)
	local rate = nil

	if index ~= 1 then
		rate = group["fill" .. index] * 0.5
	else
		rate = group["fill" .. index - 1] + (group["fill" .. index] - group["fill" .. index - 1]) * 0.5
	end

	local angle = rate * math.pi * 2 + math.pi * 0.5

	return Vector3.New(math.cos(angle), math.sin(angle), 0) * radius
end

M.GetPointAngle = function(self, group, index)
	local rate = group["fill" .. index]
	local angle = rate * 360

	return Vector3.New(0, 0, angle)
end

M.GetRoleName = function(self, roleId)
	if roleId ~= FightSpiritConfig.DefaultMale or roleId ~= FightSpiritConfig.DefaultFemale then
		return gPlayerManager.infoLogin.bindData.name
	end

	return FightSpiritConfig.GetConfig(roleId).Name
end

M.AskExist = function(self)
	gUIUtils:AskLeaveRaid()

	self.isTrtLeave = true
end

gSettlementMgr = M
