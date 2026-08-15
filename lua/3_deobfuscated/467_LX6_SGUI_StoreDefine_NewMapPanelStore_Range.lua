local M = C_NewMapPanelStore

function M:InitRangeObject()
	self.bindData.rangeList.luaRenderItem = self:CreateAction("OnRangeObjectRenderItem")

	function self.bindData.rangeList.onGetTIndex(csIndex)
		return 0
	end

	self.rangeObjIds = {}
	self.polygonObjs = {}
end

function M:TryAddRange(id)
	if not self:GetRangeObject(id) then
		return
	end

	if array.contains(self.rangeObjIds, id) then
		self:TryUpdateRange(id)
	else
		array.push(self.rangeObjIds, id)
	end

	self:RefreshRangeRenderItems()
end

function M:TryUpdateRange(id)
	if not self:GetRangeObject(id) then
		self:TryRemoveRange(id)

		return
	end

	local idx = array.index_of(self.rangeObjIds, id)

	if idx == -1 then
		return
	end

	self:RefreshRangeRenderItems()
end

function M:TryRemoveRange(id)
	if array.index_of(self.rangeObjIds, id) == -1 then
		return
	end

	array.remove(self.rangeObjIds, id)
	self:RefreshRangeRenderItems()
end

function M:GetRangeObject(id)
	local info = self._id2ElementInfo[id]

	return info and info.element.mData.rangeInfo
end

function M:RefreshRangeRenderItems()
	self.bindData.rangeList:SetList(#self.rangeObjIds)
end

function M:OnRangeObjectRenderItem(btn, csIndex)
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

function M:IsPlayerInRange(element)
	if element.areaId ~= self.areaId or not element.mData.rangeInfo or element.mData.rangeInfo.tmp_type then
		return false
	end

	local playerWorldPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local worldPos = element:GetWorldPos()
	local dx = worldPos.x - playerWorldPos.x
	local dz = worldPos.z - playerWorldPos.z
	local sqrXZDist = dx * dx + dz * dz
	local sqrRange = element.mData.rangeInfo.radius * element.mData.rangeInfo.radius

	return sqrXZDist <= sqrRange
end

function M:TryAddPolygonRange(id)
	local info = self._id2ElementInfo[id]

	if not info or not info.element.mData.polygonRangeInfo then
		return false
	end

	local polygonInfo = info.element.mData.polygonRangeInfo

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
		local tex = self:TransformWorldToTex(Vector3.New(point[1], point[2], point[3]), info.element.areaId)

		polygonObj:AddPoint(tex.x, tex.y)
	end

	self.polygonObjs[id] = item

	return true
end

function M:TryRemovePolygonRange(id)
	if not self.polygonObjs[id] then
		return
	end

	local obj = self.polygonObjs[id]

	self.bindData.polygonPool:DeleteItem(obj)
end
