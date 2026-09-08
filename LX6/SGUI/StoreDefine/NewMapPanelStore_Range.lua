-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_Range.lua
-- Decompiled from: 00995_NewMapPanelStore_Range.lua_8f328e1d9031.luajit

local M = C_NewMapPanelStore

M.InitRangeObject = function(self)
	self.bindData.rangeList.luaRenderItem = self.CreateAction(self, "OnRangeObjectRenderItem")

	self.bindData.rangeList.onGetTIndex = function(csIndex)
		return 0
	end

	self.rangeObjIds = {}
	self.polygonObjs = {}
end

M.TryAddRange = function(self, id)
	if not self.GetRangeObject(self, id) then
		return
	end

	if array.contains(self.rangeObjIds, id) then
		self.TryUpdateRange(self, id)
	else
		array.push(self.rangeObjIds, id)
	end

	self.RefreshRangeRenderItems(self)
end

M.TryUpdateRange = function(self, id)
	if not self.GetRangeObject(self, id) then
		self.TryRemoveRange(self, id)

		return
	end

	local idx = array.index_of(self.rangeObjIds, id)

	if idx ~= -1 then
		return
	end

	self.RefreshRangeRenderItems(self)
end

M.TryRemoveRange = function(self, id)
	if array.index_of(self.rangeObjIds, id) ~= -1 then
		return
	end

	array.remove(self.rangeObjIds, id)
	self.RefreshRangeRenderItems(self)
end

M.TryRefreshRange = function(self, id)
	if not self.GetRangeObject(self, id) then
		self.TryRemoveRange(self, id)

		return
	end

	self.TryAddRange(self, id)
end

M.GetRangeObject = function(self, id)
	local info = self._id2ElementInfo[id]

	return info and info.widget and info.widget.activation and info.element.mData.rangeInfo
end

M.RefreshRangeRenderItems = function(self)
	self.bindData.rangeList:SetList(#self.rangeObjIds)
end

M.OnRangeObjectRenderItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local id = self.rangeObjIds[index]
	local info = self._id2ElementInfo[id]

	if not info then
		return
	end

	local rt = btn.rectTransform
	rt.localPosition = info.texPos
	local radiusX2 = info.element.mData.rangeInfo.radius * 2 * self.mapCfg.scaleWorld2Tex.y
	rt.sizeDelta = Vector2.New(radiusX2, radiusX2)
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
	store.color = info.element.mData.rangeInfo.color
end

M.IsElementNeedRange = function(self, element)
	if element.areaId == self.areaId or not element.mData.rangeInfo then
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
		local tex = self.TransformWorldToTex(self, Vector3.New(point.x, point.y, point.z), info.element.areaId)

		polygonObj.AddPoint(polygonObj, tex.x, tex.y)
	end

	polygonObj.RefreshPolygon(polygonObj)
end

M.TryAddGpsCustomAreaRange = function(self, id)
	local info = self._id2ElementInfo[id]
	local gpsCustomAreaRangeInfo = info and info.element.mData.gpsCustomAreaRangeInfo

	if not gpsCustomAreaRangeInfo then
		return false
	end

	if not gMapSystem:IsPlayerInRange(info.element) then
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

	if not info or not info.element.mData.polygonRangeInfo or info.element.mData.polygonRangeInfo.notShowInBigMap then
		self.TryRemovePolygonRange(self, id)

		return false
	end

	local polygonInfo = info.element.mData.polygonRangeInfo

	if self.polygonObjs[id] then
		return true
	end

	local polygonObjects = {}
	local item, polygonObj = createPolygonObject(self, polygonInfo)

	polygonObj.ClearPoint(polygonObj)

	for _, point in ipairs(polygonInfo.points) do
		local tex = self.TransformWorldToTex(self, Vector3.New(point[1], point[2], point[3]), info.element.areaId)

		polygonObj.AddPoint(polygonObj, tex.x, tex.y)
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
		local polygonObj = store.polygon

		polygonObj:ClearPoint()
		self.bindData.polygonPool:DeleteItem(obj)
	end

	self.polygonObjs[id] = nil
end
