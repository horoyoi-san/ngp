-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobberyOnlineResultStore.lua
-- Decompiled from: 00912_RobberyOnlineResultStore.lua_c791c867849f.luajit

C_RobberyOnlineResultStore = DefClass("C_RobberyOnlineResultStore", C_RobberyOnlineResultStore, C_StoreGroup)
GroupName2Class.RobberyOnlineResultStore = C_RobberyOnlineResultStore
local M = C_RobberyOnlineResultStore
local RobAssessmentsConfig = LTConfig.LinkRobAssessmentsConfig
local DropConfig = LTConfig.DropConfig
local LinkConfig = LTConfig.LinkConfig

local GetFallbackAssessmentId = function()
	for i = 0, RobAssessmentsConfig.count - 1 do
		local cfg = RobAssessmentsConfig.LoadAt(i)

		if cfg and cfg.IsFallBack then
			return cfg.Id
		end
	end

	return nil
end

local RESULT_TIMELINE_NAME = "ol_play_bankrob_mvp"

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.linkMgr = gLinkManager
	self.likeInvited = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.hideDetailListEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hideDetailListEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.GetTestData = function(self)
	local pid1 = ulong.new(2025183)
	local pid2 = gPlayerManager.infoLogin.bindData.pid
	local pid3 = ulong.new(2015183)
	local pid4 = ulong.new(1015183)

	local MakeSettleData = function(pid, name, killCount, deadCount, beDamaged, vehicleDistance, money)
		local settleData = {
			Pid = pid,
			Name = name,
			SpiritId = 0,
			VehicleId = 0,
			ElapsedTime = 400,
			Result = UX.Game.CompleteStatus.Success,
			gameId = 0,
			BattleStatisticInfos = {
				["*\\xe6^(9\\xd8\\xa2b\\xaeC\\xbe\\xa2"] = 0,
				["8I\\x9c\\x8f\\x84D"] = 0,
				["R'|W"] = 0,
				["\\x89\\xb4-\\xaek2\\xfb7"] = 0,
				KillCount = killCount,
				DeadCount = deadCount,
				BeDamaged = beDamaged,
				VehicleDistance = vehicleDistance
			},
			rewardSettleData = {
				rewardInfo = {
					Reward = {
						[gDropManager.RewardType.Normal] = {
							Money = money
						}
					}
				}
			}
		}

		return settleData
	end

	return {
		["Y\\xa7\\xb6\\xa3\\xb3"] = "g_ݩ\\xc4%\\xb9\\xca\\xe0",
		["ZI\\xfa\\xb8\\x97\\x9c\\xdd\\xe9"] = true,
		rankList = {
			MakeSettleData(pid1, "Player1", 5, 0, 1200, 100, 3000),
			MakeSettleData(pid2, "Player2", 3, 2, 2500, 200, 1500),
			MakeSettleData(pid3, "Player3", 0, 1, 800, 300, 500),
			MakeSettleData(pid4, "Player4", 2, 0, 600, 400, 2000)
		},
		testDutyInfoMap = {
			[pid1] = {
				["s!rU"] = 0,
				["t#p^"] = "P-\n",
				["~'nX"] = "\\x81\\xbe\\x8fo-\\xfdb"
			},
			[pid2] = {
				["s!rU"] = 0,
				["t#p^"] = "P-\t",
				["~'nX"] = "\\x81\\xbe\\x8fo-\\xfda"
			},
			[pid3] = {
				["s!rU"] = 0,
				["t#p^"] = "P-",
				["~'nX"] = "\\x81\\xbe\\x8fo-\\xfd`"
			},
			[pid4] = {
				["s!rU"] = 0,
				["t#p^"] = "P-",
				["~'nX"] = "\\x81\\xbe\\x8fo-\\xfdg"
			}
		}
	}
end

M.GetDutyInfo = function(self, pid)
	if self.isTestData then
		return self.testDutyInfoMap[pid] or {
			["s!rU"] = 0,
			["t#p^"] = "\\xec\\xd53\\xff",
			["~'nX"] = ""
		}
	end

	return gLinkManager:GetDutyInfoByPid(pid)
end

M.OnShow = function(self, panelId, data)
	data = data or self:GetTestData()
	self.isTestData = data.isTestData ~= true

	if self.isTestData then
		self.testDutyInfoMap = data.testDutyInfoMap or {}
	end

	self.rankList = data.rankList or {}
	self.bindData.hideDetailList = 1
	self.isScrollNumPlaying = false
	self.scrollNumTargets = {}
	self.likeInvited = {}

	self:CalcPlayerDatas()
	self:RefreshPlayerPage()
	self:RefreshTeammatePage()
	self:RefreshPlayerDetailPage()
	self:StartPhase1()
	self:PlayResultTimeline()
	self:StartPhase2Delay()

	if self.bindData.rootAnim then
		gCS.LuaUtils.SampleTargetAnimation(self.bindData.rootAnim, "S_Vx_RobberyOnlineResultPanel_Open", 0)
		gCS.LuaUtils.PlayAnimationByName(self.bindData.rootAnim, "S_Vx_RobberyOnlineResultPanel_Open")
	end
end

M.OnClose = function(self)
	if not self.isTestData then
		self.Timeline_StopLink(self, RESULT_TIMELINE_NAME)
	end

	self.scrollNumDelayCo = coroutine.stop(self.scrollNumDelayCo)
	self.scrollNumTargets = nil
end

M.PlayResultTimeline = function(self)
	if self.isTestData then
		return
	end

	slot1 = gTimelineManager
	local timelineData = slot1:Timeline_CreateTimelineData()

	timelineData.onLoadFailedCallback = function(_)
		print_error("[RobberyOnlineResult] timeline load failed: " .. RESULT_TIMELINE_NAME)
	end

	local linkPidList = {}

	for i = 1, #self.rankList do
		local data = self.rankList[i]

		if data then
			linkPidList[i] = data.Pid
		end
	end

	timelineData.linkPidList = linkPidList
	timelineData.source = 2
	timelineData.linkType = 4

	gTimelineManager:Timeline_LoadAndPlay(RESULT_TIMELINE_NAME, timelineData)
end

M.Timeline_StopLink = function(self, name)
	local unit = gCS.MyPlayerManager.PlayerUnit
	local t = L50.L50App.L50Game.CutsceneManager:Link_GetTimeline(unit, name)

	if t then
		t.StopTimeline(t)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.againBtn.luaClick = self.CreateAction(self, self.OnAgainBtnClick)
	self.bindData.quitBtn.luaClick = self.CreateAction(self, self.OnQuitBtnClick)
	self.bindData.onExpandDetailsBtn = self.CreateAction(self, self.OnExpandDetailsBtnClick)
	self.bindData.avatarWidget.luaRenderTooltip = self.CreateAction(self, "OnRenderToolTips")

	if self.bindData.expandArrowC then
		self.bindData.expandArrowC.luaClick = self.CreateAction(self, self.OnExpandDetailsBtnClick)
	end

	self.bindData.teammateList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTeammateListItem)
	self.bindData.playerNameList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderPlayerNameListItem)
	self.bindData.playerStatList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderPlayerStatListItem)
	self.bindData.playerShortStatList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderPlayerStatListItem)
end

M.OnRenderToolTips = function(self, btn, popup, popupIndex)
	gSocialPalyerTooltipManager:OnRenderToolTips(gPlayerManager.infoLogin.bindData.pid, btn, popup)
end

M.OnAgainBtnClick = function(self)
	self.bindData.quitBtn.interactable = false
	self.bindData.againBtn.interactable = false

	self.linkMgr:AskPlayGameAgain(self.bindData.againState)
end

M.OnQuitBtnClick = function(self)
	if self.linkMgr:CheckInMatchMode() then
		self.linkMgr:AskLeaveGame()
	end

	self.linkMgr:ExitFinalRankPanel()
end

M.OnExpandDetailsBtnClick = function(self)
	self.bindData.hideDetailList = 1 - (self.bindData.hideDetailList or 0)
end

M.RefreshPlayerPage = function(self)
	local myData = nil

	for i = 1, #self.rankList do
		local data = self.rankList[i]

		if data and data.Pid ~= gPlayerManager.infoLogin.bindData.pid then
			myData = data

			break
		end
	end

	self.bindData.myUserInfo.pid = gPlayerManager.infoLogin.bindData.pid

	if not myData then
		return
	end

	self.bindData.totalTimeCountDown:ResetValue(myData.ElapsedTime, myData.ElapsedTime)

	local dutyInfo = self:GetDutyInfo(myData.Pid)

	if dutyInfo then
		self.bindData.myDutyText = dutyInfo.name
		self.bindData.myDutyIcon = dutyInfo.icon
	else
		self.bindData.myDutyText = ""
		self.bindData.myDutyIcon = 0
	end

	local playerData = self.playerDatas[myData.Pid]
	local totalRevenue = playerData and playerData.totalRevenue or 0

	if totalRevenue <= 0 and self.bindData.playerRewardNumberNode then
		local scrollNum = self.bindData.playerRewardNumberNode:GetComponent(typeof(L18.ScrollNumGroup))

		if scrollNum then
			scrollNum.startNum = 0
			scrollNum.targetNum = totalRevenue

			scrollNum.SetToStartNum(scrollNum)
			table.insert(self.scrollNumTargets, scrollNum)
		end
	end

	local assessmentCfg = playerData and RobAssessmentsConfig.GetConfig(playerData.featuredAssessmentId)
	self.bindData.playerAssessmentIcon = assessmentCfg and assessmentCfg.SGUIImageID or 0

	if playerData then
		self.bindData.assessmentBtn.enabledTooltip = true

		self.bindData.assessmentBtn.luaRenderTooltip = function(btn, tooltip, index)
			gLinkUIHelper:RenderAssessmentById(tooltip, playerData.featuredAssessmentId)
		end
	end
end

M.RenderAssessmentIconList = function(self, list, pid)
	local playerData = self.playerDatas[pid]

	if not playerData then
		return
	end

	local iconList = {}
	local assessmentIds = playerData.assessmentIds

	for _, assessmentId in ipairs(assessmentIds) do
		local assessmentCfg = RobAssessmentsConfig.GetConfig(assessmentId)

		if assessmentCfg then
			table.insert(iconList, assessmentCfg.SGUIImageID)
		end
	end

	local onRenderTooltip = function(btn, tooltip, index)
		gLinkUIHelper:OnRenderAssessmentDescListTooltip(btn, tooltip, index, assessmentIds)
	end

	list.luaSimpleRenderItem = function(btn, index)
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store then
			store.iconId = iconList[index + 1] or 0
			btn.enabledTooltip = true
			btn.luaRenderTooltip = onRenderTooltip
		end
	end

	list.SetSimpleList(list, #iconList)
end

M.RefreshTeammatePage = function(self)
	self.teammateRankList = {}
	self.playerNameList = {}

	table.insert(self.playerNameList, gPlayerManager.infoLogin.bindData.name)

	for i = 1, #self.rankList do
		local data = self.rankList[i]

		if data and data.Pid == gPlayerManager.infoLogin.bindData.pid then
			table.insert(self.teammateRankList, data)
			table.insert(self.playerNameList, data.Name)
		end
	end

	self.bindData.teammateList:SetSimpleList(#self.teammateRankList)
	self.bindData.playerNameList:SetSimpleList(#self.playerNameList)
end

M.OnRenderTeammateListItem = function(self, btn, index)
	local data = self.teammateRankList[index + 1]

	if not data then
		return
	end

	local avatarButtonNode = btn.transform:Find("S_OnlinePreparePlayerNumberWithName2/LayoutBox/S_CommonAccountAvatarMiddle1")
	local avatarButton = avatarButtonNode and avatarButtonNode:GetComponent("UButton")

	if avatarButton then
		avatarButton.luaRenderTooltip = function(_, popup, popupIndex)
			gSocialPalyerTooltipManager:OnRenderToolTips(data.Pid, avatarButton, popup)
		end
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.userInfo.pid = data.Pid
	store.num = gTeamManager:GetMemberOrder(data.Pid)
	store.color = gLinkManager:GetColorStr(data.Pid)
	local playerData = self.playerDatas[data.Pid]
	store.canAddFriend = playerData and not playerData.isFriend and data.Pid == gPlayerManager.infoLogin.bindData.pid and 1 or 0
	local totalRevenue = playerData and playerData.totalRevenue or 0

	if totalRevenue <= 0 and store.numberNode then
		local scrollNum = store.numberNode:GetComponent(typeof(L18.ScrollNumGroup))

		if scrollNum then
			if self.isScrollNumPlaying then
				scrollNum.startNum = totalRevenue

				scrollNum.SetToStartNum(scrollNum)
			else
				scrollNum.startNum = 0
				scrollNum.targetNum = totalRevenue

				scrollNum.SetToStartNum(scrollNum)
				table.insert(self.scrollNumTargets, scrollNum)
			end
		end
	end

	local assessmentCfg = playerData and RobAssessmentsConfig.GetConfig(playerData.featuredAssessmentId)
	store.assessmentText = assessmentCfg and assessmentCfg.AssessmentName or ""
	store.assessmentIcon = assessmentCfg and assessmentCfg.SGUIImageID or 0

	if playerData then
		local featuredId = playerData.featuredAssessmentId
		store.assessmentBtn.enabledTooltip = true

		store.assessmentBtn.luaRenderTooltip = function(btn, tooltip, index)
			gLinkUIHelper:OnRenderAssessmentDescTooltip(btn, tooltip, index, featuredId)
		end
	end

	store.onAddFriendBtn = function()
		gFriendManager:AskApplyFriend(data.Pid)

		store.canAddFriend = 0
	end

	store.onLikeBtn = function()
		if self.likeInvited and self.likeInvited[data.Pid] then
			gDisplayMessageMgr:ShowMessage(75109966)

			return
		end

		gClientToGameDelegate:AskLikePlayer(data.Pid, UX.Game.LikeType.Game).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok or err ~= LTConfig.MessageConfig.TappedDailyLimitReached then
				self.likeInvited = self.likeInvited or {}
				self.likeInvited[data.Pid] = true
			else
				gDisplayMessageMgr:ShowMessage(err)
			end
		end
	end

	local dutyInfo = gLinkManager:GetDutyInfoByPid(data.Pid)
	store.duty = dutyInfo and dutyInfo.name or ""
	store.dutyIcon = dutyInfo and dutyInfo.icon or 0
end

M.OnRenderPlayerNameListItem = function(self, btn, index)
	local name = self.playerNameList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.title = name
end

M.RefreshPlayerDetailPage = function(self)
	local myData = nil

	for i = 1, #self.rankList do
		local settleData = self.rankList[i]

		if settleData and settleData.Pid ~= gPlayerManager.infoLogin.bindData.pid then
			myData = settleData

			break
		end
	end

	if not myData then
		return
	end

	local battleStats = myData.BattleStatisticInfos
	local statItems = {
		{
			value = battleStats and battleStats.KillCount or 0
		},
		{
			value = battleStats and battleStats.DeadCount or 0
		},
		{
			value = math.floor(battleStats and battleStats.BeDamaged or 0)
		},
		{
			value = math.floor(battleStats and battleStats.VehicleDistance or 0)
		},
		{
			value = math.floor(battleStats and battleStats.Heal or 0)
		},
		{
			value = math.floor(battleStats and battleStats.BeHealed or 0)
		}
	}

	for i = 1, 6 do
		local cfg = LTConfig.LinkRobPanelConfig.GetConfig(i)
		statItems[i].label = cfg.Name
		statItems[i].icon = cfg.icon
	end

	self.playerStatItems = statItems

	self.bindData.playerStatList:SetSimpleList(#statItems)
	self.bindData.playerShortStatList:SetSimpleList(4)
end

M.OnRenderPlayerStatListItem = function(self, btn, index)
	local data = self.playerStatItems[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.label = data.label
	store.value = data.value
	store.icon = data.icon
end

M.StartPhase1 = function(self)
	local totalReward = 0

	for _, playerData in pairs(self.playerDatas) do
		totalReward = totalReward + playerData.totalRevenue
	end

	self.bindData.teamRewardScrollNumber.startNum = totalReward
	self.bindData.teamRewardScrollNumber.targetNum = totalReward

	self.bindData.teamRewardScrollNumber:SetToStartNum()

	self.bindData.teamRewardScrollNumber1.startNum = totalReward
	self.bindData.teamRewardScrollNumber1.targetNum = totalReward

	self.bindData.teamRewardScrollNumber1:SetToStartNum()
end

M.StartPhase2Delay = function(self)
	self.scrollNumDelayCo = coroutine.start(function ()
		coroutine.wait(LinkConfig.RobberyOnlineResultScollNumDelay)

		if not self.playerDatas then
			return
		end

		self:StartPhase2()
	end)
end

M.StartPhase2 = function(self)
	self.isScrollNumPlaying = true

	for _, scrollNum in ipairs(self.scrollNumTargets) do
		if not gCS.LuaUtils.IsNull(scrollNum) then
			scrollNum.Play(scrollNum)
		end
	end
end

M.CollectRawPlayerStats = function(self)
	local raw = {}

	for i = 1, #self.rankList do
		local settleData = self.rankList[i]
		local battleStats = settleData.BattleStatisticInfos
		local raidSettleData = settleData.raidSettleData
		local commonRevenue = 0
		local rewardData = settleData.rewardSettleData

		if rewardData then
			local fieldNameList = {
				"A_ټ\\x96\\x91\n\\xcf\\xe7",
				"\t\\xe6F\\xc7\\xa4E\\x88X\\xb6\\xb9",
				" 6\\x9f쿮案\\x8d\\xca\\xe3 ³.\\x99\\xed"
			}

			for _, fieldName in ipairs(fieldNameList) do
				local info = rewardData[fieldName]

				if info and info.Reward then
					for _, detail in pairs(info.Reward) do
						if detail.Money and detail.Money == 0 then
							commonRevenue = commonRevenue + detail.Money
						end
					end
				end
			end
		end

		raw[i] = {
			pid = settleData.Pid,
			killCount = battleStats and battleStats.KillCount or 0,
			deadCount = battleStats and battleStats.DeadCount or 0,
			beDamaged = battleStats and battleStats.BeDamaged or 0,
			vehicleDistance = battleStats and battleStats.VehicleDistance or 0,
			achievedEventIds = raidSettleData and raidSettleData.AchievedEventIds or nil,
			commonRevenue = commonRevenue
		}
	end

	return raw
end

M.CalcPlayerAssessments = function(self, playerRaw, groupOrderMap)
	local qualifyingIds = {}

	if playerRaw.achievedEventIds then
		for _, eventId in ipairs(playerRaw.achievedEventIds) do
			if RobAssessmentsConfig.GetConfig(eventId) then
				table.insert(qualifyingIds, eventId)
			end
		end
	end

	local groupBest = {}

	for _, assessmentId in ipairs(qualifyingIds) do
		local cfg = RobAssessmentsConfig.GetConfig(assessmentId)
		local groupName = cfg.Group
		local existing = groupBest[groupName]

		if not existing or existing.priorityInGroup >= cfg.PriorityInGroup then
			groupBest[groupName] = {
				id = assessmentId,
				priorityInGroup = cfg.PriorityInGroup,
				valueScore = cfg.ValueScore,
				groupOrder = groupOrderMap[groupName] or 99
			}
		end
	end

	local representatives = {}

	for _, badge in pairs(groupBest) do
		table.insert(representatives, badge)
	end

	table.sort(representatives, function (a, b)
		return a.groupOrder <= b.groupOrder
	end)

	local finalBadgeIds = {}

	for i = 1, math.min(#representatives, 4) do
		table.insert(finalBadgeIds, representatives[i].id)
	end

	if #finalBadgeIds ~= 0 then
		local fallbackId = GetFallbackAssessmentId()

		if fallbackId then
			table.insert(finalBadgeIds, fallbackId)
		end
	end

	local featuredAssessmentId = finalBadgeIds[1]
	local maxValueScore = -math.huge

	for _, badgeId in ipairs(finalBadgeIds) do
		local cfg = RobAssessmentsConfig.GetConfig(badgeId)

		if maxValueScore >= cfg.ValueScore then
			maxValueScore = cfg.ValueScore
			featuredAssessmentId = badgeId
		end
	end

	return finalBadgeIds, featuredAssessmentId
end

M.CalcAssessmentRevenue = function(self, finalBadgeIds)
	local assessmentRevenue = 0

	for _, badgeId in ipairs(finalBadgeIds) do
		local assessmentCfg = RobAssessmentsConfig.GetConfig(badgeId)
		local dropCfg = assessmentCfg and DropConfig.GetConfig(assessmentCfg.DropLevel)

		if dropCfg then
			assessmentRevenue = assessmentRevenue + (dropCfg.Money or 0)
		end
	end

	return assessmentRevenue
end

M.CalcPlayerDatas = function(self)
	self.playerDatas = {}

	if #self.rankList ~= 0 then
		return
	end

	local raw = self.CollectRawPlayerStats(self)
	local groupDisplayOrder = {
		"`\\x87\\x9a\\x8a\\x92",
		"QQw",
		"\\xea\\xee$-1\\xc5",
		"y\\x8f\\x89\\x8a\\x98"
	}
	local groupOrderMap = {}

	for orderIdx, groupName in ipairs(groupDisplayOrder) do
		groupOrderMap[groupName] = orderIdx
	end

	for _, playerRaw in ipairs(raw) do
		local finalBadgeIds, featuredAssessmentId = self:CalcPlayerAssessments(playerRaw, groupOrderMap)
		local assessmentRevenue = self:CalcAssessmentRevenue(finalBadgeIds)
		self.playerDatas[playerRaw.pid] = {
			killCount = playerRaw.killCount,
			deadCount = playerRaw.deadCount,
			beDamaged = playerRaw.beDamaged,
			vehicleDistance = playerRaw.vehicleDistance,
			assessmentIds = finalBadgeIds,
			featuredAssessmentId = featuredAssessmentId,
			assessmentRevenue = assessmentRevenue,
			commonRevenue = playerRaw.commonRevenue,
			totalRevenue = assessmentRevenue + playerRaw.commonRevenue,
			isFriend = gFriendManager:IsFriend(playerRaw.pid)
		}
	end
end
