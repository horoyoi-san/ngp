C_TrialPanelStore = DefClass("C_TrialPanelStore", C_TrialPanelStore, C_StoreGroup)
GroupName2Class.TrialPanelStore = C_TrialPanelStore
local M = C_TrialPanelStore

function M:OnAwake()
	self.instance = {
		panelId = 0,
		data = false,
		trialList = {},
		gameBuffList = {},
		gameGoalList = {},
		challengeRecordCache = {}
	}
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnExitBtnClick)
	self.bindData.enterBtn.luaClick = self:CreateAction(self.OnEnterBtnClick)
	self.bindData.gameBuffList.luaSimpleRenderItem = self:CreateAction(self.OnRenderGameBuffListItem)
	self.bindData.gameGoalList.luaSimpleRenderItem = self:CreateAction(self.OnRenderGameGoalListItem)
	self.bindData.gameStarList.luaSimpleRenderItem = self:CreateAction(self.OnRenderGameStarListItem)
end

function M:OnShow(panelId, data)
	data.doTrialDirectly = true
	self.instance.panelId = panelId
	self.instance.data = data
	self.instance.seasonId = (data or {}).seasonId
	self.instance.gamePlayId = (data or {}).gamePlayId
	local gamePlayCfg = LTConfig.InspireHubGamePlayConfig.GetConfig(self.instance.gamePlayId)
	self.instance.seasonGameplayId = gamePlayCfg.SeasonGamePlayId
	self.instance.gamePlayInfo = gInspireHubManager:GetGamePlayInfo(self.instance.seasonGameplayId) or {
		Stars = 0,
		GamePlayCfgId = self.instance.seasonGameplayId,
		ChallengeDict = {}
	}
	local frameTimer = FrameTimer.New(function ()
		if self.STATE_EnableOnce then
			self:InitStage2()
		end
	end, 1)

	frameTimer:Start()
end

function M:InitStage2()
	self.instance.gameList = self.bindData.scrollRect.content
	self.instance.gameList.luaRenderItem = self:CreateAction(self.OnRenderGameListItem)

	function self.instance.gameList.onGetTIndex()
		return 0
	end

	self.instance.gameList.luaClick = self:CreateAction(self.OnGameListItemClick)

	self:RefreshPageData()
end

function M:RefreshPageData()
	local gamePlayCfg = LTConfig.InspireHubGamePlayConfig.GetConfig(self.instance.gamePlayId)
	local seasonGameplayId = gamePlayCfg.SeasonGamePlayId
	local seasonGameplayCfg = LTConfig.InspireHubSeasonGamePlayConfig.GetConfig(seasonGameplayId)
	self.bindData.eventName = seasonGameplayCfg.Name
	self.bindData.eventDescription = seasonGameplayCfg.SeasonGamePlayDes
	self.bindData.eventTimeCountdown = gInspireHubManager:GetTimeCountDownStr()
	local trialList = self.instance.trialList
	local trialListLength = 0
	local posCfgList = LTConfig.SeasonTrialConfig.UINodePosList
	local maxPosX = -100000000
	local minPosX = 100000000
	local maxPosY = -100000000
	local minPosY = 100000000
	local canvasViewSize = self.bindData.scrollRect.rectTransform.rect.size
	local halfSizeY = canvasViewSize.y / 2
	local lastUnlockItemIndex = 1

	local function AddTrialListItem(seasonTrialCfg)
		local index = trialListLength + 1
		local nodePosX = LTConfig.SeasonTrialConfig.UINodeSpace * (index - 1) + LTConfig.SeasonTrialConfig.UICanvasPadding.x
		local nodePosIndex = index % #posCfgList

		if nodePosIndex == 0 then
			nodePosIndex = #posCfgList
		end

		local nodePosY = posCfgList[nodePosIndex] + halfSizeY
		maxPosX = math.max(maxPosX, nodePosX)
		minPosX = math.min(minPosX, nodePosX)
		maxPosY = math.max(maxPosY, nodePosY)
		minPosY = math.min(minPosY, nodePosY)

		if not self.instance.gamePlayInfo.ChallengeDict[seasonTrialCfg.ChallengeID] then
			local challengeInfo = {
				HistoryHighestStars = 0,
				LastStars = 0,
				ChallengeCfgId = seasonTrialCfg.Id
			}
		end

		local isUnlock = true

		if seasonTrialCfg.UnlockType == 1 then
			isUnlock = trialList[index - 1].challengeInfo.HistoryHighestStars > 0
		elseif seasonTrialCfg.UnlockType == 2 then
			isUnlock = gEventConditionUtils.CheckHasUnlocked(seasonTrialCfg, UX.Game.EventConditionImplModule.CompetitionSeasonChallenge)
		end

		if isUnlock then
			lastUnlockItemIndex = index
		end

		local trialItem = {
			cfg = seasonTrialCfg,
			index = index,
			posX = nodePosX,
			posY = nodePosY,
			isUnlock = isUnlock,
			challengeInfo = challengeInfo
		}
		trialList[index] = trialItem
		trialListLength = index
	end

	for i = 0, LTConfig.SeasonTrialConfig.count - 1 do
		local seasonTrialCfg = LTConfig.SeasonTrialConfig.LoadAt(i)

		if seasonTrialCfg.Season == self.instance.seasonId and seasonTrialCfg.SeasonGamePlay == seasonGameplayId and seasonTrialCfg.PrevStage == 0 then
			local cfgIt = seasonTrialCfg

			while cfgIt do
				AddTrialListItem(cfgIt)

				cfgIt = LTConfig.SeasonTrialConfig.GetConfig(cfgIt.NextStage)
			end

			break
		end
	end

	self.instance.canvasMaxPosX = maxPosX
	self.instance.canvasMaxPosY = maxPosY
	self.instance.canvasMinPosX = minPosX
	self.instance.canvasMinPosY = minPosY
	local sizeX = self.instance.canvasMaxPosX - self.instance.canvasMinPosX + LTConfig.SeasonTrialConfig.UICanvasPadding.x * 2
	sizeX = math.max(sizeX, canvasViewSize.x)
	local sizeY = self.instance.canvasMaxPosY - self.instance.canvasMinPosY
	sizeY = math.max(sizeY, canvasViewSize.y)

	self.instance.gameList:SetSize(Vector2.Fetch(sizeX, sizeY))
	self.instance.gameList:SetList(#trialList)

	self.instance.t_WaitForAsyncInstantiate_SelectItemIndex = lastUnlockItemIndex

	table.clear(self.instance.challengeRecordCache)

	for i = 1, #trialList do
		local data = trialList[i]

		if data.isUnlock then
			local challengeID = data.cfg.ChallengeID

			gChallengeManager:AskNewChallengeRecord(challengeID, function (record)
				self.instance.challengeRecordCache[challengeID] = record

				self:OnChallengeRecordUpdated(challengeID)
			end)
		end
	end
end

function M:OnDestroy()
	self.instance = nil
end

function M:OnExitBtnClick()
	gPanelManager:Close(self.instance.panelId)
end

function M:OnEnterBtnClick()
	local index = self.instance.selectIndex

	if index == nil then
		print_error("selectIndex is nil!")

		return
	end

	local data = self.instance.trialList[index]

	if (self.instance.data or {}).doTrialDirectly then
		local challengeID = data.cfg.ChallengeID
		local challengeCfg = LTConfig.ChallengeConfig.GetConfig(challengeID)
		local tasks = challengeCfg.RelatedTask
		local taskId = tasks and tasks[1]

		if taskId then
			gClientToGameDelegate:AskAcceptTask(taskId).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
					gMainPhoneUtils.CloseMainPhonePanel(true)
				else
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		else
			print_error("配表有误！RelatedTask 为空，ChallengeConfig=" .. tostring(challengeID))
		end

		return
	end

	local hyperLinkId = data.cfg.HyperLinkId
	local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	hyperLinkInfo.callback()
end

function M:SelectItem(index, btn, force)
	if self.instance.selectIndex == index and not force then
		return
	end

	if self.instance.selectIndex then
		local success, lastBtn = self.instance.gameList:TryGetChildAt(self.instance.selectIndex - 1, nil)

		if success then
			lastBtn:SetSelected(false)
		end
	end

	self.instance.selectIndex = index

	if btn == nil then
		local success = nil
		success, btn = self.instance.gameList:TryGetChildAt(index - 1, nil)

		if not success then
			return
		end
	end

	if gClientUtils.IsNil(btn) then
		print_error("select a nil button!", index, btn)

		return
	end

	btn:SetSelected(true)

	local data = self.instance.trialList[index]
	self.instance.currentSelectedGame = data
	local challengeID = data.cfg.ChallengeID
	local challengeCfg = LTConfig.ChallengeConfig.GetConfig(challengeID)
	self.bindData.gameName = challengeCfg.Name
	self.bindData.gameIndex = string.format("%02d", index)
	local record = self.instance.challengeRecordCache[challengeID]
	local paramData = (record or {}).ParamData or {}

	table.clear(self.instance.gameGoalList)

	for k, v in ipairs(challengeCfg.CountersDescription) do
		local goalItem = {
			text = v,
			isFinished = paramData[k - 1] or false
		}

		table.insert(self.instance.gameGoalList, goalItem)
	end

	self.bindData.gameGoalList:SetSimpleList(#self.instance.gameGoalList)
	self.bindData.gameStarList:SetSimpleList(#challengeCfg.CountersDescription)

	self.instance.gameBuffList = challengeCfg.BuffDescription

	self.bindData.gameBuffList:SetSimpleList(#self.instance.gameBuffList)
end

function M:OnChallengeRecordUpdated(challengeID)
	local selectIndex = self.instance.selectIndex

	if selectIndex then
		local data = self.instance.trialList[selectIndex]

		if data and data.cfg.ChallengeID == challengeID then
			self:SelectItem(selectIndex, nil, true)
		end
	end
end

function M:OnRenderGameListItem(btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.trialList[index]
	btn.rectTransform.anchoredPosition = Vector2.Fetch(data.posX - self.instance.canvasMinPosX, data.posY - self.instance.canvasMinPosY)
	btn.rectTransform.anchoredPosition = Vector2.Fetch(data.posX, data.posY)

	if self.instance.t_WaitForAsyncInstantiate_SelectItemIndex == index then
		self.instance.t_WaitForAsyncInstantiate_SelectItemIndex = nil

		self:SelectItem(index, btn)
		self:ScrollToIndex(index)
	end

	local store = self:GetStoreByWidget(btn)
	store.text = string.format("%02d", data.index)
	local isUnlock = data.isUnlock
	btn.interactable = isUnlock

	if self.instance.selectIndex == index then
		btn:SetSelected(true)
	end

	if isUnlock then
		local isFinished = data.challengeInfo.HistoryHighestStars == 3
		store.finishCtrl = isFinished and 1 or 0
		local starCount = data.challengeInfo.HistoryHighestStars
		local totalStarCount = 3

		function store.starList.luaSimpleRenderItem(starBtn, starCsIndex)
			self:GetStoreByWidget(starBtn).finishCtrl = starCsIndex + 1 <= starCount and 0 or 1
		end

		store.starList:SetSimpleList(totalStarCount)
	end
end

function M:OnGameListItemClick(btn, csIndex)
	local index = csIndex + 1

	self:SelectItem(index, btn)
end

function M:OnRenderGameBuffListItem(btn, csIndex)
	local data = self.instance.gameBuffList[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.text = data
end

function M:OnRenderGameGoalListItem(btn, csIndex)
	local data = self.instance.gameGoalList[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.text = data.text
	store.finishCtrl = data.isFinished and 0 or 1
end

function M:OnRenderGameStarListItem(btn, csIndex)
	local store = self:GetStoreByWidget(btn)
	local historyHighestStars = (((self.instance or {}).currentSelectedGame or {}).challengeInfo or {}).HistoryHighestStars or 0
	store.finishCtrl = csIndex < historyHighestStars and 0 or 1
end

function M:ScrollToIndex(index)
	local data = self.instance.trialList[index]

	self:ScrollToPos(Vector2.Fetch(data.posX, data.posY))
end

function M:ScrollToPos(pos)
	local basePosX = self.instance.trialList[1].posX

	self.bindData.scrollRect:GoToPos(Vector2.Fetch(basePosX - pos.x, 0), true)
end
