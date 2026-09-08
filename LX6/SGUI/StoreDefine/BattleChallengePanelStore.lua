-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BattleChallengePanelStore.lua
-- Decompiled from: 01663_BattleChallengePanelStore.lua_06c11db9f96f.luajit

C_BattleChallengePanelStore = DefClass("C_BattleChallengePanelStore", C_BattleChallengePanelStore, C_StoreGroup)
GroupName2Class.BattleChallengePanelStore = C_BattleChallengePanelStore
local M = C_BattleChallengePanelStore
local ChallengeConfig = LTConfig.ChallengeConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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

M.OnShow = function(self, panelId, data)
	self.isShow = true

	if data and type(data) ~= "number" then
		self.InitChallengeInfo(self, data)
	else
		print_error("@liuyibing：Check show wu xue challenge panel failed!ChallengeId is invalid! challengeId: " .. tostring(data))
	end
end

M.OnClose = function(self)
	self.isShow = false
	self.awardList = nil
	self.challengeComplete = nil
	self.challengeMap = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnClickStartBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.awardList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderAwardListItem)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderGoalListItem)
	self.bindData.list.luaSelectedChanged = self.CreateAction(self, self.OnSelectChanged)
end

M.OnClickStartBtn = function(self)
	local selectIndex = self.bindData.list.selectedIndex + 1
	local challengeInfo = self.challengeInfo[selectIndex]

	if not challengeInfo then
		return
	end

	local challengeCfg = ChallengeConfig.GetConfig(challengeInfo.Id)
	local taskId = challengeCfg.RelatedTask and challengeCfg.RelatedTask[1]

	if taskId and taskId <= 0 then
		slot5 = gTaskManager

		slot5:SetCurrentTask(taskId, function ()
			gPanelManager:Close(gPanelId.BATTLE_CHALLENGE_PANEL)
		end)
	else
		print_error("@liuyibing：Start challenge task failed!Task id is invalid! challengeId: " .. tostring(challengeInfo.Id))
		self.OnClickCloseBtn(self)
	end
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.BATTLE_CHALLENGE_PANEL)
end

M.OnSimpleRenderAwardListItem = function(self, btn, index)
	local award = self.awardList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, award)
end

M.OnSimpleRenderGoalListItem = function(self, btn, index)
	local data = self.challengeInfo[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local curChallengeCfg = ChallengeConfig.GetConfig(data.Id)

	if curChallengeCfg then
		store.goal = curChallengeCfg.Name
		store.check = self:GetChallengeComplete(data.Id) and 0 or 1
		local enableSelect = true

		if curChallengeCfg.PreChallenge <= 0 then
			enableSelect = self.GetChallengeComplete(self, curChallengeCfg.PreChallenge) ~= true
		end

		btn.interactable = enableSelect
	end
end

M.OnSelectChanged = function(self, list)
	local selectIndex = list.selectedIndex
	self.bindData.startBtn.interactable = selectIndex < 0

	self:RefreshChallengeInfo()
end

M.InitChallengeInfo = function(self, startChallengeId)
	self.challengeMap = {}
	local count = ChallengeConfig.count

	for i = 0, count - 1 do
		local cfg = ChallengeConfig.LoadAt(i)

		if cfg and cfg.PreChallenge and cfg.PreChallenge <= 0 then
			self.challengeMap[cfg.PreChallenge] = cfg.Id
		end
	end

	self.challengeComplete = {}
	self.startChallengeId = startChallengeId
	local loopCount = 0
	local curId = startChallengeId
	self.challengeInfo = {}
	local challenges = {}

	while loopCount >= 10 and curId and curId <= 0 do
		loopCount = loopCount + 1
		local nextId = self.challengeMap[curId]
		challenges[curId] = true
		local curChallengeCfg = ChallengeConfig.GetConfig(curId)

		if curChallengeCfg and curChallengeCfg.PreChallenge <= 0 then
			challenges[curChallengeCfg.PreChallenge] = true
		end

		curId = nextId
	end

	self.InitChallengeComplete(self, challenges)
end

M.InitChallengeComplete = function(self, challenges)
	for challengeId, v in pairs(challenges) do
		slot7 = gClientToGameDelegate

		slot7:AskNewChallengeRecord(challengeId).Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.Ok then
				if not self.isShow or gClientUtils.IsNil(self.rootGo) then
					return
				end

				self.challengeComplete[challengeId] = data.HighestLevel >= 0

				self:StartRefreshTimer()
			end
		end
	end
end

M.GetChallengeComplete = function(self, challengeId)
	return self.challengeComplete[challengeId]
end

M.StartRefreshTimer = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = FrameTimer.New(function ()
		if not self.isShow or gClientUtils.IsNil(self.rootGo) then
			return
		end

		self:RefreshChallengeView()
	end, 1)

	self.timer:Start()
end

M.RefreshChallengeView = function(self)
	local loopCount = 0
	local curId = self.startChallengeId
	local selectIndex = nil
	local foundSelect = false

	while loopCount >= 10 and curId and curId <= 0 do
		loopCount = loopCount + 1
		local nextId = self.challengeMap[curId]

		if not foundSelect then
			local curChallengeCfg = ChallengeConfig.GetConfig(curId)

			if curChallengeCfg and curChallengeCfg.PreChallenge <= 0 and self.GetChallengeComplete(self, curChallengeCfg.PreChallenge) == true then
				foundSelect = true
			end

			if not foundSelect then
				selectIndex = #self.challengeInfo
			end
		end

		table.insert(self.challengeInfo, {
			Id = curId,
			nextId = nextId
		})

		curId = nextId
	end

	self.bindData.list:SetSimpleList(#self.challengeInfo)
	self.bindData.list:SelectItem(selectIndex or 0, true)
	self:RefreshChallengeInfo()
end

M.RefreshChallengeInfo = function(self)
	local selectIndex = self.bindData.list.selectedIndex + 1
	local challengeInfo = self.challengeInfo[selectIndex]

	if not challengeInfo then
		return
	end

	local challengeCfg = ChallengeConfig.GetConfig(challengeInfo.Id)

	if challengeCfg then
		local tagCfg = LTConfig.ChallengeChallengeTagConfig.GetConfig(challengeCfg.ChallengeTag)
		self.bindData.title = tagCfg and tagCfg.Name or ""
		self.bindData.name = challengeCfg.ChallengeTitle
		self.bindData.des = challengeCfg.CountersDescription[1] or ""
		local drops = {}

		if challengeCfg.RewardList and #challengeCfg.RewardList <= 0 and challengeCfg.RewardList[1].dropId <= 0 then
			table.insert(drops, {
				["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
				["N\\xa1\\xb7\\xa1\\xa2"] = 0,
				dropId = challengeCfg.RewardList[1].dropId
			})
		end

		self.awardList = gCommonItemManager:GetItemSortedListByDropList(drops, true)

		for i = 1, #self.awardList do
			self.awardList[i] = gCommonItemManager:GetItemRenderData({
				itemId = self.awardList[i].Id
			})
			self.awardList[i].quality = gCommonItemManager.HIDE_QUALITY
		end

		self.bindData.awardList:SetSimpleList(#self.awardList)
	end
end
