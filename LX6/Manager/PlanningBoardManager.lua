-- Original chunk: @Lua\LuaFiles\LX6\Manager\PlanningBoardManager.lua
-- Decompiled from: 00240_PlanningBoardManager.lua_e450fedf5cfe.luajit

C_PlanningBoardManager = DefClass("C_PlanningBoardManager", C_PlanningBoardManager, nil, )
local M = C_PlanningBoardManager

M.ctor = function(self)
	gMessageManager:AddMessageListener(gEventConstants.LINK_SETTLE_DATA_CHANGED, function (_, args)
		self:OnLinkSettleDataChanged(args)
	end)
	gMessageManager:AddMessageListener(gEventConstants.TEAM_REFRESH_DATA, function ()
		self:OnTeamRefreshData()
	end)

	self.memberInfos = {}
	local itemIdList = {}

	for i = 0, LTConfig.LinkMultiPlayerConfig.count - 1 do
		local cfg = LTConfig.LinkMultiPlayerConfig.LoadAt(i)

		if cfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardDividends then
			array.concat(itemIdList, cfg.NeedKeyIds)
		end
	end

	self.dividendsItemIdList = itemIdList
end

M.OnTeamRefreshData = function(self)
end

M.GetPidList = function()
	if gTeamManager:GetTeamNumber() <= 1 then
		local pids = {}

		for _, member in ipairs(gTeamManager.members) do
			pids[#pids + 1] = member.Pid
		end

		return pids
	end

	return {
		gPlayerManager.infoLogin.bindData.pid
	}
end

M.GetMemberInfo = function(self, pid)
	local info = self.memberInfos[pid]

	if not info and pid ~= gPlayerManager.infoLogin.bindData.pid then
		local ownInfo = gPlanningBoardManager.GetPlanningBoardInfo()
		info = {
			MultiPlayerIdStates = ownInfo.MultiPlayerIdStates,
			MemberKeyCounts = {}
		}
		self.memberInfos[pid] = info
	end

	if info and pid ~= gPlayerManager.infoLogin.bindData.pid then
		for _, itemId in ipairs(self.dividendsItemIdList) do
			info.MemberKeyCounts[itemId] = gCommonItemManager:GetPackItemNum(itemId)
		end
	end

	return info
end

M.GetPlanningBoardInfo = function()
	return gPlayerManager.infoMinor.bindData.playerLinkPlanningBoardInfo
end

M.OnSyncLinkPlanningBoardMemberInfo = function(self, pid, info)
	self.memberInfos[pid] = info

	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
end

M.OnSyncOwnMultiPlayerIdStates = function(self, multiPlayerIdStates)
	local ownPid = gPlayerManager.infoLogin.bindData.pid
	local info = self.memberInfos[ownPid]

	if info then
		info.MultiPlayerIdStates = multiPlayerIdStates

		gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
	end
end

M.OnInitRoomMemberKeyCounts = function(self, prepareInfos)
	for pid, prepareInfo in pairs(prepareInfos) do
		local info = self.memberInfos[pid]

		if not info then
			info = {}
			self.memberInfos[pid] = info
		end

		info.MemberKeyCounts = prepareInfo.MemberKeyCounts
	end
end

M.OnInitRoomMemberPutInKeys = function(self, prepareInfos)
	for pid, prepareInfo in pairs(prepareInfos) do
		local info = self.memberInfos[pid]

		if info then
			info.PutInKeys = prepareInfo.PutInKeys
		end
	end
end

M.OnSyncRoomMemberPutInKeys = function(self, pid, putInKeys)
	local info = self.memberInfos[pid]

	if not info then
		info = {}
		self.memberInfos[pid] = info
	end

	info.PutInKeys = putInKeys

	gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
end

M.GetTeamMemberInfoList = function()
	local targetMemberList = {}

	if gTeamManager:GetTeamNumber() <= 1 then
		local memberList = gTeamManager.members

		for _, member in ipairs(memberList) do
			member.LinkPlanningBoardMemberInfo = gPlanningBoardManager:GetMemberInfo(member.Pid)

			table.insert(targetMemberList, member)
		end
	else
		table.insert(targetMemberList, {
			["oNbbg "] = 1,
			Pid = gPlayerManager.infoLogin.bindData.pid,
			PzHeadInfo = {
				SystemHeadId = gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId
			},
			Name = gPlayerManager.infoLogin.bindData.name,
			LinkPlanningBoardMemberInfo = gPlanningBoardManager:GetMemberInfo(gPlayerManager.infoLogin.bindData.pid)
		})
	end

	return targetMemberList
end

M.GetUnlockedMultiPlayerIdMap = function()
	local unlockedMap = {}
	local pids = gPlanningBoardManager.GetPidList()
	local memberCount = #pids

	if memberCount ~= 0 then
		return unlockedMap
	end

	local idCountMap = {}

	for _, pid in ipairs(pids) do
		local info = gPlanningBoardManager:GetMemberInfo(pid)
		local multiPlayerIdStates = info and info.MultiPlayerIdStates

		if multiPlayerIdStates then
			for multiPlayerId, _ in pairs(multiPlayerIdStates) do
				idCountMap[multiPlayerId] = (idCountMap[multiPlayerId] or 0) + 1
			end
		end
	end

	for multiPlayerId, count in pairs(idCountMap) do
		if count ~= memberCount then
			unlockedMap[multiPlayerId] = true
		end
	end

	return unlockedMap
end

M.CheckMultiPlayerHasCompleted = function(multiPlayerId)
	local pids = gPlanningBoardManager.GetPidList()
	local completedCount = 0

	for _, pid in ipairs(pids) do
		local info = gPlanningBoardManager:GetMemberInfo(pid)
		local multiPlayerIdStates = info and info.MultiPlayerIdStates

		if multiPlayerIdStates and multiPlayerIdStates[multiPlayerId] ~= UX.Game.PlanningBoardMultiPlayerState.Completed then
			completedCount = completedCount + 1
		end
	end

	return completedCount ~= #pids
end

M.GetTeamItemDetailDataList = function(dividendsMultiPlayerId)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(dividendsMultiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local itemDetailDataList = {}

	table.insert(itemDetailDataList, {
		["a\\x9f\\x8a\\x86Y"] = 0,
		dataList = itemIdList
	})

	local pids = gPlanningBoardManager.GetPidList()
	local totalOwnerItemMap = {}

	for _, pid in ipairs(pids) do
		local memberItemDataList = {}

		for _, itemId in ipairs(itemIdList) do
			local info = gPlanningBoardManager:GetMemberInfo(pid)
			local ownerCount = info and info.MemberKeyCounts and info.MemberKeyCounts[itemId] or 0

			table.insert(memberItemDataList, {
				itemId,
				num = ownerCount
			})

			local totalOwnerCount = totalOwnerItemMap[itemId] or 0
			totalOwnerCount = totalOwnerCount + ownerCount
			totalOwnerItemMap[itemId] = totalOwnerCount
		end

		table.insert(itemDetailDataList, {
			["a\\x9f\\x8a\\x86Y"] = 1,
			pid = pid,
			dataList = memberItemDataList
		})
	end

	local totalDataList = {}

	for _, itemId in ipairs(itemIdList) do
		local ownerCount = totalOwnerItemMap[itemId] or 0

		table.insert(totalDataList, ownerCount)
	end

	table.insert(itemDetailDataList, {
		["a\\x9f\\x8a\\x86Y"] = 2,
		dataList = totalDataList
	})

	return itemDetailDataList
end

M.GetTeamMemberCount = function()
	local memberList = gTeamManager.members
	local count = memberList and #memberList or 1

	return math.max(count, 1)
end

M.AskLinkPlanningBoardDividendsPutInKeys = function(self, itemInfoMap, callback)
	gClientToGameDelegate:AskLinkPlanningBoardDividendsPutInKeys(itemInfoMap).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_PLANNING_BOARD_DIVIDENDS_PUT_IN_KEYS_SUCCESS)
	end
end

M.GetMemberPutItemCount = function(pid, itemId)
	local info = gPlanningBoardManager.memberInfos[pid]
	local putInKeys = info and info.PutInKeys

	return putInKeys and putInKeys[itemId] or 0
end

M.GetDividendDropId = function(itemId)
	local count = LTConfig.LinkPlanningBoardDividendsConfig.count

	for i = 0, count - 1 do
		local dividendCfg = LTConfig.LinkPlanningBoardDividendsConfig.LoadAt(i)

		if dividendCfg.KeyId ~= itemId then
			return dividendCfg.DropId
		end
	end
end

M.GetReadyMemberCount = function()
	local linkGame = gLinkManager.currentLinkGame

	if not linkGame or linkGame.StageId == LTConfig.LinkStageConfig.Invest then
		return 0
	end

	return linkGame.StageConfirmMembers and #linkGame.StageConfirmMembers or 0
end

M.AskLinkPlanningBoardTeamLeaderUpdateSettingsInfo = function(self, settingInfo)
	if gClientUtils.CheckIsForbidRequestRpc() then
		return
	end

	gClientToGameDelegate:AskLinkPlanningBoardTeamLeaderUpdateSettingsInfo(settingInfo).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskExtraStateConfirm = function(self, confirmInfo, callback)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	if gLinkManager.useNewStage then
		gClientToGameDelegate:AskStageConfirm(confirmInfo).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			if callback then
				callback()
			end
		end
	else
		gClientToGameDelegate:AskExtraStateConfirm(confirmInfo).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			if callback then
				callback()
			end
		end
	end
end

M.OnLinkSettleDataChanged = function(self, args)
	local isSuccess = args and args.isSuccess
	local multiPlayerId = args and args.multiPlayerId

	if multiPlayerId and isSuccess then
		local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(multiPlayerId)

		if multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardDividends then
			self.dividendsMultiPlayerIdFinished = true
		end
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.dividendsMultiPlayerIdFinished = nil
		self.memberInfos = {}
	end
end

gPlanningBoardManager = gPlanningBoardManager or C_PlanningBoardManager.new()
