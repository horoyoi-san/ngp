local M = C_NewMapPanelStore

function M:InitTracing()
	self._indicatorData = {}
end

function M:RemoveIndicator(id)
	local indicator = self._indicatorData[id]

	if indicator then
		self.bindData.indicatorPool:DeleteItem(indicator.widget)

		self._indicatorData[id] = nil
	end
end

function M:AddIndicator(id)
	local indicator = self._indicatorData[id]
	local info = self._id2ElementInfo[id]

	if indicator then
		indicator.texPos = info.texPos

		return
	end

	local widget = self.bindData.indicatorPool:CreateItem(0)

	function widget.luaClick()
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
		widget = widget
	}
end

function M:AddOrUpdateTraceEffect(info)
	if not info.traceEffectWidget then
		local effectWidget = self.bindData.traceFxPool:CreateItem(0)
		info.traceEffectWidget = effectWidget
	end

	info.traceEffectWidget.rectTransform:SetLocalPositionXY(info.texPos.x, info.texPos.y)
end

function M:TryUpdateTraceEffectPos(info)
	if info.traceEffectWidget then
		info.traceEffectWidget.rectTransform:SetLocalPositionXY(info.texPos.x, info.texPos.y)
	end
end

function M:RemoveTraceEffect(info)
	if info.traceEffectWidget then
		self.bindData.traceFxPool:DeleteItem(info.traceEffectWidget)

		info.traceEffectWidget = nil
	end
end

function M:TickIndicatorAndPlayer()
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
				local iconId = self:GetIconId(info.element)

				self:SetupIndicator(widget, indicator.texPos, iconId, halfViewportSize, halfContainerSize)
			end
		end
	end

	self:NewResolveIndicatorFrameData(70, halfContainerSize)
end

function M:NewResolveIndicatorFrameData(step, halfContainerSize)
	local count = #self.tmp_IndicatorStack2

	if count == 0 then
		return
	end

	table.sort(self.tmp_IndicatorStack2, function (a, b)
		return a.unifiedPosT < b.unifiedPosT
	end)

	if count > 1 then
		for i = 1, count - 1 do
			local pos1 = self.tmp_IndicatorStack2[i].unifiedPosT
			local pos2 = self.tmp_IndicatorStack2[i + 1].unifiedPosT

			if step > pos2 - pos1 then
				self.tmp_IndicatorStack2[i + 1].unifiedPosT = pos1 + step
			end
		end

		local l = halfContainerSize.x * 4 + halfContainerSize.y * 4

		if step > l - self.tmp_IndicatorStack2[count].unifiedPosT + self.tmp_IndicatorStack2[1].unifiedPosT then
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

		if t <= width then
			widget.rectTransform:SetLocalPositionXY(t - hWidth, hHeight)
		elseif t <= width + height then
			widget.rectTransform:SetLocalPositionXY(hWidth, hHeight - (t - width))
		elseif t <= width * 2 + height then
			widget.rectTransform:SetLocalPositionXY(hWidth - (t - width - height), -hHeight)
		else
			widget.rectTransform:SetLocalPositionXY(-hWidth, -hHeight + t - width * 2 - height)
		end
	end
end

function M:TryGetPlayerData()
	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	if not playerUnit or not self.areaCluster or self:IsLegendMode() then
		return false
	end

	local playerIndoorId = gMapSystem.lastIndoorId or 0

	if self.indoorId ~= 0 and playerIndoorId ~= self.indoorId then
		return false
	end

	local playerPos = playerUnit.Position
	playerPos = Vector3.New(playerPos.X, playerPos.Y, playerPos.Z)
	local areaId, worldPos = self.areaCluster:GetResolvedCoord(playerPos, gMapSystem.lastAreaId)

	if areaId and self:IsBigWorld() then
		local targetRaidId, _ = gMapSystem.area:SplitAreaId(areaId)

		if targetRaidId == gMapSystem.lastRaidId then
			worldPos = playerPos
		end
	end

	if not areaId or not worldPos then
		return false
	end

	local eulerZ = nil

	if gDriveVehiclesManager.isDriveMode and gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle then
		eulerZ = -gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle.VehicleGameObject.transform.eulerAngles.y
	else
		eulerZ = -playerUnit.EulerY
	end

	return true, self:TransformWorldToTex(worldPos, areaId), eulerZ
end

function M:TickPlayerAndPlayerIndicator(halfViewportSize, halfContainerSize)
	local needShow, playerTexPos, eulerZ = self:TryGetPlayerData()

	if not needShow then
		self.bindData.playerRT.gameObject:SetActive(false)
		self.bindData.meIndicatorRoot:SetActive(false)

		return
	end

	self.bindData.playerRT.gameObject:SetActive(true)

	self.bindData.playerRT.localPosition = playerTexPos

	self.bindData.playerRT:SetLocalEulerAnglesZ(eulerZ)
	self.bindData.meIndicatorIconRT:SetLocalEulerAnglesZ(eulerZ)
	self:SetupIndicator(self.bindData.meIndicatorRoot, playerTexPos, nil, halfViewportSize, halfContainerSize)
end

function M:SetupIndicator(widget, texPos, iconId, halfViewportSize, halfContainerSize)
	local uiPos = self:TransformTexToUI(texPos)
	local halfWidth = halfViewportSize.x
	local halfHeight = halfViewportSize.y

	if uiPos.x < -halfWidth or halfWidth < uiPos.x or uiPos.y < -halfHeight or halfHeight < uiPos.y then
		widget:SetActive(true)

		local hContainerWidth = halfContainerSize.x
		local hContainerHeight = halfContainerSize.y
		local xType = 0

		if uiPos.x < -hContainerWidth then
			uiPos.x = -hContainerWidth
			xType = -1
		elseif hContainerWidth < uiPos.x then
			uiPos.x = hContainerWidth
			xType = 1
		end

		local yType = 0

		if uiPos.y < -hContainerHeight then
			uiPos.y = -hContainerHeight
			yType = -1
		elseif hContainerHeight < uiPos.y then
			uiPos.y = hContainerHeight
			yType = 1
		end

		local eulerZ = 0
		local unifiedPosT = nil

		if xType == 0 and yType == 1 then
			eulerZ = 0
			unifiedPosT = hContainerWidth + uiPos.x
		elseif xType == 1 and yType == 1 then
			eulerZ = 315
			unifiedPosT = hContainerWidth * 2
		elseif xType == 1 and yType == 0 then
			eulerZ = 270
			unifiedPosT = hContainerWidth * 2 + hContainerHeight - uiPos.y
		elseif xType == 1 and yType == -1 then
			eulerZ = 225
			unifiedPosT = hContainerWidth * 2 + hContainerHeight * 2
		elseif xType == 0 and yType == -1 then
			eulerZ = 180
			unifiedPosT = hContainerWidth * 3 + hContainerHeight * 2 - uiPos.x
		elseif xType == -1 and yType == -1 then
			eulerZ = 135
			unifiedPosT = hContainerWidth * 4 + hContainerHeight * 2
		elseif xType == -1 and yType == 0 then
			eulerZ = 90
			unifiedPosT = hContainerWidth * 4 + hContainerHeight * 3 + uiPos.y
		elseif xType == -1 and yType == 1 then
			eulerZ = 45
			unifiedPosT = 0
		end

		local store = gStoreManager:GetStoreGroup("NewMapPanelStore_Indicator"):GetStoreByWidget(widget)

		if iconId then
			store.iconId = iconId
		end

		store.eulerZ = eulerZ
		local frameData = {
			widget = widget,
			unifiedPosT = unifiedPosT
		}

		table.insert(self.tmp_IndicatorStack2, frameData)
	else
		widget:SetActive(false)
	end
end

function M:OnClickMeIndicator()
	local areaId, worldPos = self.areaCluster:GetResolvedCoord(gCS.MyPlayerManager.PlayerUnit.LocalPosition, gMapSystem.lastAreaId)
	local playerTexPos = self:TransformWorldToTex(worldPos, areaId)

	self:SetSelected(nil)
	self:ScheduleOperation(self.OperationType.FocusTexPos, {
		texPos = playerTexPos
	})
end

function M:AddAvailableTaskIndicators()
	local taskSubSystem = gMapSubSystem_Task

	for id, info in pairs(self._id2ElementInfo) do
		local element = gMapSystem:GetByInstanceId(id)

		if not element then
			return
		end

		if taskSubSystem:IsImportantTaskElement(element) then
			local visible = info.showMask >= info.hideMask and info.showMask ~= 0

			if visible and not taskSubSystem:HasCurTask() then
				self:AddIndicator(id)
			else
				self:RemoveIndicator(id)
			end
		end
	end
end
