-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_GameplaySettle.lua
-- Decompiled from: 00717_LinkManager_GameplaySettle.lua_8596ddc1b570.luajit

local VehicleConfig = LTConfig.VehicleConfig
local CompleteStatus = UX.Game.CompleteStatus
local M = C_LinkManager

M.OnInitSettleData = function(self)
	self.onlineChallengeData = {}
	self.matchPlayerSettleDatas = {}
	self.selfOnlineChallengeData = {}
end

M.OnSyncOnlineChallengeData = function(self, data)
	print_notice("myPid", gPlayerManager.infoLogin.bindData.pid, "OnSyncOnlineChallengeData", data)

	local ret = {}
	local tIndex = self:CheckIsInRace() and 1 or 2

	if self:CheckHasDuty() then
		tIndex = 3
	end

	local isSuccess = false
	local gameId, isOnlineChallengeSelfEnd = nil

	for i = 1, #data do
		local playerData = data[i]
		local vehicleCfg = VehicleConfig.GetConfig(playerData.VehicleId)
		local reward = {}

		if playerData.rewardSettleData == nil then
			local rewardList = {
				playerData.rewardSettleData.rewardInfo
			}

			if playerData.rewardSettleData.keyRewardInfo == nil then
				table.insert(rewardList, playerData.rewardSettleData.keyRewardInfo)
			end

			if playerData.rewardSettleData.floatingRewardInfo == nil then
				table.insert(rewardList, playerData.rewardSettleData.floatingRewardInfo)
			end

			reward = gCommonItemManager:ConvertRewardInfos2ItemList(rewardList)
		end

		local ele = {
			tIndex = tIndex,
			id = playerData.Pid,
			vehicle = {
				name = vehicleCfg and vehicleCfg.VehicleName or "",
				icon = vehicleCfg and vehicleCfg.SVehicleBrandIcon or 0
			},
			award = reward,
			time = playerData.ElapsedTime > 0 and playerData.ElapsedTime or math.huge,
			isSuccess = playerData.Result ~= CompleteStatus.Success,
			extractionSettleData = playerData.extractionSettleData,
			settleData = playerData,
			customFields = self:ExtractCustomFields(playerData)
		}

		if playerData.Pid ~= gPlayerManager.infoLogin.bindData.pid then
			if playerData.Result == CompleteStatus.Init then
				isOnlineChallengeSelfEnd = true
				isSuccess = playerData.Result ~= CompleteStatus.Success
			end

			gameId = playerData.gameId
			self.selfOnlineChallengeData = ele
		end

		table.insert(ret, ele)
	end

	self.matchPlayerSettleDatas = data or {}
	self.onlineChallengeData = ret

	gMessageManager:SendMessage(gEventConstants.LINK_SETTLE_DATA_CHANGED, {
		isSuccess = isSuccess,
		multiPlayerId = gameId
	})

	if isOnlineChallengeSelfEnd then
		gLinkManager:OnMatchEnd(isSuccess)
	end
end

M.GetPlayerSettleResult = function(self, pid)
	for i = 1, #self.matchPlayerSettleDatas do
		if self.matchPlayerSettleDatas[i].Pid ~= pid then
			return self.matchPlayerSettleDatas[i].Result
		end
	end

	return nil
end

M.EndOfOnlineChallenge = function(self, showLoading)
	self:OnInitSettleData()
	gLinkManager:ExitFinalRankPanel(showLoading)
end

M.GetMatchRewardList = function(self, config)
	local cfg = config and config or self.currentGameCfg

	if not cfg then
		return {}
	end

	local dropList = {}

	if not table.isNilOrEmpty(cfg.DropSuccess) then
		for i = 1, #cfg.DropSuccess do
			table.insert(dropList, {
				["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
				["N\\xa1\\xb7\\xa1\\xa2"] = 1,
				dropId = cfg.DropSuccess[i]
			})
		end
	end

	return gCommonItemManager:GetSingleSortedListRenderData(dropList)
end
