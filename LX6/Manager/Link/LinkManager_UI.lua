-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_UI.lua
-- Decompiled from: 00713_LinkManager_UI.lua_515844ca7eb9.luajit

local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local VehicleConfig = LTConfig.VehicleConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local LinkConfig = LTConfig.LinkConfig
local CompleteStatus = UX.Game.CompleteStatus
local M = C_LinkManager
local CONTENT_TYPE = {
	[".m\\xa6\\xaf\\xb1e"] = 4,
	["y\\x87\\x96\\x83\\x93"] = 0,
	["2}\\xbc\\xac\\xa6s"] = 2,
	["W\rY~"] = 5,
	["\\xfa\\xf4:);\n\\xc5"] = 1,
	["(i\\xa3\\xa9\\xa6u"] = 3
}

M.CloseAllStagePanel = function(self, room)
	gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
end

M.OnRefreshLinkContent = function(self, content, modeId, tabStore)
	local store = gStoreManager:GetStoreGroup("OnlineCommonContentTemplate"):GetStoreByWidget(content)

	if not store then
		return
	end

	local cfg = LinkMultiPlayerConfig.GetConfig(modeId)
	local isFullEntrance = false

	if not cfg then
		cfg = LinkConfig.GetConfig(modeId)
		isFullEntrance = true

		if not cfg then
			return store, cfg, isFullEntrance
		end
	end

	local names = string.split(cfg.Name, "·")
	local modeCfg = cfg

	local addRewardContentRows = function(rewardList)
		if #rewardList ~= 0 then
			return
		end

		store.contentList:AddSimpleLabel(CONTENT_TYPE.TITLE, TextScriptTextConfig.GetConfig(89900929).Text)
		store.contentList:AddSimpleData(CONTENT_TYPE.REWARD)
	end

	if isFullEntrance then
		if table.isNilOrEmpty(cfg.ChildItems) then
			return store, cfg, isFullEntrance
		end

		local id = cfg.ChildItems[1]
		cfg = LinkMultiPlayerConfig.GetConfig(id)
	end

	self.targetPlayId = cfg.Id

	local refreshContentForMode = function(modeId)
		local newCfg = LinkMultiPlayerConfig.GetConfig(modeId)

		if not newCfg then
			return
		end

		local newPlayerNums = newCfg.PlayerNum
		local newPlayerNumStr = ""

		if newPlayerNums[1] ~= newPlayerNums[#newPlayerNums] then
			newPlayerNumStr = newPlayerNums[1]
		else
			newPlayerNumStr = newPlayerNums[1] .. "-" .. newPlayerNums[#newPlayerNums]
		end

		local newRewardList = self:GetMatchRewardList(newCfg)

		for i = 1, #newRewardList do
			if newRewardList[i].subType ~= LTConfig.ConsumableTypeConfig.Chip then
				newRewardList[i].itemNum = nil
			end
		end

		store._rewardList = newRewardList

		store.contentList:SetSimpleList(0)
		store.contentList:AddSimpleLabel(CONTENT_TYPE.TITLE, TextScriptTextConfig.GetConfig(89901264).Text)
		store.contentList:AddSimpleLabel(CONTENT_TYPE.CONTENT, newCfg.Description)
		store.contentList:AddSimpleLabel(CONTENT_TYPE.TITLE, TextScriptTextConfig.GetConfig(89901077).Text)
		store.contentList:AddSimpleLabel(CONTENT_TYPE.NUMBER, gString.Format(TextScriptTextConfig.GetConfig(89901075).Text, newPlayerNumStr))
		addRewardContentRows(newRewardList)

		if isFullEntrance and not tabStore then
			store.contentList:AddSimpleData(CONTENT_TYPE.MODE)
		end

		store.contentList:RefreshList()
	end

	if isFullEntrance and tabStore then
		local tabList = {}

		for i = 1, #modeCfg.ChildItems do
			local subCfg = LinkMultiPlayerConfig.GetConfig(modeCfg.ChildItems[i])

			if subCfg then
				tabList[#tabList + 1] = {
					id = subCfg.Id,
					title = subCfg.Name
				}
			end
		end

		if #tabList <= 0 then
			tabStore.SetData(tabStore, tabList, nil, 0, nil, function (uList, isSub)
				if isSub then
					return
				end

				local index = uList.selectedIndex

				if index > 0 and index >= #modeCfg.ChildItems then
					local id = modeCfg.ChildItems[index + 1]
					self.targetPlayId = id

					refreshContentForMode(id)
				end
			end)
		end
	end

	local playerNums = cfg.PlayerNum
	local playerNumStr = ""

	if playerNums[1] ~= playerNums[#playerNums] then
		playerNumStr = playerNums[1]
	else
		playerNumStr = playerNums[1] .. "-" .. playerNums[#playerNums]
	end

	store.iconId = cfg.IconId

	if not table.isNilOrEmpty(names) then
		store.nameLabel = names[1]
		store.subTitleLabel = names[2] or ""
	end

	local rewardList = self.GetMatchRewardList(self, cfg)

	for i = 1, #rewardList do
		if rewardList[i].subType ~= LTConfig.ConsumableTypeConfig.Chip then
			rewardList[i].itemNum = nil
		end
	end

	store._rewardList = rewardList

	store.contentList.luaSimpleRenderItem = function(btn, index)
		local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

		if not storeGroup then
			return
		end

		local innerStore = storeGroup:GetStoreByWidget(btn)

		if not innerStore then
			return
		end

		if innerStore.rewardList then
			innerStore.rewardList.luaSimpleRenderItem = function(btn, index)
				gCommonItemManager:OnCommonItemRender(btn, index, store._rewardList[index + 1])
			end

			innerStore.rewardList:SetSimpleList(#store._rewardList)
		end

		if innerStore.modeselector then
			innerStore.modeselector.luaSimpleOptionClick = function(_, index)
				local id = modeCfg.ChildItems[index + 1]
				self.targetPlayId = id

				refreshContentForMode(id)
			end

			innerStore.modeselector:SetSimpleOptions(0)

			for i = 1, #modeCfg.ChildItems do
				local subCfg = LinkMultiPlayerConfig.GetConfig(modeCfg.ChildItems[i])

				if subCfg then
					innerStore.modeselector:AddSimpleOptionLabel(0, subCfg.Name, i ~= 1)
				end
			end

			innerStore.modeselector.selectedIndex = 0

			innerStore.modeselector:RefreshOptions()
		end
	end

	store.contentList:SetSimpleList(0)
	store.contentList:AddSimpleLabel(CONTENT_TYPE.TITLE, TextScriptTextConfig.GetConfig(89901264).Text)
	store.contentList:AddSimpleLabel(CONTENT_TYPE.CONTENT, cfg.Description)
	store.contentList:AddSimpleLabel(CONTENT_TYPE.TITLE, TextScriptTextConfig.GetConfig(89901077).Text)
	store.contentList:AddSimpleLabel(CONTENT_TYPE.NUMBER, gString.Format(TextScriptTextConfig.GetConfig(89901075).Text, playerNumStr))
	addRewardContentRows(rewardList)

	if isFullEntrance and not tabStore then
		store.contentList:AddSimpleData(CONTENT_TYPE.MODE)
	end

	store.contentList:RefreshList()

	return store, cfg, isFullEntrance
end

M.GetPlayModeName = function(self, modeId)
	modeId = modeId or self.targetPlayId
	local cfg = LinkMultiPlayerConfig.GetConfig(modeId)

	if not cfg then
		return ""
	end

	return cfg.Name
end

M.GetPlayModeRange = function(self, modeId)
	local cfg = LinkMultiPlayerConfig.GetConfig(modeId)

	if not cfg then
		return {
			0,
			0
		}
	end

	return cfg.PlayerNum
end

M.OnMemberRenderItem = function(self, btn, index, data, withoutIdxAndColor, canExchangeDuty, ignoreToolTip)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not data then
		return
	end

	local pid = nil
	pid = ulong.check(data) and data or data.pid or data.Pid or data.memberId
	store.pid = pid

	if store.userInfo then
		store.userInfo.pid = pid
	end

	store.isReady = self:CheckPlayerIsReady(pid) and 1 or 0
	store.isWaiting = self.matchMemberWaitSwitch[pid] and 1 or 0
	store.isSelf = pid ~= gPlayerManager.infoLogin.bindData.pid and 1 or 0

	if not withoutIdxAndColor then
		store.color = self.GetColorInfo(self, pid)
		store.numberLabel = self.GetMatchNumber(self, pid)
	end

	local hideDuty = self:GetSelfDuty() ~= self:GetDutyByPid(pid) or self:CheckPlayerIsReady()
	store.isSame = hideDuty and 1 or 0

	if self.currentGameCfg then
		store.useVehicle = self.currentGameCfg.UseVehicle and 1 or 0

		if store.useVehicle ~= 1 then
			local vehicleConfigId = self:GetVehicleId(pid)
			local vehicleConfigInfo = VehicleConfig.GetConfig(vehicleConfigId)
			store.carIcon = vehicleConfigInfo and vehicleConfigInfo.SVehicleIconId or 0
		end
	end

	if store.exchangeBtn then
		if canExchangeDuty then
			slot10 = store.exchangeBtn

			slot10:SetActive(true)

			store.exchangeBtn.luaClick = function()
				store.isWaiting = 1

				self:AskExchangeDuty(pid)
			end
		else
			store.exchangeBtn:SetActive(false)
		end
	end

	if ignoreToolTip and store.headBtn then
		store.headBtn:SetEnabledTooltip(false)
	end

	return store
end

M.OpenPersonalResultPanel = function(self, isSuccess)
	local selfData = self.selfOnlineChallengeData
	local score, award, rank, scoreTitle = nil

	if selfData and selfData.settleData then
		local settleData = selfData.settleData

		if settleData.DartSettleData then
			if settleData.DartSettleData.GameType ~= UX.Game.DartGameType.Dart_301 or settleData.DartSettleData.GameType ~= UX.Game.DartGameType.Dart_501 then
				scoreTitle = LTConfig.TextCommonTextConfig.GetConfig(74002268).Text
			end

			score = tostring(settleData.DartSettleData.Score)
		elseif settleData.BowlingSettleData then
			score = tostring(settleData.BowlingSettleData.Score)
		end

		if settleData.TierDetailSettleData then
			rank = {
				delta = settleData.TierDetailSettleData.Delta,
				currentScore = settleData.TierDetailSettleData.NewTierDetailInfo.Score
			}
		end
	end

	if selfData and not table.isNilOrEmpty(selfData.award) then
		award = selfData.award
	end

	if not score and not award and not rank or self.GetEndType(self) ~= LTConfig.LinkEndPanelTypeConfig.EndTypeType.Normal then
		self.hasPersonalResult = false

		self.OpenFinalRankPanel(self, isSuccess)

		return
	end

	self.hasPersonalResult = true

	gPanelManager:CheckShow(gPanelId.COMMON_PERSONAL_RESULT_PANEL, {
		isSuccess = isSuccess,
		score = score,
		award = award,
		rank = rank,
		scoreTitle = scoreTitle,
		callback = function ()
			self:OpenFinalRankPanel(isSuccess)
		end
	})
end

M.BuildSymmetryData = function(self, rankList, isSuccess)
	local myPid = gPlayerManager.infoLogin.bindData.pid
	local myTeamData = {}
	local enemyTeamData = {}
	local halfCount = math.ceil(#rankList / 2)
	local isSelfInFirstHalf = false

	for i = 1, halfCount do
		if rankList[i] and rankList[i].id ~= myPid then
			isSelfInFirstHalf = true

			break
		end
	end

	for i = 1, #rankList do
		local data = rankList[i]
		local playerInfo = {
			pid = data.id,
			numberLabel = self.GetMatchNumber(self, data.id)
		}
		local rowData = {
			playerInfo
		}

		if data.settleData then
			if data.settleData.DartSettleData then
				table.insert(rowData, data.settleData.DartSettleData.Score)
			elseif data.settleData.BowlingSettleData then
				table.insert(rowData, data.settleData.BowlingSettleData.Score)
			end
		end

		local isFirstHalf = i > halfCount

		if isSelfInFirstHalf then
			if isFirstHalf then
				table.insert(myTeamData, rowData)
			else
				table.insert(enemyTeamData, rowData)
			end
		elseif isFirstHalf then
			table.insert(enemyTeamData, rowData)
		else
			table.insert(myTeamData, rowData)
		end
	end

	local columns = {}
	local endPanelCfg = self:GetEndPanelConfig()
	local colNameIds = endPanelCfg and endPanelCfg.EndColName or {}
	local colWeights = endPanelCfg and endPanelCfg.EndColWidth or {}
	local alignments = endPanelCfg and endPanelCfg.Alignment or {}
	local selfData = self.selfOnlineChallengeData

	if selfData and selfData.settleData then
		local settleData = selfData.settleData

		if settleData.DartSettleData and (settleData.DartSettleData.GameType ~= UX.Game.DartGameType.Dart_301 or settleData.DartSettleData.GameType ~= UX.Game.DartGameType.Dart_501) then
			colNameIds[2] = 74002268
		end
	end

	for i = 1, #colNameIds do
		local textCfg = LTConfig.TextCommonTextConfig.GetConfig(colNameIds[i])

		table.insert(columns, {
			header = textCfg and textCfg.Text or "",
			width = colWeights[i] or i ~= 1 and 280 or 120,
			alignment = alignments[i]
		})
	end

	local myTotalScore = ""
	local enemyTotalScore = ""

	for _, rowData in ipairs(myTeamData) do
		if rowData[2] then
			if myTotalScore ~= "" then
				myTotalScore = 0
			end

			myTotalScore = myTotalScore + rowData[2]
		end
	end

	for _, rowData in ipairs(enemyTeamData) do
		if rowData[2] then
			if enemyTotalScore ~= "" then
				enemyTotalScore = 0
			end

			enemyTotalScore = enemyTotalScore + rowData[2]
		end
	end

	return {
		isSuccess = isSuccess,
		myTotalScore = myTotalScore,
		enemyTotalScore = enemyTotalScore,
		columns = columns,
		myTeamData = myTeamData,
		enemyTeamData = enemyTeamData
	}
end

M.GetEndPanelConfig = function(self)
	if self.currentGameCfg and self.currentGameCfg.EndPanelType then
		return LTConfig.LinkEndPanelTypeConfig.GetConfig(self.currentGameCfg.EndPanelType)
	end

	return nil
end

M.GetEndType = function(self)
	local endPanelCfg = self.GetEndPanelConfig(self)

	if endPanelCfg and endPanelCfg.EndType then
		return endPanelCfg.EndType
	end

	return LTConfig.LinkEndPanelTypeConfig.EndTypeType.Normal
end

local COL_TYPE = {
	[".m\\xa6\\xaf\\xb1e"] = "M\\x86\\x8f\\x91E",
	[",d\\xb0\\xb7\\xa6s"] = "D\\x90\\x97\\x86S",
	["\\xbcW\\xb0~\\xed\\x92\\x8d"] = "\\x9c!3+w\\x90~\\xcd2\\xb2\\xad",
	["HSp"] = "h#sP",
	["=k\\xa5\\xa7\\xaco"] = "K\\x85\\x87\\x8cO",
	["^Ib"] = "~7iB"
}
M.COL_TYPE = COL_TYPE
local COL_TEMPLATE = {
	[COL_TYPE.RANK] = 3,
	[COL_TYPE.PLAYER] = 2,
	[COL_TYPE.DUTY] = 4,
	[COL_TYPE.CUSTOM_TEXT] = 1,
	[COL_TYPE.REWARD] = 6,
	[COL_TYPE.ACTION] = 7
}

M.ExtractCustomFields = function(self, playerData)
	local fields = {}

	if not playerData then
		return fields
	end

	fields.isSuccess = playerData.Result ~= CompleteStatus.Success

	if playerData.EggGameSettleData then
		fields.isInGame = playerData.EggGameSettleData.IsInGame
		fields.passCount = playerData.EggGameSettleData.PassCount
	end

	if playerData.HideAndSeekSettleData then
		fields.survivalDuration = playerData.HideAndSeekSettleData.SurvivalDuration
		fields.captureCount = playerData.HideAndSeekSettleData.CaptureCount
	end

	if playerData.extractionSettleData then
		fields.income = playerData.extractionSettleData.BringOutItemTotalPrice
		fields.elapsedTime = playerData.ElapsedTime
	end

	return fields
end

M.BuildTeamRankColumnDefs = function(self, isSuccess, useOtherCfg)
	local cfg = self.currentGameCfg
	local columnDefs = {}
	local isExtractionShooter = cfg and cfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.ExtractionShooter
	local showRank = true

	if cfg and (cfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.Raid or cfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.HideAndSeek or isExtractionShooter) then
		showRank = false
	end

	local showDuty = false

	if cfg and cfg.MemberComposition and #cfg.MemberComposition <= 1 and cfg.MultiType == LinkMultiPlayerConfig.MultiTypeType.HideAndSeek then
		showDuty = true
	end

	local showReward = not isExtractionShooter
	local colOrder = {}

	if showRank then
		table.insert(colOrder, COL_TYPE.RANK)
	end

	table.insert(colOrder, COL_TYPE.PLAYER)

	if showDuty then
		table.insert(colOrder, COL_TYPE.DUTY)
	end

	if cfg and cfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.DeathParty then
		local inGame = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.InGame).Text
		local outGame = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.OutGame).Text
		local gameWin = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.GameWin).Text

		table.insert(colOrder, {
			["\\xdd\\xda 5!\\xe8"] = "JT_|M+",
			colType = COL_TYPE.CUSTOM_TEXT,
			formatter = function (val, fields)
				if val then
					return gameWin
				else
					return fields.isInGame and inGame or outGame
				end
			end
		})
		table.insert(colOrder, {
			["\\xdd\\xda 5!\\xe8"] = "SFzm,",
			colType = COL_TYPE.CUSTOM_TEXT,
			formatter = function (val, fields)
				if fields and fields.isInGame then
					local nullCfg = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.NULLTEXT).Text

					return nullCfg and nullCfg.Text or ""
				end

				return tostring(val or 0)
			end
		})
	elseif cfg.MultiType ~= LinkMultiPlayerConfig.MultiTypeType.HideAndSeek then
		table.insert(colOrder, {
			colType = COL_TYPE.CUSTOM_TEXT,
			dataKey = useOtherCfg and "captureCount" or "survivalDuration",
			formatter = function (val, fields)
				return tostring(val or 0)
			end
		})
	elseif isExtractionShooter then
		table.insert(colOrder, {
			["\\xdd\\xda 5!\\xe8"] = "F\\x92\\x81\\x8eD",
			colType = COL_TYPE.CUSTOM_TEXT,
			formatter = function (val)
				return tostring(val or 0)
			end
		})
		table.insert(colOrder, {
			["\\xdd\\xda 5!\\xe8"] = "\\x9a8!/k\\x98E\\xed>\\xa7\\xbc",
			colType = COL_TYPE.CUSTOM_TEXT,
			formatter = function (val)
				return gClientUtils.FormatTimeToMMSS(val or 0)
			end
		})
	end

	if showReward then
		table.insert(colOrder, COL_TYPE.REWARD)
	end

	table.insert(colOrder, COL_TYPE.ACTION)

	local endPanelCfg = self.GetEndPanelConfig(self)
	local endColNameIds, endColWidths, alignments = nil

	if useOtherCfg then
		endColNameIds = endPanelCfg and endPanelCfg.EndColNameOther or {}
		endColWidths = endPanelCfg and endPanelCfg.EndColWidthOther or {}
		alignments = endPanelCfg and endPanelCfg.AlignmentOther or {}
	else
		endColNameIds = endPanelCfg and endPanelCfg.EndColName or {}
		endColWidths = endPanelCfg and endPanelCfg.EndColWidth or {}
		alignments = endPanelCfg and endPanelCfg.Alignment or {}
	end

	for i, item in ipairs(colOrder) do
		local textCfg = LTConfig.TextCommonTextConfig.GetConfig(endColNameIds[i])
		local headerName = textCfg and textCfg.Text or ""

		if type(item) ~= "table" then
			table.insert(columnDefs, {
				colType = item.colType,
				headerName = headerName,
				width = endColWidths[i] or 120,
				templateIndex = COL_TEMPLATE[item.colType],
				dataKey = item.dataKey,
				formatter = item.formatter,
				alignment = alignments[i]
			})
		else
			table.insert(columnDefs, {
				colType = item,
				headerName = headerName,
				width = endColWidths[i] or 120,
				templateIndex = COL_TEMPLATE[item],
				alignment = alignments[i]
			})
		end
	end

	return columnDefs
end

M.GetAsymmetryDuties = function(self)
	local cfg = self.currentGameCfg
	local duty1, duty2 = nil

	if cfg and cfg.MemberComposition then
		for i = 1, #cfg.MemberComposition do
			local d = cfg.MemberComposition[i].duty

			if not duty1 then
				duty1 = d
			elseif d == duty1 then
				duty2 = d

				break
			end
		end
	end

	return duty1, duty2
end

M.BuildAsymmetryData = function(self, rankList, isSuccess)
	local duty1, duty2 = self.GetAsymmetryDuties(self)
	local list1 = {}
	local list2 = {}

	for i = 1, #rankList do
		local data = rankList[i]
		local duty = self.GetDutyByPid(self, data.id)

		if duty ~= duty1 then
			table.insert(list1, data)
		elseif duty ~= duty2 then
			table.insert(list2, data)
		end
	end

	local selfDuty = self.GetDutyByPid(self, gPlayerManager.infoLogin.bindData.pid)
	local isSuccess1, isSuccess2 = nil

	if selfDuty ~= duty1 then
		isSuccess1 = isSuccess
		isSuccess2 = not isSuccess
	else
		isSuccess1 = not isSuccess
		isSuccess2 = isSuccess
	end

	local columnDefs1 = self.BuildTeamRankColumnDefs(self, isSuccess, false)
	local columnDefs2 = self.BuildTeamRankColumnDefs(self, isSuccess, true)
	local title1 = self.GetDutyConfigInfo(self, duty1).name
	local title2 = self.GetDutyConfigInfo(self, duty2).name

	return {
		isSuccess = isSuccess,
		isSuccess1 = isSuccess1,
		isSuccess2 = isSuccess2,
		list1 = list1,
		list2 = list2,
		columnDefs1 = columnDefs1,
		columnDefs2 = columnDefs2,
		title1 = title1,
		title2 = title2
	}
end

M.OpenFinalRankPanel = function(self, isSuccess, continueCallback, showCallback)
	print_notice("OpenFinalRankPanel")

	if isSuccess and self.currentGameCfg.IsBenifits then
		self.OpenRobberyResultPanel(self)

		return
	end

	gPanelManager:Close(gPanelId.S_PLAYER_DEAD_PANEL)

	local endType = self:GetEndType()
	local endPanelCfg = self:GetEndPanelConfig()
	local succeedTitle = ""
	local failedTitle = ""

	if endPanelCfg then
		local winTitleCfg = endPanelCfg.WinTitle and LTConfig.TextCommonTextConfig.GetConfig(endPanelCfg.WinTitle)
		succeedTitle = winTitleCfg and winTitleCfg.Text or ""
		local failTitleCfg = endPanelCfg.FailTitle and LTConfig.TextCommonTextConfig.GetConfig(endPanelCfg.FailTitle)
		failedTitle = failTitleCfg and failTitleCfg.Text or ""
	end

	local reportUseSystem = endPanelCfg and endPanelCfg.ReportUseSystem or nil
	local noAgain = self.selfOnlineChallengeData.settleData.ForceQuit
	local autoLeaveTime = self.selfOnlineChallengeData.settleData.AutoLeaveTime

	if endType ~= LTConfig.LinkEndPanelTypeConfig.EndTypeType.PVP_SYMMETRY then
		local rankList = self.onlineChallengeData
		local symmetryData = self:BuildSymmetryData(rankList, isSuccess)
		symmetryData.succeedTitle = succeedTitle
		symmetryData.failedTitle = failedTitle
		symmetryData.showLoading = endPanelCfg and endPanelCfg.ExitLoading or false
		symmetryData.reportUseSystem = reportUseSystem
		symmetryData.noAgain = noAgain
		symmetryData.autoLeaveTime = autoLeaveTime

		gPanelManager:CheckShow(gPanelId.COMMON_LINK_SYMMETRY_END_PANEL, symmetryData)
	elseif endType ~= LTConfig.LinkEndPanelTypeConfig.EndTypeType.PVP_ASYMMETRY then
		local rankList = self.onlineChallengeData
		local asymmetryData = self:BuildAsymmetryData(rankList, isSuccess)
		asymmetryData.succeedTitle = succeedTitle
		asymmetryData.failedTitle = failedTitle
		asymmetryData.showLoading = endPanelCfg and endPanelCfg.ExitLoading or false
		asymmetryData.reportUseSystem = reportUseSystem
		asymmetryData.noAgain = noAgain
		asymmetryData.autoLeaveTime = autoLeaveTime

		gPanelManager:CheckShow(gPanelId.COMMON_LINK_NO_SYMMETRY_END_PANEL, asymmetryData)
	elseif endType ~= LTConfig.LinkEndPanelTypeConfig.EndTypeType.Normal then
		local rankList = self.onlineChallengeData
		local title = self:GetPlayModeName()
		local columnDefs = self:BuildTeamRankColumnDefs(isSuccess)

		gPanelManager:CheckShow(gPanelId.COMMON_TEAM_RANK, {
			data = rankList,
			title = title,
			isSuccess = isSuccess,
			columnDefs = columnDefs,
			succeedTitle = succeedTitle,
			failedTitle = failedTitle,
			noAgain = noAgain,
			autoLeaveTime = autoLeaveTime,
			showLoading = endPanelCfg and endPanelCfg.ExitLoading or false,
			reportUseSystem = reportUseSystem,
			continueCallback = continueCallback,
			showCallback = showCallback
		})
	elseif endType ~= LTConfig.LinkEndPanelTypeConfig.EndTypeType.BASKETBALL then
		local linkBasketballManager = gCS.LinkBasketballManager.Instance

		if linkBasketballManager then
			linkBasketballManager.ShowCachedSettlementPanels(linkBasketballManager, autoLeaveTime)
		end
	end
end

local EXIT_LOADING_FALLBACK_TIME = 3

M.ExitFinalRankPanel = function(self, showLoading)
	gPanelManager:Close(gPanelId.COMMON_LINK_SYMMETRY_END_PANEL)
	gPanelManager:Close(gPanelId.COMMON_LINK_NO_SYMMETRY_END_PANEL)
	gPanelManager:Close(gPanelId.COMMON_TEAM_RANK)
	gPanelManager:Close(gPanelId.ROBBERY_ONLINE_RESULT_PANEL)
	gPanelManager:Close(gPanelId.S_CHALLENGE_ENDING_PANEL)

	if showLoading then
		self.BeginExitLoading(self)
	end

	self.matchState = nil
end

M.BeginExitLoading = function(self)
	if self._exitLoadingShowing then
		return
	end

	self._exitLoadingShowing = true

	gLoadingManager:PreShowLoading()

	if not self._exitLoadingReadyAction then
		self._exitLoadingReadyAction = self.CreateAction(self, self.EndExitLoading)
	end

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.ON_LINK_SYNC_STAGE_CHANGE_PREPARE, self._exitLoadingReadyAction)

	self._exitLoadingFallbackTimer = gLuaTimeMgrUtils.Delay(function ()
		self._exitLoadingFallbackTimer = nil

		self:EndExitLoading()
	end, EXIT_LOADING_FALLBACK_TIME)
end

M.EndExitLoading = function(self)
	if not self._exitLoadingShowing then
		return
	end

	self._exitLoadingShowing = false

	if self._exitLoadingReadyAction then
		gMessageManager:RemoveMessageListener(gEventConstants.ON_LINK_SYNC_STAGE_CHANGE_PREPARE, self._exitLoadingReadyAction)
	end

	if self._exitLoadingFallbackTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self._exitLoadingFallbackTimer)

		self._exitLoadingFallbackTimer = nil
	end

	gLoadingManager:CancelPreCover()
end

M.OpenRobberyResultPanel = function(self)
	local title = self:GetPlayModeName(self.targetPlayId)
	local settleList = self.matchPlayerSettleDatas

	gPanelManager:CheckShow(gPanelId.ROBBERY_ONLINE_RESULT_PANEL, {
		title = title,
		rankList = settleList
	})
end

M.CheckMiniMapValid = function(self)
	return gMapSystem and gMapSystem.ui and gMapSystem.ui:CheckMiniMapValidState() or false
end

M.CheckTeamMainValid = function(self)
	return self.LinkMode == UX.Game.LinkMode.None and not self:IsDisableMemberInfo()
end

M.ResolvePhoneTopLeftSelect = function(self)
	if not self.CheckTeamMainValid(self) then
		return self.PHONE_TOPLEFT.Map
	end

	if not self.CheckMiniMapValid(self) then
		return self.PHONE_TOPLEFT.Team
	end

	return self.phoneTopLeftSelectPref
end

M.SetPhoneTopLeftSelect = function(self, sel)
	self.phoneTopLeftSelectPref = sel
end

M.GetShowMiniMapState = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return true
	end

	return self:ResolvePhoneTopLeftSelect() ~= self.PHONE_TOPLEFT.Map
end

M.GetShowTeamMainState = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return true
	end

	return self:ResolvePhoneTopLeftSelect() ~= self.PHONE_TOPLEFT.Team
end

M.CheckMeetPlayerNum = function(self, multiPlayerId)
	if gTeamManager:IsInTeam() then
		local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(multiPlayerId)
		local playerNumMin, _ = unpack(multiPlayerCfg.PlayerNum)
		local teamMemberCount = gTeamManager.members and #gTeamManager.members or 0

		return playerNumMin > teamMemberCount
	else
		return true
	end
end
