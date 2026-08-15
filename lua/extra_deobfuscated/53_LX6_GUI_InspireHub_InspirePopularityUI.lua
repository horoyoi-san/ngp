local InspirePopularityUI = DefClass("C_InspirePopularityUI", GetClass("C_InspirePopularityUI"))
C_InspirePopularityUI = InspirePopularityUI

function InspirePopularityUI:InitConst()
	self.colorCtrlEnum = {
		up = 2,
		down = 1,
		normal = 0
	}
end

function InspirePopularityUI:GetPopularityInfoArray(timeSpan, sampleCount, currentHour)
	if self.popularityInfoArrayCache and self.popularityInfoArrayCacheTimeSpan == timeSpan and self.popularityInfoArrayCacheHour == currentHour then
		return self.popularityInfoArrayCache
	end

	timeSpan = timeSpan * 3600
	local currentTime = gCS.TimeManager.ServerUnixTime
	currentTime = math.floor(currentTime)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo == nil then
		return nil
	end

	local historyList = table.shallow_clone(popularityInfo.HistoryPopularityList)

	table.insert(historyList, {
		Time = currentTime,
		Value = popularityInfo.Popularity
	})

	local startTime = currentTime - timeSpan
	local timeInterval = 3600
	local resultArray = table.createFixedArray(sampleCount)

	for i = 1, sampleCount do
		local sampleTime = startTime + (i - 1) * timeInterval
		local sampleValue = gInspireHubUtils._interpolatePopularity(historyList, sampleTime)

		table.insert(resultArray, {
			Time = sampleTime,
			Value = sampleValue
		})
	end

	self.popularityInfoArrayCache = resultArray
	self.popularityInfoArrayCacheTimeSpan = timeSpan
	self.popularityInfoArrayCacheHour = currentHour

	return resultArray
end

function InspirePopularityUI:FindCoinReward(timestamp)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local pastHoursCoinRewards = popularityInfo and popularityInfo.PastHoursCoinRewards

	if pastHoursCoinRewards == nil or #pastHoursCoinRewards == 0 then
		return 0
	end

	local moneyData, _ = array.find_if(pastHoursCoinRewards, function (data)
		return data.Date == timestamp
	end)

	return moneyData and moneyData.Reward or 0
end

function InspirePopularityUI:OnRenderPopularityListItem(btn, csIndex)
	local index = csIndex + 1
	local data = self.popularityInfoArray[index + 1]
	local uGradient = btn:GetComponentInChildren(typeof(SGUI.Effect.UGradient))

	gInspireHubUtils.SetUGradientScaleY(uGradient, data.Value / gInspireHubUtils.GetPopularityInfoMaxY())

	if self.simpleMode then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		function btn.luaHover()
			UpdateBeat:AddListener(self.hoverUpdateHandler)
			self:ShowInfoWidget(index, true)
		end

		function btn.luaUnhover()
			UpdateBeat:RemoveListener(self.hoverUpdateHandler)
			self:HideInfoWidget()
		end
	else
		function btn.luaClick()
			self:ShowInfoWidget(index, true)
		end
	end

	local btnTransformInfo = {
		btn = btn,
		visible = data.Value > 0
	}

	table.insert(self.btnTransformInfoList, btnTransformInfo)
end

function InspirePopularityUI:OnPopularityListLayoutSet()
	for i, v in ipairs(self.btnTransformInfoList) do
		local btn = v.btn
		local rect = btn.rectTransform.rect
		local btnLocalPos = self.baseTransform:InverseTransformPoint(btn.rectTransform.position)
		local halfWidth = rect.width / 2
		v.startX = btnLocalPos.x - halfWidth
		v.endX = btnLocalPos.x + halfWidth
	end
end

function InspirePopularityUI:RenderInspirePopularityChart(widget, isPhoneAppIcon)
	self.bDestroy = false
	local chartStore = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	self.chartStore = chartStore

	if isPhoneAppIcon then
		self.simpleMode = true
		chartStore.popularityList.visibility = SGUI.EVisibility.HitTestInvisible

		chartStore.backgroundBtn:SetActive(false)
	else
		self.simpleMode = false

		self:InitHotInfo(widget, chartStore)
		chartStore.backgroundBtn:SetActive(true)

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			chartStore.popularityList.visibility = SGUI.EVisibility.HitTestInvisible
		end
	end

	self:RemoveListeners()

	self.OnHourChangeHandler = self:CreateAction(self.OnHourChanged)
	local dateTime = gCS.TimeManager.ServerDateTime
	local currentHour = dateTime.Hour
	self.refreshHour = currentHour

	self:RegisterForNextHour()

	function self.onPlayerPopularityChangeHandler()
		if self.bDestroy == false then
			local dateTimeNew = gCS.TimeManager.ServerDateTime

			self:RefreshUI(dateTimeNew, dateTimeNew.Hour)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.ON_PLAYER_POPULARITY_CHANGE, self.onPlayerPopularityChangeHandler)
	self:RefreshUI(dateTime, currentHour)
end

function InspirePopularityUI:RefreshUI(dateTime, currentHour)
	local chartStore = self.chartStore
	local currentPopularity = gSocialNetworkUtils.GetCurrentPopularityValue()
	chartStore.popularity = tostring(currentPopularity)
	local yesterdayAvgPopularity = gInspireHubUtils.GetYesterdayAvgPopularity()

	if yesterdayAvgPopularity < 1 or currentPopularity < yesterdayAvgPopularity then
		yesterdayAvgPopularity = 1
		chartStore.popularityIncreaseCtrl = 0
	else
		local popularityIncrease = currentPopularity / yesterdayAvgPopularity - 1
		chartStore.popularityIncreaseCtrl = 1
		chartStore.popularityIncrease = string.format("%.1f%%", popularityIncrease * 100)
	end

	if not self.simpleMode then
		self:RefreshBarChart(dateTime, currentHour)
	end
end

function InspirePopularityUI:RefreshBarChart(dateTime, currentHour)
	local chartStore = self.chartStore
	local displayCount = 24
	local currentMinute = dateTime.Minute
	local timeSpan = displayCount - 1 + currentMinute / 60
	local totalSampleCount = displayCount + 1
	self.popularityInfoArray = self:GetPopularityInfoArray(timeSpan, totalSampleCount, currentHour)

	if self.popularityInfoArray == nil then
		if gClientUtils.NotNil(chartStore.popularityList) then
			chartStore.popularityList:SetSimpleList(0)
		end

		return
	end

	chartStore.popularityList.luaSimpleRenderItem = self:CreateAction(self.OnRenderPopularityListItem)

	if not self.simpleMode then
		chartStore.popularityList.luaLayoutSet = self:CreateAction(self.OnPopularityListLayoutSet)
	end

	chartStore.popularityList:SetSimpleList(displayCount)

	local xLabelCount = 4

	for i = 1, xLabelCount do
		local fieldName = "xAxisLabel" .. tostring(i)
		chartStore[fieldName] = (currentHour + 25 - 24 * (xLabelCount - i + 1) / xLabelCount) % 24
	end

	local maxPopularity = gInspireHubUtils.GetPopularityInfoMaxY()
	local yLabelCount = 4

	for i = 1, yLabelCount do
		local fieldName = "yAxisLabel" .. tostring(i)
		chartStore[fieldName] = maxPopularity * (yLabelCount - i + 1) / yLabelCount
	end
end

function InspirePopularityUI:OnHourChanged()
	if self.bDestroy then
		return
	end

	self.delayRegisterTimer = FrameTimer.New(function ()
		self:RegisterForNextHour()

		self.delayRegisterTimer = nil
	end, 1)

	self.delayRegisterTimer:Start()

	self.refreshHour = self.refreshHour + 1

	self:RefreshUI(gCS.TimeManager.ServerDateTime, self.refreshHour)
end

function InspirePopularityUI:RegisterForNextHour()
	if self.bDestroy then
		return
	end

	gTimeNotificationManager:Unregister(self.OnHourChangeHandler)

	local nextHour = self.refreshHour + 1

	gTimeNotificationManager:Register(nextHour, 0, self.OnHourChangeHandler)
end

function InspirePopularityUI:CalcDataList(index)
	local currentData = self.popularityInfoArray[index]
	local sampleCount = #self.popularityInfoArray
	local isLast = index == sampleCount
	local timeText = nil
	local currentTime = gCS.TimeManager.ServerDateTime
	local currentHour = currentTime.Hour

	if isLast then
		timeText = string.format("%02d:%02d", currentHour, currentTime.Minute)
	else
		local startHour = (currentHour - (sampleCount - index) + 24) % 24
		local endHour = (startHour + 1) % 24
		timeText = string.format("%02d:00-%02d:00", startHour, endHour)
	end

	local inspireChangeAmount, inspireChangeRate = nil
	local inspireChangeColorCtrl = self.colorCtrlEnum.normal
	local prevData = self.popularityInfoArray[index - 1]
	local prevValue = prevData.Value
	inspireChangeAmount = currentData.Value - prevValue

	if prevValue >= 1 then
		inspireChangeRate = inspireChangeAmount / prevValue * 100
	end

	if inspireChangeAmount > 0 then
		inspireChangeColorCtrl = self.colorCtrlEnum.up
	elseif inspireChangeAmount < 0 then
		inspireChangeColorCtrl = self.colorCtrlEnum.down
	end

	local moneyChangeColorCtrl = self.colorCtrlEnum.normal
	local nowDate = LTUtils.UXTime.GetNowDateTime()
	local startHourTimestamp = gTimeUtils:GetUnixTime(nowDate.Year, nowDate.Month, nowDate.Day, nowDate.Hour, 0, 0)
	startHourTimestamp = startHourTimestamp - 3600 * (sampleCount - index)
	local money = self:FindCoinReward(startHourTimestamp)
	local lastMoney = self:FindCoinReward(startHourTimestamp - 3600)
	local diff = money - lastMoney

	if diff > 0 then
		moneyChangeColorCtrl = self.colorCtrlEnum.up
	elseif diff < 0 then
		moneyChangeColorCtrl = self.colorCtrlEnum.down
	end

	local dataList = {
		{
			title = LTConfig.InspireHubConfig.UITextInfoTime,
			data = timeText
		},
		{
			title = LTConfig.InspireHubConfig.UITextInfoHeatValue,
			data = math.floor(currentData.Value)
		},
		{
			title = LTConfig.InspireHubConfig.UITextInfoChangeAmount,
			colorCtrl = inspireChangeColorCtrl,
			data = math.ceil(inspireChangeAmount)
		}
	}

	if inspireChangeRate then
		table.insert(dataList, {
			title = LTConfig.InspireHubConfig.UITextInfoChangeRate,
			colorCtrl = inspireChangeColorCtrl,
			data = string.format("%+.1f%%", inspireChangeRate)
		})
	end

	if isLast or money > 0 then
		table.insert(dataList, {
			title = isLast and LTConfig.InspireHubConfig.UITextInfoCurrentPeriodProfit or LTConfig.InspireHubConfig.UITextInfoCoinProfit,
			colorCtrl = moneyChangeColorCtrl,
			data = money
		})
	end

	return dataList
end

function InspirePopularityUI:ShowInfoWidget(btnIndex, setPosToBarTopRight)
	if self.currentInfoWidgetShowIndex == btnIndex then
		return
	end

	self.currentInfoWidgetShowIndex = btnIndex
	self.dataList = self:CalcDataList(btnIndex + 1)

	self.infoStore.list:SetSimpleList(#self.dataList)
	self.infoWidget:SetActive(true)

	local currentSelectedBtn = self.btnTransformInfoList[btnIndex].btn

	if gClientUtils.NotNil(self.currentSelectedBtn) then
		self.currentSelectedBtn:SetSelected(false)
	end

	self.currentSelectedBtn = currentSelectedBtn

	if gClientUtils.IsControllerMode() then
		self.currentSelectedBtn:SetSelected(true)
	end

	if not setPosToBarTopRight then
		return
	end

	local barTrans = currentSelectedBtn.rectTransform:GetChild(0)
	local rect = barTrans.rect
	local localRightTop = Vector3.Fetch(rect.max.x, rect.max.y, 0)
	local rightTopPos = barTrans:TransformPoint(localRightTop)
	local infoWidgetTrans = self.infoWidget.rectTransform
	rightTopPos = infoWidgetTrans.parent:InverseTransformPoint(rightTopPos)
	infoWidgetTrans.localPosition = rightTopPos
end

function InspirePopularityUI:HideInfoWidget()
	self.lastInfoWidgetShowIndex = self.currentInfoWidgetShowIndex
	self.currentInfoWidgetShowIndex = nil

	if gClientUtils.NotNil(self.infoWidget) then
		self.infoWidget:SetActive(false)
	end

	if gClientUtils.NotNil(self.currentSelectedBtn) then
		self.currentSelectedBtn:SetSelected(false)
	end

	self.currentSelectedBtn = nil
end

function InspirePopularityUI:OnHoverUpdate()
	if self.bDestroy then
		return
	end

	local pointerPos = gCS.LuaUtils.GetPointerPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.baseTransform, pointerPos)
	self.infoWidget.rectTransform.localPosition = uiPos
end

function InspirePopularityUI:GetPressPositionX()
	local pointerPos = gCS.LuaUtils.GetPointerPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.baseTransform, pointerPos)

	return uiPos.x
end

function InspirePopularityUI:OnPressUpdate()
	if self.bDestroy then
		return
	end

	local pressPosX = self:GetPressPositionX()
	local item, index = array.find_if(self.btnTransformInfoList, function (v)
		return v.startX <= pressPosX and pressPosX <= v.endX
	end)

	if index and item.visible then
		self:ShowInfoWidget(index, false)

		local btnTrans = item.btn.rectTransform
		local rect = btnTrans.rect
		local localRightTop = Vector3.Fetch(rect.max.x, rect.max.y, 0)
		local rightTopPos = btnTrans:TransformPoint(localRightTop)
		local infoWidgetTrans = self.infoWidget.rectTransform
		rightTopPos = infoWidgetTrans.parent:InverseTransformPoint(rightTopPos)
		infoWidgetTrans.localPosition = rightTopPos
	else
		self:HideInfoWidget()
	end
end

function InspirePopularityUI:InitHotInfo(rootWidget, chartStore)
	self:InitConst()

	local infoWidget = chartStore.hotInfoWidget
	local storeGroup = gStoreManager:GetStoreGroup(infoWidget.Store)
	local infoStore = storeGroup:GetStoreByWidget(infoWidget)
	local baseTransform = rootWidget.rectTransform
	self.rootWidget = rootWidget
	self.infoStoreGroup = storeGroup
	self.infoStore = infoStore
	self.infoWidget = infoWidget
	self.baseTransform = baseTransform
	self.btnTransformInfoList = {}
	infoStore.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderInfoListItem)
	local backgroundBtn = chartStore.backgroundBtn

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.hoverUpdateHandler = UpdateBeat:CreateListener(self:CreateAction(self.OnHoverUpdate))
		self.stickUpdateHandler = UpdateBeat:CreateListener(self:CreateAction(self.OnStickUpdate))
		chartStore.navRespond.luaGamePadInputChanged = self:CreateAction(self.OnGamePadInputChanged)
		backgroundBtn.luaFocus = self:CreateActionWithArgs(self.GamePadShowInfoWidget, 0)

		local function CloseInfoWidget()
			self:HideInfoWidget()

			if self.hoverUpdateHandler then
				UpdateBeat:RemoveListener(self.hoverUpdateHandler)
			end

			if self.pressUpdateHandler then
				UpdateBeat:RemoveListener(self.pressUpdateHandler)
			end

			if self.stickUpdateHandler then
				UpdateBeat:RemoveListener(self.stickUpdateHandler)
			end
		end

		infoStore.closeBtn.luaClick = CloseInfoWidget
		backgroundBtn.luaBlur = CloseInfoWidget

		infoStore.backgroundBtn:SetActive(false)
	else
		self.pressUpdateHandler = UpdateBeat:CreateListener(self:CreateAction(self.OnPressUpdate))

		function backgroundBtn.luaPress()
			UpdateBeat:AddListener(self.pressUpdateHandler)
		end

		function backgroundBtn.luaRelease()
			UpdateBeat:RemoveListener(self.pressUpdateHandler)
		end

		infoStore.backgroundBtn.luaClick = self:CreateAction(self.HideInfoWidget)
	end
end

function InspirePopularityUI:OnGamePadInputChanged(context)
	local x = context:ReadValueVector2().x

	if context.started then
		self:GamePadShowInfoWidget(x)

		self.gamePadInputStartTime = Time.unscaledTime
		self.gamePadInputDir = x
		self.gamePadRightStickX = x

		UpdateBeat:AddListener(self.stickUpdateHandler)
	elseif context.performed then
		self.gamePadRightStickX = x
	elseif context.canceled then
		UpdateBeat:RemoveListener(self.stickUpdateHandler)
	end
end

function InspirePopularityUI:GamePadShowInfoWidget(x)
	local initialSelectIndex = self.currentInfoWidgetShowIndex
	initialSelectIndex = initialSelectIndex and self:MoveIndex(initialSelectIndex, x) or self.lastInfoWidgetShowIndex or #self.btnTransformInfoList

	self:ShowInfoWidget(initialSelectIndex, true)
end

function InspirePopularityUI:OnStickUpdate()
	local longPressTime = 0.75
	local x = self.gamePadRightStickX

	if self.gamePadInputDir * x <= 0 then
		self.gamePadInputStartTime = Time.unscaledTime
		self.gamePadInputDir = x

		return
	end

	if Time.unscaledTime > self.gamePadInputStartTime + longPressTime then
		local nextSelectIndex = self:MoveIndex(self.currentInfoWidgetShowIndex, x)

		self:ShowInfoWidget(nextSelectIndex, true)
	end
end

function InspirePopularityUI:MoveIndex(index, dir)
	if dir > 0 then
		return math.min(index + 1, #self.btnTransformInfoList)
	elseif dir < 0 then
		return math.max(index - 1, 1)
	else
		return index
	end
end

function InspirePopularityUI:OnRenderInfoListItem(btn, csIndex)
	local index = csIndex + 1
	local btnStore = self.infoStoreGroup:GetStoreByWidget(btn)
	local data = self.dataList[index]
	btnStore.m_ImmediatelyCommit = true
	btnStore.title = data.title
	btnStore.data = data.data
	btnStore.colorCtrl = data.colorCtrl or self.colorCtrlEnum.normal
end

function InspirePopularityUI:RemoveListeners()
	if self.onPlayerPopularityChangeHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.ON_PLAYER_POPULARITY_CHANGE, self.onPlayerPopularityChangeHandler)
	end

	if self.delayRegisterTimer then
		self.delayRegisterTimer:Stop()
	end

	if self.OnHourChangeHandler then
		gTimeNotificationManager:Unregister(self.OnHourChangeHandler)
	end

	if self.hoverUpdateHandler then
		UpdateBeat:RemoveListener(self.hoverUpdateHandler)
	end

	if self.pressUpdateHandler then
		UpdateBeat:RemoveListener(self.pressUpdateHandler)
	end

	if self.stickUpdateHandler then
		UpdateBeat:RemoveListener(self.stickUpdateHandler)
	end
end

function InspirePopularityUI:Destroy()
	self:RemoveListeners()
	table.clear(self)

	self.bDestroy = true
end
