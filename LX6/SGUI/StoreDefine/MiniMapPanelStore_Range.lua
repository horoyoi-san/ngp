-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MiniMapPanelStore_Range.lua
-- Decompiled from: 00980_MiniMapPanelStore_Range.lua_024552ff1a15.luajit

local M = C_MiniMapPanelStore

M.InitRangeObject = function(self)
	self.polygonObjs = {}
	self._safeAreaObjs = {}
	self._safeAreaSplineObjs = {}
	self._safeAreaTexRanges = {}
	self._safeAreaColor = Color.NewByStr(LTConfig.GpsConfig.BlockColor.safeColor)
	self._safeAreaOutlineColor = Color.New(self._safeAreaColor.r, self._safeAreaColor.g, self._safeAreaColor.b, 1)
	self._dangerAreaColor = Color.NewByStr(LTConfig.GpsConfig.BlockColor.dangerColor)
	self._dangerAreaOutlineColor = Color.New(self._dangerAreaColor.r, self._dangerAreaColor.g, self._dangerAreaColor.b, 1)
	self._safeOrDangerOutlineWidth = LTConfig.GpsConfig.BlockColor.width
	self.isInDangerArea = false
	self.isInFight = false

	self.RefreshInFightCtrl(self)
	self.RefreshMapScaleByDangerArea(self)
end

M.HasRange = function(self, element)
	if element.areaId == self.areaId or not element.mData.rangeInfo or element.mData.rangeInfo.rangeType ~= 2 then
		return false
	end

	return true
end

M.CheckRange = function(self, element)
	if not self.HasRange(self, element) then
		return false
	end

	if element.mData.rangeInfo.alwaysShowIcon then
		return false
	end

	if element.mData.rangeInfo.hideIcon ~= true then
		return true
	end

	if Vector3.Distance(element:GetWorldPos(), gMapSystem:GetCurPlayerLocalPosition()) < element.mData.rangeInfo.radius then
		return true
	end

	return false
end

M.HasPolygonRange = function(self, element)
	if element.areaId == self.areaId or not element.mData.polygonRangeInfo then
		return false
	end

	return true
end

M.CheckGpsCustomAreaRange = function(self, element)
	if element.areaId == self.areaId or not element.mData.gpsCustomAreaRangeInfo then
		return false
	end

	return gMapSystem:IsPlayerInRange(element)
end

M.TryAddRange = function(self, info)
	local widget = info.rangeWidget

	if not widget then
		widget = self.bindData.rangePool:CreateItem(0)
		info.rangeWidget = widget
	end

	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(widget)

	if info.mapElement.mData.rangeInfo.isLeaveRange then
		store.isLeaveRange = 1
	else
		store.isLeaveRange = 0
	end

	store.color = info.mapElement.mData.rangeInfo.color
	widget.localPosition = info.texPos
	local radiusX2 = info.mapElement.mData.rangeInfo.radius * 2 * self.mapCfg.scaleWorld2Tex.y
	widget.rectTransform.sizeDelta = Vector2.New(radiusX2, radiusX2)
end

M.TryRemoveRange = function(self, info)
	if info.rangeWidget then
		self.bindData.rangePool:DeleteItem(info.rangeWidget)

		info.rangeWidget = nil
	end
end

M.IsElementNeedRange = function(self, element)
	if not self.HasRange(self, element) then
		return false
	end

	local rangeInfo = element.mData.rangeInfo

	if rangeInfo.rangeType and rangeInfo.rangeType ~= 3 then
		return true
	end

	local playerWorldPos = gMapSystem:GetCurPlayerLocalPosition()
	local worldPos = element:GetWorldPos()
	local dx = worldPos.x - playerWorldPos.x
	local dz = worldPos.z - playerWorldPos.z
	local sqrXZDist = dx * dx + dz * dz
	local sqrRange = element.mData.rangeInfo.radius * element.mData.rangeInfo.radius

	return sqrXZDist > sqrRange
end

local createPolygonObject = function(self, polygonInfo)
	local item = self.bindData.polygonPool:CreateItem(0)
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(item)
	local polygonObj = store.polygon
	polygonObj.outline = true
	polygonObj.outlineColor = polygonInfo.color
	polygonObj.outlineWidth = 3
	polygonObj.color = Color.New(polygonInfo.color.r, polygonInfo.color.g, polygonInfo.color.b, 0.3)

	return item, polygonObj
end

local fillGpsCustomAreaPolygon = function(self, info, polygonObj, area)
	polygonObj:ClearPoint()

	slot4 = ipairs
	slot6 = area.points or {}

	for _, point in slot4(slot6) do
		local texX, texY = gMapTransformHelper:WorldPosXZ2TexPosXY(point.x, point.z, info.mapElement.areaId)

		polygonObj:AddPoint(texX, texY)
	end

	polygonObj.RefreshPolygon(polygonObj)
end

M.TryAddGpsCustomAreaRange = function(self, id)
	local info = self._id2ElementInfo[id]
	local gpsCustomAreaRangeInfo = info and info.mapElement.mData.gpsCustomAreaRangeInfo

	if not gpsCustomAreaRangeInfo then
		return false
	end

	if not gMapSystem:IsPlayerInRange(info.mapElement) then
		self.TryRemovePolygonRange(self, id)

		return false
	end

	if self.polygonObjs[id] then
		return true
	end

	local polygonObjects = {}
	slot5 = ipairs
	slot7 = gpsCustomAreaRangeInfo.areas or {}

	for _, area in slot5(slot7) do
		local item, polygonObj = createPolygonObject(self, gpsCustomAreaRangeInfo)

		fillGpsCustomAreaPolygon(self, info, polygonObj, area)
		table.insert(polygonObjects, item)
	end

	if #polygonObjects ~= 0 then
		return false
	end

	self.polygonObjs[id] = polygonObjects

	return true
end

M.TryAddPolygonRange = function(self, id)
	local info = self._id2ElementInfo[id]

	if not info or not info.mapElement.mData.polygonRangeInfo then
		self.TryRemovePolygonRange(self, id)

		return false
	end

	local polygonInfo = info.mapElement.mData.polygonRangeInfo

	if self.polygonObjs[id] then
		return true
	end

	local polygonObjects = {}
	local item, polygonObj = createPolygonObject(self, polygonInfo)

	polygonObj.ClearPoint(polygonObj)

	for _, point in ipairs(polygonInfo.points) do
		local texX, texY = gMapTransformHelper:WorldPosXZ2TexPosXY(point[1], point[3], info.mapElement.areaId)

		polygonObj:AddPoint(texX, texY)
	end

	polygonObj.RefreshPolygon(polygonObj)
	table.insert(polygonObjects, item)

	self.polygonObjs[id] = polygonObjects

	return true
end

M.TryRemovePolygonRange = function(self, id)
	if not self.polygonObjs[id] then
		return
	end

	for _, obj in ipairs(self.polygonObjs[id]) do
		local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(obj)
		local polygon = store.polygon

		polygon:ClearPoint()
		self.bindData.polygonPool:DeleteItem(obj)
	end

	self.polygonObjs[id] = nil
end

M.RefreshSafeAreas = function(self)
	self.RemoveAllSafeAreas(self)

	local areaDatas = self.GetSafeAreaDatas(self)

	if not areaDatas or #areaDatas ~= 0 then
		return
	end

	for _, areaData in ipairs(areaDatas) do
		if #areaData.points >= 6 then
			print_error("安全区数据非法:" .. tostring(#areaData) .. "个点不能组成多边形, 当前areaId:" .. tostring(self.areaId))
		elseif #areaData.points % 2 == 0 then
			print_error("安全区数据非法:" .. tostring(#areaData) .. "点数不是偶数, 当前areaId:" .. tostring(self.areaId))
		else
			local polygonItem = self.bindData.polygonPool:CreateItem(0)
			local polygonStore = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(polygonItem)
			local splineItem = self.bindData.splinePool:CreateItem(0)
			local polygon = polygonStore.polygon
			local spline = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(splineItem).spline
			polygon.outline = false
			polygon.color = areaData.isSafe and self._safeAreaColor or self._dangerAreaColor
			spline.color = areaData.isSafe and self._safeAreaOutlineColor or self._dangerAreaOutlineColor
			local points = areaData.points
			local minTexX = math.huge
			local minTexY = math.huge
			local maxTexX = -math.huge
			local maxTexY = -math.huge

			for i = 1, #points / 2 do
				local x = points[i * 2 - 1]
				local z = points[i * 2]
				local texX, texY = gMapTransformHelper:WorldPosXZ2TexPosXY(x, z, self.areaId)

				polygon:AddPoint(texX, texY)
				spline:AddPoint(texX, texY, self._safeOrDangerOutlineWidth, true, 0, self._safeOrDangerOutlineWidth / 2)

				minTexX = math.min(minTexX, texX)
				minTexY = math.min(minTexY, texY)
				maxTexX = math.max(maxTexX, texX)
				maxTexY = math.max(maxTexY, texY)
			end

			local texX, texY = gMapTransformHelper:WorldPosXZ2TexPosXY(points[1], points[2], self.areaId)

			spline:AddPoint(texX, texY, self._safeOrDangerOutlineWidth, true, 0, self._safeOrDangerOutlineWidth / 2)
			polygon:RefreshPolygon()
			spline:RefreshSpline()
			table.insert(self._safeAreaObjs, polygonItem)
			table.insert(self._safeAreaSplineObjs, splineItem)
			table.insert(self._safeAreaTexRanges, {
				minTexX,
				minTexY,
				maxTexX,
				maxTexY
			})
		end
	end
end

M.RemoveAllSafeAreas = function(self)
	for _, obj in ipairs(self._safeAreaObjs) do
		local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(obj)
		local polygon = store.polygon

		polygon:ClearPoint()
		self.bindData.polygonPool:DeleteItem(obj)
	end

	for _, obj in ipairs(self._safeAreaSplineObjs) do
		local spline = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(obj).spline

		spline:ClearPoint()
		self.bindData.splinePool:DeleteItem(obj)
	end

	table.clear(self._safeAreaObjs)
	table.clear(self._safeAreaSplineObjs)
	table.clear(self._safeAreaTexRanges)
end

M.TickSafeAreaActive = function(self, inLogicThread)
	local focusTexMin = {
		self.focusTexPosition.x - self.mainRectSize.x * 0.7,
		self.focusTexPosition.y - self.mainRectSize.y * 0.7
	}
	local focusTexMax = {
		self.focusTexPosition.x + self.mainRectSize.x * 0.7,
		self.focusTexPosition.y + self.mainRectSize.y * 0.7
	}

	for index, texRange in ipairs(self._safeAreaTexRanges) do
		local isIntersect = texRange[1] < focusTexMax[1] and focusTexMin[1] < texRange[3] and texRange[2] < focusTexMax[2] and focusTexMin[2] > texRange[4]
		local splineObj = self._safeAreaSplineObjs[index]

		if splineObj and splineObj.activation == isIntersect then
			if inLogicThread then
				self.StoreWidgetOperation(self, splineObj, splineObj.SetActive, isIntersect)
			else
				splineObj.SetActive(splineObj, isIntersect)
			end
		end

		local polygonObj = self._safeAreaObjs[index]

		if polygonObj and polygonObj.activation == isIntersect then
			if inLogicThread then
				self.StoreWidgetOperation(self, polygonObj, polygonObj.SetActive, isIntersect)
			else
				polygonObj.SetActive(polygonObj, isIntersect)
			end
		end
	end
end

M.GetSafeAreaDatas = function(self)
	if self.indoorId ~= 0 then
		return LX6.Gps.AreaMgr.graph:LuaGetAllActiveSafeAreaXZPolygon(self.raidId)
	else
		return nil
	end
end

M.OnEnterOrLeaveDangerArea = function(self, _, inDanger)
	self.isInDangerArea = inDanger

	self.RefreshInFightCtrl(self)
	self.RefreshMapScaleByDangerArea(self)
end

M.OnPlayerFightStatusChange = function(self, _, isInFight)
	self.isInFight = isInFight

	self.RefreshInFightCtrl(self)
end

M.RefreshInFightCtrl = function(self)
	if self.isInDangerArea and self.isInFight or gMapSubSystem_Vehicle:GetMiniMapInFightActivate() then
		self.bindData.inFightCtrl = 1
	else
		self.bindData.inFightCtrl = 0
	end
end

M.RefreshMapScaleByDangerArea = function(self)
	if self.isInDangerArea then
		local miniMapScale = LTConfig.GpsConfig.MiniMapBlockScale

		if miniMapScale then
			gMapManager:SetMiniMapScale(miniMapScale, gMapScaleType.DangerArea)
		end
	else
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.DangerArea)
	end
end

M.ShowBoundaryAlert = function(self, show)
	if show then
		self.bindData.boundaryCtrl = 0
		self.bindData.boundaryAlertText = LTConfig.GameConfig.BoundaryAlertText
	else
		self.bindData.boundaryCtrl = 1
	end
end
