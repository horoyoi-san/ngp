MapSubSystem_Debug = DefClass("MapSubSystem_Debug", MapSubSystem_Debug, MapSubSystemBase)
local M = MapSubSystem_Debug

function M:OnInit()
	self.icons = {
		28000036,
		28000037,
		28000038,
		28000039,
		28000040,
		28000041,
		28000042,
		28000043
	}
	self.debugElements = {}
	self.idCounter = {}
end

function M:AddElement(id, raidId, worldPos)
	if self.debugElements[id] then
		self.debugElements[id]:Dispose()

		self.debugElements[id] = nil
	end

	worldPos.y = 1

	print_debug("Debug Add Gps Point ", worldPos.x, worldPos.y, worldPos.z)

	local element = MapElement.CreateLegacy(EMapElementType.Debug, id, EMapSubSystemType.Debug, EMapViewMask.AllSgui, raidId, 0)

	element:SetPosition(worldPos)

	element.mData.sIconId = self:PopulateIcon()
	element.mData.name = element.gpsId

	element:SetVisible(true)
	element:SetTraceInfo(EMapGTraceType.Debug)

	self.debugElements[id] = element

	return element
end

function M:AddOnMe(id, raidId)
	local element = MapElement.CreateLegacy(EMapElementType.Debug, id, EMapSubSystemType.Debug, EMapViewMask.AllSgui, raidId, 0)

	element:BindUnit(gGpsBindingMgr.mePid)

	element.mData.sIconId = self:PopulateIcon()
	element.mData.name = element.gpsId

	element:SetVisible(true)
	element:SetTraceInfo(EMapGTraceType.Debug)

	self.debugElements[id] = element
end

function M:Get(id)
	return self.debugElements[id]
end

function M:RemoveAll()
	for _, element in pairs(self.debugElements) do
		element:Dispose()
	end
end

function M:PopulateIcon()
	local iconId = self.icons[math.random(1, #self.icons)]

	return iconId
end

function M:SGetTooltipInfo(id, element)
	return nil
end

return M
