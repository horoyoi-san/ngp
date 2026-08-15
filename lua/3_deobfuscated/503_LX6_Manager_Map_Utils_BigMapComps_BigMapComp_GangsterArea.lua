local FactionConfig = LTConfig.FactionConfig
local SmallAreaConfig = LTConfig.FactionInfluenceEventConfig
local InfluenceEventConfig = LTConfig.FactionInfluenceEventConfig
BigMapComp_GangsterArea = BigMapComp_GangsterArea or {}
local M = BigMapComp_GangsterArea
M.__index = M

function M:OnInit()
	self._areaDirtyHandler = self.bigMap:CreateAction("RenderAllArea", self)
	self.bindData.jiamuTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
	self.selectedAreaInfo = {}

	gMessageManager:AddMessageListener(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY, self._areaDirtyHandler)
end

function M:OnEnd()
	self.bindData.jiamuTab.selectedIndex = -1

	self.bindData.jiamuTab:ClearUnusedTabInstances()
end

function M:OnActive()
	self.bigMap.bindData.bigWorldBg:SetGrayScale(0.8, 0.716)
	gMapSubSystem_Gangster.helper:BuildColorWidthCache()
	self:Refresh()
end

function M:OnInactive()
	self.bigMap.bindData.bigWorldBg:SetGrayScale(1, 1)
	self:Refresh()
	gMapSubSystem_Gangster.helper:ClearColorWidthCache()
end

function M:OnDestroy()
	if self._areaDirtyHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY, self._areaDirtyHandler)

		self._areaDirtyHandler = nil
	end

	gMapSubSystem_Gangster.helper:ClearColorWidthCache()
end

function M:Refresh()
	if not self:CheckLoaded() then
		if self.actived then
			self:LoadPanel()
		end

		return
	end

	if self.actived then
		self:RenderAllArea()
		self.widget:SetActive(true)
	else
		self:ClearAllArea()
		self.widget:SetActive(false)
	end
end

function M:CheckLoaded()
	return self.store ~= nil and self.widget ~= nil
end

function M:LoadPanel()
	self.bindData.jiamuTab.selectedIndex = 0
end

function M:OnPanelLoaded(index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMap_JiaMuViewStore"):GetStoreByWidget(self.widget)
	self.gangsters = {}
	self.polygonItems = {}
	self.splineItems = {}
	self.gangsterIcons = {}
	self.gangsterIconRendered = false

	self:Refresh()
end

function M:OnUpdate()
	self:TickLines()
end

function M:RenderAllArea()
	if not self.actived then
		return
	end

	self:ClearAllArea()

	local toTopSplines = {}

	for id, _ in pairs(gMapSubSystem_Gangster.gangsters) do
		self:RenderSingleArea(id, toTopSplines)
	end

	for _, topSpline in ipairs(toTopSplines) do
		topSpline.transform:SetAsLastSibling()
	end
end

function M:RenderSingleArea(gangsterId, toTopSplines)
	if not self.actived then
		return
	end

	local renderHandler = gMapSubSystem_Gangster:GetGangsterRenderHandler(gangsterId)
	local rd = renderHandler:GetAreaRenderData()
	local gangsterSplines = {}
	local gangsterPolygons = {}
	local gangster = {
		splineItems = gangsterSplines,
		polygonItems = gangsterPolygons,
		highlighters = {}
	}
	self.gangsters[gangsterId] = gangster

	for _, splineRd in ipairs(rd.splineRds) do
		self:RenderSingleSpline(splineRd, gangsterSplines, toTopSplines)
	end

	for _, polygonRd in ipairs(rd.polygonRds) do
		local item = self.store.polygonPool:GetItem(0)
		local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(item)
		local polygon = store.polygon
		polygon.color = polygonRd.color

		for _, point in ipairs(polygonRd.points) do
			local texX, texY = self.bigMap:TransformWorldXZToTexXY(point.x, point.z, gMapAreaMgr.XinQiAreaId)

			polygon:AddPoint(texX, texY)
		end

		polygon:RefreshPolygon()

		gangsterPolygons[#gangsterPolygons + 1] = item
	end
end

function M:RenderSingleSpline(rd, container, toTopSplines)
	local item = nil

	if not rd.needMaterial and rd.isDouble then
		print_error("GangsterAreaRenderHandler:RenderSingleSpline: rd.needMaterial is false but rd.isDouble is true, INVALID")

		return
	end

	if rd.needMaterial then
		item = self.store.splinePool:GetItem(1)
	else
		item = self.store.splinePool:GetItem(0)
	end

	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(item)
	local spline1 = store.spline1
	local spline2 = store.spline2

	for _, point in ipairs(rd.points) do
		local texX, texY = self.bigMap:TransformWorldXZToTexXY(point.x, point.z, gMapAreaMgr.XinQiAreaId)

		spline1:AddPoint(texX, texY, rd.width, true, 0, rd.width / 2)

		if rd.isDouble then
			spline2:AddPoint(texX, texY, rd.width * 2, true, 0, rd.width)
		end
	end

	spline1.color = rd.color1

	spline1:RefreshSpline()

	if rd.isDouble then
		spline2.color = rd.color2

		spline2:RefreshSpline()
	end

	if toTopSplines and rd.shouldTop then
		toTopSplines[#toTopSplines + 1] = item
	end

	container[#container + 1] = {
		item = item,
		isOuter = rd.isOuter
	}
end

function M:ClearAllArea()
	if not self.gangsters then
		return
	end

	for id, gangster in pairs(self.gangsters) do
		local splineItems = gangster.splineItems

		for _, item in ipairs(splineItems) do
			self:DisposeSingleSpline(item)
		end

		local highlighters = gangster.highlighters

		for _, item in ipairs(highlighters) do
			self:DisposeSingleSpline(item)
		end

		local polygonItems = gangster.polygonItems

		for _, item in ipairs(polygonItems) do
			local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(item)
			local polygon = store.polygon

			polygon:ClearPoint()
			self.store.polygonPool:DeleteItem(item)
		end
	end

	table.clear(self.gangsters)
end

local EGangsterEventType = {
	BattleCamp = 2,
	RandomEvent = 5,
	Elite = 4,
	ConqueredCamp = 3,
	Center = 1
}

function M:OnAttachElement(id, element, source)
	self:DisposeCurrentHighlighter()

	if element.subSystemType ~= EMapSubSystemType.Gangster and element.subSystemType ~= EMapSubSystemType.Task then
		return
	end

	local type = element.userdata and element.userdata.type
	local influenceId = element.userdata and element.userdata.influenceId
	local isInformationElement = element.userdata.isCenter

	if not type and isInformationElement == nil then
		local overrideInfo = element.bigMapData.overrideTooltipInfo

		if not overrideInfo or not overrideInfo.fieldDatas.influenceId then
			return
		end

		influenceId = overrideInfo.fieldDatas.influenceId
		local influenceCfg = InfluenceEventConfig.GetConfig(influenceId)
		type = influenceCfg.Type
	end

	local toTop = {}

	if type == EGangsterEventType.Center or isInformationElement then
		local gangsterId = element.userdata.gangsterId
		self.selectedAreaInfo.gangsterId = gangsterId
		local gangster = self.gangsters[gangsterId]
		local renderHandler = gMapSubSystem_Gangster:GetGangsterRenderHandler(gangsterId)

		if not renderHandler then
			print_error("@xiajingbo01 Comp_GangsterArea:renderHandler is nil, gangsterId=" .. tostring(gangsterId) .. " elementGpsId=" .. tostring(element.gpsId))

			self.selectedAreaInfo.gangsterId = nil

			self:DisposeCurrentHighlighter()

			return
		end

		local rds = renderHandler:GetSelectGangsterAreaHighlighter()

		for _, rd in ipairs(rds) do
			self:RenderSingleSpline(rd, gangster.highlighters, toTop)
		end
	elseif type == EGangsterEventType.BattleCamp or type == EGangsterEventType.Elite then
		local influenceCfg = SmallAreaConfig.GetConfig(influenceId)

		if not influenceCfg.InfluenceAreaId or influenceCfg.InfluenceAreaId <= 0 then
			print_error_without_stack("GangsterAreaHighlight : InfluenceEvent: Id =" .. element.userdata.influenceId .. " 配置的InfluenceAreaId不合法或未配置")

			return
		end

		local smallAreaId = influenceCfg.InfluenceAreaId
		local gangsterId = gMapSubSystem_Gangster.helper:GetSmallAreaBelongGangster(smallAreaId)

		if not gangsterId then
			print_error_without_stack("GangsterAreaHighlight : 小区域 id:" .. smallAreaId .. "不存在于任何帮派.\n request by influenceId:" .. influenceId)

			return
		end

		self.selectedAreaInfo.gangsterId = gangsterId
		self.selectedAreaInfo.smallAreaId = smallAreaId
		local gangster = self.gangsters[gangsterId]
		local renderHandler = gMapSubSystem_Gangster:GetGangsterRenderHandler(gangsterId)

		if not renderHandler then
			print_error("@xiajingbo01 Comp_GangsterArea:renderHandler is nil, gangsterId=" .. tostring(gangsterId) .. " elementGpsId=" .. tostring(element.gpsId))

			self.selectedAreaInfo.gangsterId = nil
			self.selectedAreaInfo.smallAreaId = nil

			self:DisposeCurrentHighlighter()

			return
		end

		local rd = renderHandler:GetSelectSmallAreaHighlighter(self.selectedAreaInfo.smallAreaId)

		self:RenderSingleSpline(rd, gangster.highlighters, toTop)
	end

	self:TopSplines(toTop)
end

function M:OnClearAttachedElement()
	self:DisposeCurrentHighlighter()
end

function M:DisposeCurrentHighlighter()
	if self.selectedAreaInfo.gangsterId ~= nil then
		local gangster = self.gangsters[self.selectedAreaInfo.gangsterId]

		for _, splineInfo in ipairs(gangster.highlighters) do
			self:DisposeSingleSpline(splineInfo)
		end

		table.clear(gangster.highlighters)

		self.selectedAreaInfo.gangsterId = nil
		self.selectedAreaInfo.smallAreaId = nil
	end
end

function M:DisposeSingleSpline(splineInfo)
	local widget = splineInfo.item

	if not widget then
		return
	end

	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(widget)

	if store.spline1 then
		local spline1 = store.spline1

		spline1:ClearPoint()
	end

	if store.spline2 then
		local spline2 = store.spline2

		spline2:ClearPoint()
	end

	self.store.splinePool:DeleteItem(widget)
end

function M:TopSplines(toTop)
	for _, topSpline in ipairs(toTop) do
		topSpline.transform:SetAsLastSibling()
	end
end

function M:TickLines()
	if not self.gangsters or table.count(self.gangsters) == 0 then
		return
	end

	if self.prevMapScale ~= self.bigMap.curScaleLevel then
		if self.bigMap.curScaleLevel == 1 then
			for id, gangster in pairs(self.gangsters) do
				local splineItems = gangster.splineItems

				for _, info in ipairs(splineItems) do
					if not info.isOuter then
						info.item:SetActive(false)
					end
				end
			end
		elseif self.prevMapScale == 1 then
			for id, gangster in pairs(self.gangsters) do
				local splineItems = gangster.splineItems

				for _, info in ipairs(splineItems) do
					if not info.isOuter then
						info.item:SetActive(true)
					end
				end
			end
		end

		self.prevMapScale = self.bigMap.curScaleLevel
	end
end
