-- Original chunk: @Lua\LuaFiles\LX6\GUI\InspireHub\InspirePopularityUI.lua
-- Decompiled from: 00248_InspirePopularityUI.lua_3451152a154f.luajit

local InspirePopularityUI = DefClass("C_InspirePopularityUI", GetClass("C_InspirePopularityUI"))
C_InspirePopularityUI = InspirePopularityUI

InspirePopularityUI.InitConst = function(self)
	self.colorCtrlEnum = {
		[""] = 2,
		["~-jU"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

InspirePopularityUI.GetPopularityInfoArray = function(self, timeSpan, sampleCount, currentHour)
	if self.popularityInfoArrayCache and self.popularityInfoArrayCacheTimeSpan ~= timeSpan and self.popularityInfoArrayCacheHour ~= currentHour then
		return self.popularityInfoArrayCache
	end

	timeSpan = timeSpan * 3600
	local currentTime = gCS.TimeManager.ServerUnixTime
	currentTime = math.floor(currentTime)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo ~= nil then
		return nil
	end

	local historyList = table.shallow_clone(popularityInfo.PastDaysHighestPopularityList or {})

	table.insert(historyList, {
		Time = currentTime,
		Value = popularityInfo.Popularity
	})

	local startTime = currentTime - timeSpan
	local timeInterval = 3600
	local resultArray = table.createFixedArray(sampleCount)
	local multiplier = 1

	for i = 1, sampleCount do
		local sampleTime = startTime + (i - 1) * multiplier * timeInterval
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

InspirePopularityUI.GetPopularitySevenDaysInfoArray = function(self)
	if self.popularityInfoArrayCache then
		return self.popularityInfoArrayCache
	end

	local popularityData = gHotCenterManager.GetSevenDaysPopularityData()
	local data = {}

	for i = 1, #popularityData do
		table.insert(data, {
			day = popularityData[i].day,
			Value = popularityData[i].popularity,
			Time = popularityData[i].time
		})
	end

	local temp = {
		Value = data[1].Value,
		Time = data[1].Time
	}

	table.insert(data, 1, temp)

	self.popularityInfoArrayCache = data

	return data
end

InspirePopularityUI.FindCoinReward = function(self, timestamp)
	return 0
end

InspirePopularityUI.OnRenderPopularityListItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.popularityInfoArray[index + 1]
	local uGradient = btn.GetComponentInChildren(btn, typeof(SGUI.Effect.UGradient))

	gInspireHubUtils.SetUGradientScaleY(uGradient, data.Value / gInspireHubUtils.GetPopularityInfoMaxY())

	if self.simpleMode then
		return
	end

	if self.infoStore then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			btn.luaHover = function()
				UpdateBeat:AddListener(self.hoverUpdateHandler)
				self:ShowInfoWidget(index, true)
			end

			btn.luaUnhover = function()
				UpdateBeat:RemoveListener(self.hoverUpdateHandler)
				self:HideInfoWidget()
			end
		else
			btn.luaClick = function()
				self:ShowInfoWidget(index, true)
			end
		end
	end

	local btnTransformInfo = {
		btn = btn,
		visible = data.Value >= 0
	}

	table.insert(self.btnTransformInfoList, btnTransformInfo)
end

InspirePopularityUI.OnPopularityListLayoutSet = function(self)
	for i, v in ipairs(self.btnTransformInfoList) do
		local btn = v.btn
		local rect = btn.rectTransform.rect
		local btnLocalPos = self.baseTransform:InverseTransformPoint(btn.rectTransform.position)
		local halfWidth = rect.width / 2
		v.startX = btnLocalPos.x - halfWidth
		v.endX = btnLocalPos.x + halfWidth
	end
end

InspirePopularityUI.RenderInspirePopularityChart = function(self, widget, isPhoneAppIcon)
	self.bDestroy = false
	local chartStore = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	self.chartStore = chartStore

	if isPhoneAppIcon then
		self.simpleMode = true
		chartStore.popularityList.visibility = SGUI.EVisibility.HitTestInvisible

		if chartStore.backgroundBtn then
			chartStore.backgroundBtn:SetActive(false)
		end
	else
		self.simpleMode = false

		self.InitHotInfo(self, widget, chartStore)

		if chartStore.backgroundBtn then
			chartStore.backgroundBtn:SetActive(true)
		end

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

	self.onPlayerPopularityChangeHandler = function()
		if self.bDestroy ~= false then
			local dateTimeNew = gCS.TimeManager.ServerDateTime

			self:RefreshUI(dateTimeNew, dateTimeNew.Hour)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.ON_PLAYER_POPULARITY_CHANGE, self.onPlayerPopularityChangeHandler)
	self:RefreshUI(dateTime, currentHour)
end

InspirePopularityUI.RefreshUI = function(self, dateTime, currentHour)
	local chartStore = self.chartStore
	local currentPopularity = gSocialNetworkUtils.GetCurrentPopularityValue()
	chartStore.popularity = tostring(currentPopularity)
	local yesterdayAvgPopularity = gInspireHubUtils.GetYesterdayAvgPopularity()

	if yesterdayAvgPopularity <= 1 or currentPopularity >= yesterdayAvgPopularity then
		yesterdayAvgPopularity = 1
		chartStore.popularityIncreaseCtrl = 0
	else
		local popularityIncrease = currentPopularity / yesterdayAvgPopularity - 1

		if popularityIncrease < 0 then
			chartStore.popularityIncreaseCtrl = 0
		else
			chartStore.popularityIncreaseCtrl = 1
			chartStore.popularityIncrease = string.format("%.1f%%", popularityIncrease * 100)
		end
	end

	if not self.simpleMode then
		if self.useDay then
			self.RefreshSevenDaysBarChart(self)
		else
			self.RefreshBarChart(self, dateTime, currentHour)
		end
	end
end

InspirePopularityUI.SetDisplayInfo = function(self, displayCount, useDay, xLabelCount)
	self.displayCount = displayCount
	self.useDay = useDay
	self.xLabelCount = xLabelCount
end

InspirePopularityUI.RefreshSevenDaysBarChart = function(self)
	local chartStore = self.chartStore
	local displayCount = self.displayCount or 24
	self.popularityInfoArray = self:GetPopularitySevenDaysInfoArray()

	if self.popularityInfoArray ~= nil then
		if gClientUtils.NotNil(chartStore.popularityList) then
			chartStore.popularityList:SetSimpleList(0)
		end

		return
	end

	chartStore.popularityList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderPopularityListItem)

	if not self.simpleMode then
		chartStore.popularityList.luaLayoutSet = self.CreateAction(self, self.OnPopularityListLayoutSet)
	end

	chartStore.popularityList:SetSimpleList(displayCount)

	local xLabelCount = self.xLabelCount or 4
	local nowTime = gCS.TimeManager.ServerUnixTime

	for i = 1, xLabelCount do
		local fieldName = "xAxisLabel" .. tostring(i)
		local curTime = nowTime - 86400 * (xLabelCount - i + 1) * (displayCount - 1) / xLabelCount
		local t = os.date("*t", curTime)
		chartStore[fieldName] = string.format("%d.%d", t.month, t.day)
	end

	local maxPopularity = gInspireHubUtils.GetPopularityInfoMaxY()
	local yLabelCount = 4

	for i = 1, yLabelCount do
		local fieldName = "yAxisLabel" .. tostring(i)
		chartStore[fieldName] = maxPopularity * (yLabelCount - i + 1) / yLabelCount
	end
end

InspirePopularityUI.RefreshBarChart = function(self, dateTime, currentHour)
	local chartStore = self.chartStore
	local displayCount = self.displayCount or 24
	local currentMinute = dateTime.Minute
	local multiplier = 1
	local timeSpan = displayCount * multiplier - 1 + currentMinute / 60
	local totalSampleCount = displayCount + 1
	self.popularityInfoArray = self:GetPopularityInfoArray(timeSpan, totalSampleCount, currentHour)

	if self.popularityInfoArray ~= nil then
		if gClientUtils.NotNil(chartStore.popularityList) then
			chartStore.popularityList:SetSimpleList(0)
		end

		return
	end

	chartStore.popularityList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderPopularityListItem)

	if not self.simpleMode then
		chartStore.popularityList.luaLayoutSet = self.CreateAction(self, self.OnPopularityListLayoutSet)
	end

	chartStore.popularityList:SetSimpleList(displayCount)

	local xLabelCount = self.xLabelCount or 4
	local nowTime = gCS.TimeManager.ServerUnixTime

	for i = 1, xLabelCount do
		local fieldName = "xAxisLabel" .. tostring(i)

		if self.useDay then
			local curTime = nowTime - 86400 * (xLabelCount - i + 1) * (displayCount - 1) / xLabelCount
			local t = os.date("*t", curTime)
			chartStore[fieldName] = string.format("%d.%d", t.month, t.day)
		else
			chartStore[fieldName] = (currentHour + 25 - 24 * (xLabelCount - i + 1) / xLabelCount) % 24
		end
	end

	local maxPopularity = gInspireHubUtils.GetPopularityInfoMaxY()
	local yLabelCount = 4

	for i = 1, yLabelCount do
		local fieldName = "yAxisLabel" .. tostring(i)
		chartStore[fieldName] = maxPopularity * (yLabelCount - i + 1) / yLabelCount
	end
end

InspirePopularityUI.OnHourChanged = function(self)
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

InspirePopularityUI.RegisterForNextHour = function(self)
	if self.bDestroy then
		return
	end

	gTimeNotificationManager:Unregister(self.OnHourChangeHandler)

	local nextHour = self.refreshHour + 1

	gTimeNotificationManager:Register(nextHour, 0, self.OnHourChangeHandler)
end

InspirePopularityUI.CalcDataList = function(self, index)
	local currentData = self.popularityInfoArray[index]
	local sampleCount = #self.popularityInfoArray
	local isLast = index ~= sampleCount
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

	if prevValue > 1 then
		inspireChangeRate = inspireChangeAmount / prevValue * 100
	end

	if inspireChangeAmount <= 0 then
		inspireChangeColorCtrl = self.colorCtrlEnum.up
	elseif inspireChangeAmount >= 0 then
		inspireChangeColorCtrl = self.colorCtrlEnum.down
	end

	local moneyChangeColorCtrl = self.colorCtrlEnum.normal
	local nowDate = LTUtils.UXTime.GetNowDateTime()
	local startHourTimestamp = gTimeUtils:GetUnixTime(nowDate.Year, nowDate.Month, nowDate.Day, nowDate.Hour, 0, 0)
	startHourTimestamp = startHourTimestamp - 3600 * (sampleCount - index)
	local money = self:FindCoinReward(startHourTimestamp)
	local lastMoney = self:FindCoinReward(startHourTimestamp - 3600)
	local diff = money - lastMoney

	if diff <= 0 then
		moneyChangeColorCtrl = self.colorCtrlEnum.up
	elseif diff >= 0 then
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

	if isLast or money <= 0 then
		table.insert(dataList, {
			title = isLast and LTConfig.InspireHubConfig.UITextInfoCurrentPeriodProfit or LTConfig.InspireHubConfig.UITextInfoCoinProfit,
			colorCtrl = moneyChangeColorCtrl,
			data = money
		})
	end

	return dataList
end

InspirePopularityUI.ShowInfoWidget = function(self, btnIndex, setPosToBarTopRight)
	if self.currentInfoWidgetShowIndex ~= btnIndex then
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

InspirePopularityUI.HideInfoWidget = function(self)
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

InspirePopularityUI.OnHoverUpdate = function(self)
	if self.bDestroy then
		return
	end

	local pointerPos = gCS.LuaUtils.GetPointerPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.baseTransform, pointerPos)
	self.infoWidget.rectTransform.localPosition = uiPos
end

InspirePopularityUI.GetPressPositionX = function(self)
	local pointerPos = gCS.LuaUtils.GetPointerPosition()
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.baseTransform, pointerPos)

	return uiPos.x
end

InspirePopularityUI.OnPressUpdate = function(self)
	if self.bDestroy then
		return
	end

	local pressPosX = self.GetPressPositionX(self)
	local item, index = array.find_if(self.btnTransformInfoList, function (v)
		return v.startX < pressPosX and pressPosX > v.endX
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
		self.HideInfoWidget(self)
	end
end

InspirePopularityUI.InitHotInfo = function(self, rootWidget, chartStore)
	self.InitConst(self)

	self.rootWidget = rootWidget
	local baseTransform = rootWidget.rectTransform
	self.baseTransform = baseTransform
	self.btnTransformInfoList = {}

	if not chartStore.hotInfoWidget then
		return
	end

	local infoWidget = chartStore.hotInfoWidget
	local storeGroup = gStoreManager:GetStoreGroup(infoWidget.Store)
	local infoStore = storeGroup:GetStoreByWidget(infoWidget)
	self.infoStoreGroup = storeGroup
	self.infoStore = infoStore
	self.infoWidget = infoWidget
	infoStore.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderInfoListItem)
	local backgroundBtn = chartStore.backgroundBtn

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.hoverUpdateHandler = UpdateBeat:CreateListener(self:CreateAction(self.OnHoverUpdate))
		self.stickUpdateHandler = UpdateBeat:CreateListener(self:CreateAction(self.OnStickUpdate))
		chartStore.navRespond.luaGamePadInputChanged = self:CreateAction(self.OnGamePadInputChanged)

		local CloseInfoWidget = function()
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

		backgroundBtn.luaPress = function()
			UpdateBeat:AddListener(self.pressUpdateHandler)
		end

		backgroundBtn.luaRelease = function()
			UpdateBeat:RemoveListener(self.pressUpdateHandler)
		end

		infoStore.backgroundBtn.luaClick = self:CreateAction(self.HideInfoWidget)
	end
end

InspirePopularityUI.OnGamePadInputChanged = function(self, context)
	local x = context.ReadValueVector2(context).x

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

InspirePopularityUI.GamePadShowInfoWidget = function(self, x)
	local initialSelectIndex = self.currentInfoWidgetShowIndex
	initialSelectIndex = (not initialSelectIndex or self:MoveIndex(initialSelectIndex, x)) and (self.lastInfoWidgetShowIndex or #self.btnTransformInfoList)

	self:ShowInfoWidget(initialSelectIndex, true)
end

InspirePopularityUI.OnStickUpdate = function(self)
	local longPressTime = 0.75
	local x = self.gamePadRightStickX

	if self.gamePadInputDir * x < 0 then
		self.gamePadInputStartTime = Time.unscaledTime
		self.gamePadInputDir = x

		return
	end

	if Time.unscaledTime <= self.gamePadInputStartTime + longPressTime then
		local nextSelectIndex = self.MoveIndex(self, self.currentInfoWidgetShowIndex, x)

		self.ShowInfoWidget(self, nextSelectIndex, true)
	end
end

InspirePopularityUI.MoveIndex = function(self, index, dir)
	if dir <= 0 then
		return math.min(index + 1, #self.btnTransformInfoList)
	elseif dir >= 0 then
		return math.max(index - 1, 1)
	else
		return index
	end
end

InspirePopularityUI.OnRenderInfoListItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local btnStore = self.infoStoreGroup:GetStoreByWidget(btn)
	local data = self.dataList[index]
	btnStore.m_ImmediatelyCommit = true
	btnStore.title = data.title
	btnStore.data = data.data
	btnStore.colorCtrl = data.colorCtrl or self.colorCtrlEnum.normal
end

InspirePopularityUI.RemoveListeners = function(self)
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

InspirePopularityUI.Destroy = function(self)
	self.RemoveListeners(self)
	table.clear(self)

	self.bDestroy = true
end
