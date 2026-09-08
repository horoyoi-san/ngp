-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_Trace.lua
-- Decompiled from: 00993_NewMapPanelStore_Trace.lua_0b514888cfe2.luajit

local M = C_NewMapPanelStore

M.InitTracing = function(self)
	self._indicatorData = {}
	self.cityCenter = nil

	self.RefreshPlayerAndPlayerIndicatorColor(self)
end

M.RemoveIndicator = function(self, id)
	local indicator = self._indicatorData[id]

	if indicator then
		self.bindData.indicatorPool:DeleteItem(indicator.widget)

		self._indicatorData[id] = nil
	end
end

M.AddIndicator = function(self, id)
	local indicator = self._indicatorData[id]
	local info = self._id2ElementInfo[id]

	if indicator then
		indicator.texPos = info.texPos
		indicator.tintColor = info.element.mData.tintColor or nil

		return
	end

	local widget = self.bindData.indicatorPool:CreateItem(0)

	widget.luaClick = function()
		self:SetSelected(nil)
		self:ScheduleOperation(self.OperationType.FocusTexPos, {
			texPos = self._id2ElementInfo[id].texPos
		})
	end

	local store = gStoreManager:GetStoreGroup("NewMapPanelStore_Indicator"):GetStoreByWidget(widget)
	store.guideId = "AR_" .. info.element.gpsId
	self._indicatorData[id] = {
		id = id,
		texPos = self._id2ElementInfo[id].texPos,
		widget = widget,
		tintColor = info.element.mData.tintColor or nil
	}
end

M.AddOrUpdateTraceEffect = function(self, info)
	if not info.traceEffectWidget then
		local effectWidget = self.bindData.traceFxPool:CreateItem(0)
		info.traceEffectWidget = effectWidget
	end

	local traceStore = gStoreManager:GetStoreGroup("BigMapTraceEffectStore"):GetStoreByWidget(info.traceEffectWidget)

	if traceStore then
		traceStore.tintColor1 = info.element.mData.tintColor or "3263FF"
		traceStore.tintColor2 = info.element.mData.tintColor or "3263FF"
	end

	info.traceEffectWidget.rectTransform:SetLocalPositionXY(info.texPos.x, info.texPos.y)
end

M.TryUpdateTraceEffectPos = function(self, info)
	if info.traceEffectWidget then
		info.traceEffectWidget.rectTransform:SetLocalPositionXY(info.texPos.x, info.texPos.y)
	end
end

M.RemoveTraceEffect = function(self, info)
	if info.traceEffectWidget then
		self.bindData.traceFxPool:DeleteItem(info.traceEffectWidget)

		info.traceEffectWidget = nil
	end
end

M.TickIndicatorAndPlayer = function(self)
	self:AddAvailableTaskIndicators()

	self.tmp_IndicatorStack2 = self.tmp_IndicatorStack2 or {}

	array.clear(self.tmp_IndicatorStack2)

	local halfViewportSize = self:GetRootSize() * 0.5
	local halfContainerSize = gCS.LuaUtils.GetRectTransformSize(self.bindData.indicatorContainerRT) * 0.5

	self:TickPlayerAndPlayerIndicator(halfViewportSize, halfContainerSize)

	for id, indicator in pairs(self._indicatorData) do
		local widget = indicator.widget

		if indicator.id then
			if indicator.texPos then
				local info = self._id2ElementInfo[indicator.id]
				local iconId = self.GetIconId(self, info.element)

				self.SetupIndicator(self, widget, indicator.texPos, iconId, halfViewportSize, halfContainerSize, false, indicator.tintColor)
			end
		end
	end

	self.NewResolveIndicatorFrameData(self, 70, halfContainerSize)
end

M.NewResolveIndicatorFrameData = function(self, step, halfContainerSize)
	local count = #self.tmp_IndicatorStack2

	if count ~= 0 then
		return
	end

	table.sort(self.tmp_IndicatorStack2, function (a, b)
		return a.unifiedPosT <= b.unifiedPosT
	end)

	if count <= 1 then
		for i = 1, count - 1 do
			local pos1 = self.tmp_IndicatorStack2[i].unifiedPosT
			local pos2 = self.tmp_IndicatorStack2[i + 1].unifiedPosT

			if step <= pos2 - pos1 then
				self.tmp_IndicatorStack2[i + 1].unifiedPosT = pos1 + step
			end
		end

		local l = halfContainerSize.x * 4 + halfContainerSize.y * 4

		if step <= l - self.tmp_IndicatorStack2[count].unifiedPosT + self.tmp_IndicatorStack2[1].unifiedPosT then
			self.tmp_IndicatorStack2[1].unifiedPosT = step - (l - self.tmp_IndicatorStack2[count].unifiedPosT)
		end
	end

	local hWidth = halfContainerSize.x
	local hHeight = halfContainerSize.y
	local width = hWidth * 2
	local height = hHeight * 2

	for i = 1, #self.tmp_IndicatorStack2 do
		local widget = self.tmp_IndicatorStack2[i].widget
		local t = self.tmp_IndicatorStack2[i].unifiedPosT

		if t < width then
			widget.rectTransform:SetLocalPositionXY(t - hWidth, hHeight)
		elseif t < width + height then
			widget.rectTransform:SetLocalPositionXY(hWidth, hHeight - (t - width))
		elseif t < width * 2 + height then
			widget.rectTransform:SetLocalPositionXY(hWidth - (t - width - height), -hHeight)
		else
			widget.rectTransform:SetLocalPositionXY(-hWidth, -hHeight + t - width * 2 - height)
		end
	end
end

M.TryGetPlayerData = function(self)
	local playerUnit = gMapSystem.curPlayerUnit

	if not playerUnit or not self.areaCluster or self.IsLegendMode(self) then
		return false
	end

	local playerIndoorId = gMapSystem.lastIndoorId or 0

	if self.indoorId == 0 and playerIndoorId == self.indoorId then
		return false
	end

	local playerPos = gMapSystem:GetCurPlayerPosition()
	playerPos = Vector3.New(playerPos.X, playerPos.Y, playerPos.Z)
	local areaId, worldPos = self.areaCluster:GetResolvedCoord(playerPos, gMapManager:GetParentAreaId(gMapSystem.lastAreaId))

	if areaId and self.IsBigWorld(self) then
		local targetRaidId, _ = gMapSystem.area:SplitAreaId(areaId)

		if targetRaidId ~= gMapSystem.lastRaidId then
			worldPos = playerPos
		end
	end

	if not areaId or not worldPos then
		return false
	end

	local eulerZ = -gMapSystem:GetCurPlayerEulerY()

	return true, self:TransformWorldToTex(worldPos, areaId), eulerZ
end

M.TickPlayerAndPlayerIndicator = function(self, halfViewportSize, halfContainerSize)
	local needShow, playerTexPos, eulerZ = self.TryGetPlayerData(self)

	if not needShow then
		self.bindData.playerRT.gameObject:SetActive(false)
		self.bindData.meIndicatorRoot:SetActive(false)

		return
	end

	self.bindData.playerRT.gameObject:SetActive(true)

	self.bindData.playerRT.localPosition = playerTexPos

	self.bindData.playerRT:SetLocalEulerAnglesZ(eulerZ)
	self.bindData.meIndicatorIconRT:SetLocalEulerAnglesZ(eulerZ)
	self:SetupIndicator(self.bindData.meIndicatorRoot, playerTexPos, nil, halfViewportSize, halfContainerSize, true, nil)
end

M.RefreshPlayerAndPlayerIndicatorColor = function(self)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		self.bindData.onlineStateCtrl = 0
		local meIndicatorStore = gStoreManager:GetStoreGroup("NewMapPanelStore_Indicator"):GetStoreByWidget(self.bindData.meIndicatorRoot)
		meIndicatorStore.onlineStateCtrl = 0
	else
		local pId = gPlayerManager.infoLogin.bindData.pid
		local tintColor = gLinkManager:GetColorInfo(pId)
		self.bindData.onlineStateCtrl = 1
		self.bindData.meTintColor = tintColor
		local meIndicatorStore = gStoreManager:GetStoreGroup("NewMapPanelStore_Indicator"):GetStoreByWidget(self.bindData.meIndicatorRoot)
		meIndicatorStore.onlineStateCtrl = 1
		meIndicatorStore.meTintColor = tintColor
	end
end

M.SetupIndicator = function(self, widget, texPos, iconId, halfViewportSize, halfContainerSize, isMe, tintColor)
	local uiPos = self.TransformTexToUI(self, texPos)
	local halfWidth = halfViewportSize.x
	local halfHeight = halfViewportSize.y

	if uiPos.x <= -halfWidth or halfWidth <= uiPos.x or uiPos.y <= -halfHeight or halfHeight >= uiPos.y then
		widget.SetActive(widget, true)

		local hContainerWidth = halfContainerSize.x
		local hContainerHeight = halfContainerSize.y
		local xType = 0

		if uiPos.x >= -hContainerWidth then
			uiPos.x = -hContainerWidth
			xType = -1
		elseif hContainerWidth >= uiPos.x then
			uiPos.x = hContainerWidth
			xType = 1
		end

		local yType = 0

		if uiPos.y >= -hContainerHeight then
			uiPos.y = -hContainerHeight
			yType = -1
		elseif hContainerHeight >= uiPos.y then
			uiPos.y = hContainerHeight
			yType = 1
		end

		local eulerZ = 0
		local unifiedPosT = nil

		if xType ~= 0 and yType ~= 1 then
			eulerZ = 0
			unifiedPosT = hContainerWidth + uiPos.x
		elseif xType ~= 1 and yType ~= 1 then
			eulerZ = 315
			unifiedPosT = hContainerWidth * 2
		elseif xType ~= 1 and yType ~= 0 then
			eulerZ = 270
			unifiedPosT = hContainerWidth * 2 + hContainerHeight - uiPos.y
		elseif xType ~= 1 and yType ~= -1 then
			eulerZ = 225
			unifiedPosT = hContainerWidth * 2 + hContainerHeight * 2
		elseif xType ~= 0 and yType ~= -1 then
			eulerZ = 180
			unifiedPosT = hContainerWidth * 3 + hContainerHeight * 2 - uiPos.x
		elseif xType ~= -1 and yType ~= -1 then
			eulerZ = 135
			unifiedPosT = hContainerWidth * 4 + hContainerHeight * 2
		elseif xType ~= -1 and yType ~= 0 then
			eulerZ = 90
			unifiedPosT = hContainerWidth * 4 + hContainerHeight * 3 + uiPos.y
		elseif xType ~= -1 and yType ~= 1 then
			eulerZ = 45
			unifiedPosT = 0
		end

		local store = gStoreManager:GetStoreGroup("NewMapPanelStore_Indicator"):GetStoreByWidget(widget)

		if iconId then
			store.iconId = iconId
		end

		if not isMe then
			if tintColor then
				store.onlineStateCtrl = 2
				store.tintColor = tintColor
			else
				store.onlineStateCtrl = 0
			end
		end

		store.eulerZ = eulerZ
		local frameData = {
			widget = widget,
			unifiedPosT = unifiedPosT
		}

		table.insert(self.tmp_IndicatorStack2, frameData)
	else
		widget.SetActive(widget, false)
	end
end

M.OnClickMeIndicator = function(self)
	local areaId, worldPos = self.areaCluster:GetResolvedCoord(gMapSystem:GetCurPlayerLocalPosition(), gMapManager:GetParentAreaId(gMapSystem.lastAreaId))
	local playerTexPos = self:TransformWorldToTex(worldPos, areaId)

	self:SetSelected(nil)
	self:ScheduleOperation(self.OperationType.FocusTexPos, {
		texPos = playerTexPos
	})
end

M.AddAvailableTaskIndicators = function(self)
	local taskSubSystem = gMapSubSystem_Task

	for id, info in pairs(self._id2ElementInfo) do
		local element = gMapSystem:GetByInstanceId(id)

		if not element then
			return
		end

		if taskSubSystem.IsImportantTaskElement(taskSubSystem, element) then
			local visible = info.showMask > info.hideMask and info.showMask == 0

			if visible and not taskSubSystem.HasCurTask(taskSubSystem) then
				self.AddIndicator(self, id)
			else
				self.RemoveIndicator(self, id)
			end
		end
	end
end

M.RefreshIndicator = function(self)
end
