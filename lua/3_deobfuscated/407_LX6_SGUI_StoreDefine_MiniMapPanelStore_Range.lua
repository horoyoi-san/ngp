local M = C_MiniMapPanelStore

function M:InitRangeObject()
	self.polygonObjs = {}
	self._safeAreaObjs = {}
	self._safeAreaSplineObjs = {}
	self._safeAreaColor = Color.NewByStr(LTConfig.GpsConfig.BlockColor.safeColor)
	self._safeAreaOutlineColor = Color.New(self._safeAreaColor.r, self._safeAreaColor.g, self._safeAreaColor.b, 1)
	self._dangerAreaColor = Color.NewByStr(LTConfig.GpsConfig.BlockColor.dangerColor)
	self._dangerAreaOutlineColor = Color.New(self._dangerAreaColor.r, self._dangerAreaColor.g, self._dangerAreaColor.b, 1)
	self._safeOrDangerOutlineWidth = LTConfig.GpsConfig.BlockColor.width
end

function M:HasRange(element)
	if element.areaId ~= self.areaId or not element.mData.rangeInfo or element.mData.rangeInfo.tmp_type == 2 then
		return false
	end

	return true
end

function M:HasPolygonRange(element)
	if element.areaId ~= self.areaId or not element.mData.polygonRangeInfo then
		return false
	end

	return true
end

function M:TryAddRange(info)
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

function M:TryRemoveRange(info)
	if info.rangeWidget then
		self.bindData.rangePool:DeleteItem(info.rangeWidget)

		info.rangeWidget = nil
	end
end

function M:TryAddPolygonRange(id)
	local info = self._id2ElementInfo[id]

	if not info or not info.mapElement.mData.polygonRangeInfo then
		return false
	end

	local polygonInfo = info.mapElement.mData.polygonRangeInfo

	if self.polygonObjs[id] then
		return true
	end

	local item = self.bindData.polygonPool:CreateItem(0)
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(item)
	local polygonObj = store.polygon
	polygonObj.outline = true
	polygonObj.outlineColor = polygonInfo.color
	polygonObj.outlineWidth = 3
	polygonObj.color = Color.New(polygonInfo.color.r, polygonInfo.color.g, polygonInfo.color.b, 0.3)

	for _, point in ipairs(polygonInfo.points) do
		local texX, texY = gMapTransformHelper:WorldPosXZ2TexPosXY(point[1], point[3], info.mapElement.areaId)

		polygonObj:AddPoint(texX, texY)
	end

	self.polygonObjs[id] = item

	return true
end

function M:TryRemovePolygonRange(id)
	if not self.polygonObjs[id] then
		return
	end

	local obj = self.polygonObjs[id]
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(obj)
	local polygon = store.polygon

	polygon:ClearPoint()
	self.bindData.polygonPool:DeleteItem(obj)
end

function M:RefreshSafeAreas()
	self:RemoveAllSafeAreas()

	local areaDatas = self:GetSafeAreaDatas()

	if not areaDatas or #areaDatas == 0 then
		return
	end

	for _, areaData in ipairs(areaDatas) do
		if #areaData.points < 6 then
			print_error("安全区数据非法:" .. tostring(#areaData) .. "个点不能组成多边形, 当前areaId:" .. tostring(self.areaId))
		elseif #areaData.points % 2 ~= 0 then
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

			for i = 1, #points / 2 do
				local x = points[i * 2 - 1]
				local z = points[i * 2]
				local texX, texY = gMapTransformHelper:WorldPosXZ2TexPosXY(x, z, self.areaId)

				polygon:AddPoint(texX, texY)
				spline:AddPoint(texX, texY, self._safeOrDangerOutlineWidth, true, 0, self._safeOrDangerOutlineWidth / 2)
			end

			local texX, texY = gMapTransformHelper:WorldPosXZ2TexPosXY(points[1], points[2], self.areaId)

			spline:AddPoint(texX, texY, self._safeOrDangerOutlineWidth, true, 0, self._safeOrDangerOutlineWidth / 2)
			polygon:RefreshPolygon()
			spline:RefreshSpline()
			table.insert(self._safeAreaObjs, polygonItem)
			table.insert(self._safeAreaSplineObjs, splineItem)
		end
	end
end

function M:RemoveAllSafeAreas()
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
end

function M:GetSafeAreaDatas()
	if self.indoorId == 0 then
		return LX6.Gps.AreaMgr.graph:LuaGetAllActiveSafeAreaXZPolygon(self.raidId)
	else
		return nil
	end
end
