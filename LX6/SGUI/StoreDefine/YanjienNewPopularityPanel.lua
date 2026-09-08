-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjienNewPopularityPanel.lua
-- Decompiled from: 01918_YanjienNewPopularityPanel.lua_6cf0de61614d.luajit

C_YanjienNewPopularityPanel = DefClass("C_YanjienNewPopularityPanel", C_YanjienNewPopularityPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjienNewPopularityPanel = C_YanjienNewPopularityPanel
local M = C_YanjienNewPopularityPanel

M.OnAwake = function(self)
	self.bindData.levelRewardButton.luaClick = self.CreateAction(self, "OnLevelRewardClick")
	self.bindData.memberCenterButton.luaClick = self.CreateAction(self, "OnMemberCenterClick")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.historyPositionCount = nil
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self.CreateAction(self, "RefreshPanelView")
	}
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	local popularityWidget = self.bindData.popularityWidget
	local store = gStoreManager:GetStoreGroup(popularityWidget.Store):GetStoreByWidget(popularityWidget)
	self.historyLineNode = store.historyLineNode
	self.splitLineNode = store.splitLineNode
	self.dotNode = store.dotNode
	self.popularityStore = store
	self.historyYAxisHeight = store.historyLineNode.rect.height
	local yList = LTConfig.TuiteConfig.PopularityChartY
	self.popularityMaxY = yList[#yList]
	self.bindData.popularityValue = gSocialNetworkUtils.GetCurrentPopularityValue()

	self.splitLineNode.gameObject:SetActive(false)
	self:RefreshPanelView()
end

M.RefreshPanelView = function(self)
	local historyPositionArray = gSocialNetworkUtils.RefreshPopularityView(self.bindData.popularityWidget)
	local historyPositionCount = historyPositionArray and #historyPositionArray or 0

	if historyPositionCount > 2 then
		self.historyPositionCount = historyPositionCount
		self.historyPositionArray = historyPositionArray
		self.axisMin = historyPositionArray[1].x
		self.axisMax = historyPositionArray[self.historyPositionCount].x
		local xAxisHourMax = gSocialNetworkUtils.GetHistoryXAxisMax()

		if xAxisHourMax < 4 then
			local store = gStoreManager:GetStoreGroup(self.bindData.popularityWidget.Store):GetStoreByWidget(self.bindData.popularityWidget)

			store.nowNode.gameObject:SetActive(true)

			store.nowNode.transform.localPosition = Vector2.Fetch(self.axisMax, historyPositionArray[self.historyPositionCount].y)
		end
	end

	self.RefreshFansView(self)
end

M.RefreshFansView = function(self)
	local fansWidget = self.bindData.commonFansLevel

	gSocialNetworkUtils.RefreshPlayerExpProgressView(fansWidget)

	local fansStore = gStoreManager:GetStoreGroup(fansWidget.Store):GetStoreByWidget(fansWidget)
	local fansCount = gPlayerManager.infoMinor.bindData.fan123
	fansStore.progressText = gClientUtils.FormatWithThousandsSeparator(fansCount)

	if gClientUtils.CheckHasLevelReward() then
		self.bindData.levelRewardText = LTConfig.TextScriptTextConfig.GetConfig(89901178).Text
	else
		local nextLevelReward = self.GetNextLevelReward(self)

		if nextLevelReward then
			self.bindData.levelRewardText = LTConfig.TextScriptTextConfig.GetConfig(89901176).Text:format(nextLevelReward)
		else
			self.bindData.levelRewardText = LTConfig.TextScriptTextConfig.GetConfig(89901177).Text
		end
	end

	local hasRedDot = gClientUtils.CheckHasLevelReward()

	self.bindData.levelRewardButton:SetActive(hasRedDot)
end

M.OnLevelRewardClick = function(self)
	local targetLevel = gClientUtils.GetPlayerLevel()
	local rootGo = nil
	slot3 = gClientToGameDelegate

	slot3:AskTakeLevelReward(targetLevel).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gPlayerManager.infoMinor.bindData.levelRewardList = {}

		gMessageManager:SendMessage(gEventConstants.ON_LEVEL_REWARD_UPDATE)

		if gClientUtils.IsNil(rootGo) then
			return
		end
	end
end

M.GetNextLevelReward = function(self)
	local currentLevel = gPlayerManager.infoMinor.bindData.level
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if currentLevel >= growthCfg.Lv and growthCfg.Drop <= 0 then
			return growthCfg.Lv
		end
	end
end

M.OnUpdate = function(self)
	if gCS.LuaUtils.RectangleContainsScreenPoint(self.bindData.pointerArea, UnityEngine.Input.mousePosition) then
		local localPosition = gCS.LuaUtils.TransformScreenPointToUI(self.historyLineNode, UnityEngine.Input.mousePosition)

		if self.historyPositionCount and localPosition.x < self.axisMax and self.axisMin < localPosition.x then
			self.splitLineNode.gameObject:SetActive(true)

			self.splitLineNode.transform.localPosition = Vector2.Fetch(localPosition.x, 0)
			local dotPositionY = self:GetDotNodeLocalPositionY(localPosition.x)
			self.dotNode.transform.localPosition = Vector2.Fetch(0, dotPositionY)
			local dotPopularityValue = self:GetDotPopularityValue(dotPositionY)
			self.popularityStore.popularityValue = LTConfig.TextScriptTextConfig.GetConfig(89901182).Text:format(dotPopularityValue)
		else
			self.splitLineNode.gameObject:SetActive(false)
		end
	else
		self.splitLineNode.gameObject:SetActive(false)
	end
end

M.GetDotPopularityValue = function(self, dotPositionY)
	if dotPositionY >= 0 then
		return 0
	end

	if dotPositionY <= 1000 then
		return 1000
	end

	return math.floor(dotPositionY / self.historyYAxisHeight * self.popularityMaxY)
end

M.GetDotNodeLocalPositionY = function(self, axisX)
	for i = 1, self.historyPositionCount - 1 do
		if self.historyPositionArray[i].x < axisX and axisX >= self.historyPositionArray[i + 1].x then
			local t = (axisX - self.historyPositionArray[i].x) / (self.historyPositionArray[i + 1].x - self.historyPositionArray[i].x)

			return self.historyPositionArray[i].y + (self.historyPositionArray[i + 1].y - self.historyPositionArray[i].y) * t
		end
	end

	return self.historyPositionArray[self.historyPositionCount].y
end

M.OnMemberCenterClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.MemberCenter
	})
end
