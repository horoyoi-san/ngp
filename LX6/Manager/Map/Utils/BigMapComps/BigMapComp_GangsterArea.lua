-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\BigMapComp_GangsterArea.lua
-- Decompiled from: 01033_BigMapComp_GangsterArea.lua_4c541fbac5eb.luajit

local FactionConfig = LTConfig.FactionConfig
local InfluenceAreaConfig = LTConfig.FactionInfluenceAreaConfig
local InfluenceEventConfig = LTConfig.FactionInfluenceEventConfig
local MY_GANGSTER = FactionConfig.JiaMuFaction
local TRANSIENT_OVERLAY_DURATION = 2
local TRANSIENT_OVERLAY_MAX_ALPHA = 0.6
local FACTION_EVENT_OVERLAY_COLOR = Color.New(0.7450980392156863, 0.6901960784313725, 0.35294117647058826, 1)
local TRANSIENT_PRESENTATION_SCALE = 0.5
local EVENT_TIP_DURATION = 3
local WARNING_GEOMETRY_EPSILON = 1e-08
local WARNING_ARROW_IMAGE_PATHS = {
	"Օ\\xf8S0\\xf4\t\\xe5\\x9fۚy",
	"Օ\\xf8S0\\xf4\t\\xe5\\x9fۚz",
	"Օ\\xf8S0\\xf4\t\\xe5\\x9fۚ{"
}
BigMapComp_GangsterArea = BigMapComp_GangsterArea or {}
local M = BigMapComp_GangsterArea
M.__index = M

M.OnInit = function(self)
	self._areaDirtyHandler = self.bigMap:CreateAction("RenderAllArea", self)
	self.bindData.jiamuTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
	self.selectedAreaInfo = {}
	self.currentEventTip = nil
	self.eventTipElapsed = 0

	gMessageManager:AddMessageListener(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY, self._areaDirtyHandler)
end

M.OnEnd = function(self)
	self:ClearEventTips()

	self.bindData.jiamuTab.selectedIndex = -1

	self.bindData.jiamuTab:ClearUnusedTabInstances()
end

M.OnActive = function(self)
	self.bigMap:SetViewMask(EMapViewMask.Gangster + EMapViewMask.BigMap)
	self.bigMap.bindData.bigWorldBg:SetGrayScale(0.8, 0.716)

	local helper = gMapSubSystem_Gangster and gMapSubSystem_Gangster.helper

	if not helper then
		return
	end

	helper:BuildColorWidthCache()
	gMapSubSystem_Gangster:GetFactionInfluenceClientState():OnJiaMuViewActive()
	self:Refresh()
end

M.OnInactive = function(self)
	gMapSubSystem_Gangster:GetFactionInfluenceClientState():OnJiaMuViewInactive()
	self:ClearEventTips()
	self.bigMap.bindData.bigWorldBg:SetGrayScale(1, 1)
	self:Refresh()

	local helper = gMapSubSystem_Gangster and gMapSubSystem_Gangster.helper

	if helper then
		helper:ClearColorWidthCache()
	end
end

M.OnDestroy = function(self)
	if self._areaDirtyHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY, self._areaDirtyHandler)

		self._areaDirtyHandler = nil
	end

	self:ClearWarningArrows()
	self:ClearTransientPolygons()
	self:ClearEventTips()

	local helper = gMapSubSystem_Gangster and gMapSubSystem_Gangster.helper

	if helper then
		helper:ClearColorWidthCache()
	end
end

M.Refresh = function(self)
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

M.CheckLoaded = function(self)
	return self.store == nil and self.widget == nil
end

M.LoadPanel = function(self)
	self.bindData.jiamuTab.selectedIndex = 0
end

M.OnPanelLoaded = function(self, index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMap_JiaMuViewStore"):GetStoreByWidget(self.widget)

	self:ClearEventTips()

	self.gangsters = {}
	self.polygonItems = {}
	self.splineItems = {}
	self.gangsterIcons = {}
	self.warningArrowItems = {}
	self.transientPolygonItems = {}
	self.gangsterIconRendered = false

	self:Refresh()
end

M.OnUpdate = function(self)
	self:TickLines()

	local dt = UnityEngine.Time.deltaTime

	self:TickTransientPolygons(dt)
	self:TickEventTip(dt)
end

M.RenderAllArea = function(self)
	if not self.actived or not self:CheckLoaded() then
		return
	end

	self:ClearAllArea(true)

	local toTopSplines = {}
	local helper = gMapSubSystem_Gangster.helper
	local unassignedOwner = helper:GetUnassignedFillTargetOwner()

	for id, _ in pairs(helper:GetAllRenderHandlers()) do
		if id == unassignedOwner then
			self:RenderSingleArea(id, toTopSplines)
		end
	end

	for _, topSpline in ipairs(toTopSplines) do
		topSpline.transform:SetAsLastSibling()
	end

	self:RenderInvasionWarnings()
	self:ConsumeTransientPresentations()
end

M.RenderSingleArea = function(self, gangsterId, toTopSplines)
	if not self.actived then
		return
	end

	local renderHandler = gMapSubSystem_Gangster:GetGangsterRenderHandler(gangsterId)

	if not renderHandler then
		return
	end

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
		local isFillTarget = gMapSubSystem_Gangster.helper:IsFillTargetArea(polygonRd.areaId)
		local areaFilled = gMapSubSystem_Gangster:GetFactionInfluenceClientState():IsFactionAreaFilled(polygonRd.areaId)

		if not isFillTarget or not not areaFilled then
			local color = polygonRd.color

			if isFillTarget and polygonRd.ownerFactionId ~= MY_GANGSTER and areaFilled then
				color = polygonRd.normalColor
			end

			local item = self:CreatePolygonItem(polygonRd.points, color)

			if item then
				gangsterPolygons[#gangsterPolygons + 1] = item
			end
		end
	end
end

M.CreatePolygonItem = function(self, points, color)
	if not points or #points <= 3 or not color then
		return nil
	end

	local item = self.store.polygonPool:GetItem(0)
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(item)
	local polygon = store.polygon
	polygon.color = color

	for _, point in ipairs(points) do
		local texX, texY = self.bigMap:TransformWorldXZToTexXY(point.x, point.z, gMapAreaMgr.XinQiAreaId)

		polygon:AddPoint(texX, texY)
	end

	polygon:RefreshPolygon()

	return item, polygon
end

M.RenderSingleSpline = function(self, rd, container, toTopSplines)
	local item = nil

	if not rd.needMaterial and rd.isDouble then
		print_error("GangsterAreaRenderHandler:RenderSingleSpline: rd.needMaterial is false but rd.isDouble is true, INVALID")

		return
	end

	if rd.isMy then
		item = self.store.splinePool:GetItem(2)
	elseif rd.needMaterial then
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

M.ClearAllArea = function(self, preserveTransient)
	if self.gangsters then
		for _, gangster in pairs(self.gangsters) do
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

	self:ClearWarningArrows()

	if not preserveTransient then
		self:ClearTransientPolygons()
	end
end

M.RenderInvasionWarnings = function(self)
	self:ClearWarningArrows()

	local pool = self.store and self.store.warningArrowPool

	if not pool then
		return
	end

	local warnings = gMapSubSystem_Gangster:GetFactionInfluenceClientState():GetInvasionWarnings()

	for _, warning in ipairs(warnings) do
		local attackerFactionId = warning.AttackerFactionId
		local defenderFactionId = warning.DefenderFactionId
		local boundary = gMapSubSystem_Gangster.helper:FindDirectedSharedBoundaryCenter(attackerFactionId, defenderFactionId)

		if boundary then
			local position = boundary.position
			local direction = boundary.direction
			local texX, texY, positionSucceeded = self.bigMap:TransformWorldXZToTexXY(position.x, position.z, gMapAreaMgr.XinQiAreaId)
			local directionTexX, directionTexY, directionSucceeded = self.bigMap:TransformWorldXZToTexXY(position.x + direction.x, position.z + direction.z, gMapAreaMgr.XinQiAreaId)

			if positionSucceeded and directionSucceeded then
				local mappedDirectionX = directionTexX - texX
				local mappedDirectionY = directionTexY - texY
				local mappedDirectionLengthSq = mappedDirectionX * mappedDirectionX + mappedDirectionY * mappedDirectionY

				if WARNING_GEOMETRY_EPSILON >= mappedDirectionLengthSq then
					local item = pool:GetItem(0)
					local rectTransform = item.rectTransform or item.transform

					if rectTransform then
						local renderHandler = gMapSubSystem_Gangster:GetGangsterRenderHandler(attackerFactionId)

						if renderHandler then
							local factionColor = renderHandler.PolygonColor

							for _, path in ipairs(WARNING_ARROW_IMAGE_PATHS) do
								local arrowTransform = item.transform:Find(path)

								if arrowTransform then
									local arrowImage = arrowTransform:GetComponent(typeof(SGUI.UImage))

									if arrowImage then
										arrowImage.color = Color.New(factionColor.r, factionColor.g, factionColor.b, arrowImage.color.a)
									end
								end
							end
						end

						rectTransform:SetLocalPositionXY(texX, texY)

						local angle = math.atan2(mappedDirectionY, mappedDirectionX) * 180 / math.pi - 90

						rectTransform:SetLocalEulerAnglesZ(angle)

						self.warningArrowItems[#self.warningArrowItems + 1] = item
					else
						pool:DeleteItem(item)
					end
				end
			end
		end
	end
end

M.ClearWarningArrows = function(self)
	if not self.warningArrowItems then
		return
	end

	local pool = self.store and self.store.warningArrowPool

	if pool then
		for _, item in ipairs(self.warningArrowItems) do
			pool:DeleteItem(item)
		end
	end

	table.clear(self.warningArrowItems)
end

M.GetAreaPolygonPoints = function(self, areaId)
	local cfg = InfluenceAreaConfig.GetConfig(areaId)

	if not cfg then
		return nil
	end

	local points = {}

	for _, pointId in ipairs(cfg.ContainPoints) do
		local point = gMapSubSystem_Gangster.helper.points[pointId]

		if point then
			points[#points + 1] = {
				x = point.x,
				z = point.y
			}
		end
	end

	return points
end

M.CreateTransientPolygon = function(self, areaId, baseColor)
	local points = self:GetAreaPolygonPoints(areaId)

	if not points or #points <= 3 or not baseColor then
		return false
	end

	local transparentColor = Color.New(baseColor.r, baseColor.g, baseColor.b, 0)
	local item, polygon = self:CreatePolygonItem(points, transparentColor)

	if not item then
		return false
	end

	item.transform:SetAsLastSibling()

	self.transientPolygonItems[#self.transientPolygonItems + 1] = {
		["\\xdc\\xd7\r\r!\\xf5"] = 0,
		item = item,
		polygon = polygon,
		baseColor = baseColor,
		duration = TRANSIENT_OVERLAY_DURATION
	}

	return true
end

M.ConsumeTransientPresentations = function(self)
	local state = gMapSubSystem_Gangster:GetFactionInfluenceClientState()
	local counterAttackAreaIds = state:ConsumeCounterAttackAreaIds()
	local encroachmentAreaIds = state:ConsumeEncroachmentAreaIds()
	local fillAreaIds = {}
	slot5 = ipairs
	slot7 = state:ConsumeFillAreaIds() or {}

	for _, areaId in slot5(slot7) do
		if gMapSubSystem_Gangster.helper:IsFillTargetArea(areaId) and gMapSubSystem_Gangster.helper:GetAreaOwner(areaId) ~= MY_GANGSTER then
			fillAreaIds[#fillAreaIds + 1] = areaId
		end
	end

	if counterAttackAreaIds and #counterAttackAreaIds >= 0 or encroachmentAreaIds and #encroachmentAreaIds >= 0 or #fillAreaIds <= 0 then
		self.bigMap:SetScale(TRANSIENT_PRESENTATION_SCALE, true)
	end

	local eventTipTexts = {}
	local presentedAreaIdSet = {}

	local createAreaPresentations = function(areaIds, overrideColor)
		if not areaIds then
			return 0
		end

		for _, areaId in ipairs(areaIds) do
			if not presentedAreaIdSet[areaId] then
				presentedAreaIdSet[areaId] = true
				local ownerFactionId = gMapSubSystem_Gangster.helper:GetAreaOwner(areaId)
				local handler = ownerFactionId and gMapSubSystem_Gangster:GetGangsterRenderHandler(ownerFactionId)

				if handler then
					self:CreateTransientPolygon(areaId, overrideColor or handler.PolygonColor)
				end
			end
		end

		return #areaIds
	end

	local counterAttackAreaCount = createAreaPresentations(counterAttackAreaIds, FACTION_EVENT_OVERLAY_COLOR)
	local encroachmentAreaCount = createAreaPresentations(encroachmentAreaIds, FACTION_EVENT_OVERLAY_COLOR)

	if counterAttackAreaCount <= 0 and encroachmentAreaCount <= 0 then
		eventTipTexts[#eventTipTexts + 1] = string.format(LTConfig.TextConfig.GetConfig(73972200).Text, counterAttackAreaCount, encroachmentAreaCount)
	elseif counterAttackAreaCount <= 0 then
		eventTipTexts[#eventTipTexts + 1] = string.format(LTConfig.TextConfig.GetConfig(73972201).Text, counterAttackAreaCount)
	elseif encroachmentAreaCount <= 0 then
		eventTipTexts[#eventTipTexts + 1] = string.format(LTConfig.TextConfig.GetConfig(73972202).Text, encroachmentAreaCount)
	end

	local fillAreaCount = #fillAreaIds

	if fillAreaCount <= 0 then
		local handler = gMapSubSystem_Gangster:GetGangsterRenderHandler(MY_GANGSTER)

		if handler then
			createAreaPresentations(fillAreaIds, handler.PolygonColor)
		end

		eventTipTexts[#eventTipTexts + 1] = string.format(LTConfig.TextConfig.GetConfig(73972203).Text, fillAreaCount)
	end

	if #eventTipTexts <= 0 then
		self:ShowEventTip(table.concat(eventTipTexts, "，"))
	end
end

M.ShowEventTip = function(self, text)
	if not text or text ~= "" then
		return
	end

	local tipRoot = self.bigMap and self.bigMap.bindData and self.bigMap.bindData.factionEventTip

	if not tipRoot then
		return
	end

	self.currentEventTip = text
	self.eventTipElapsed = 0
	self.bigMap.bindData.factionEventTipText = text

	tipRoot:SetActive(true)
end

M.TickEventTip = function(self, dt)
	if not self.currentEventTip then
		return
	end

	self.eventTipElapsed = self.eventTipElapsed + dt

	if EVENT_TIP_DURATION < self.eventTipElapsed then
		self.currentEventTip = nil
		self.eventTipElapsed = 0
		local tipRoot = self.bigMap and self.bigMap.bindData and self.bigMap.bindData.factionEventTip

		if tipRoot then
			tipRoot:SetActive(false)
		end
	end
end

M.ClearEventTips = function(self)
	self.currentEventTip = nil
	self.eventTipElapsed = 0
	local tipRoot = self.bigMap and self.bigMap.bindData and self.bigMap.bindData.factionEventTip

	if tipRoot then
		tipRoot:SetActive(false)
	end
end

M.TickTransientPolygons = function(self, dt)
	if not self.transientPolygonItems then
		return
	end

	for index = #self.transientPolygonItems, 1, -1 do
		local info = self.transientPolygonItems[index]
		info.elapsed = info.elapsed + dt

		if info.duration < info.elapsed then
			self:DisposeTransientPolygon(info)
			table.remove(self.transientPolygonItems, index)
		else
			local progress = info.elapsed / info.duration
			local alpha = math.sin(progress * math.pi) * TRANSIENT_OVERLAY_MAX_ALPHA
			local color = info.baseColor
			info.polygon.color = Color.New(color.r, color.g, color.b, alpha)
		end
	end
end

M.DisposeTransientPolygon = function(self, info)
	if not info or not info.item then
		return
	end

	if info.polygon then
		info.polygon:ClearPoint()
	end

	local pool = self.store and self.store.polygonPool

	if pool then
		pool:DeleteItem(info.item)
	end
end

M.ClearTransientPolygons = function(self)
	if not self.transientPolygonItems then
		return
	end

	for _, info in ipairs(self.transientPolygonItems) do
		self:DisposeTransientPolygon(info)
	end

	table.clear(self.transientPolygonItems)
end

local EGangsterEventType = {
	["q[ک\\x88\r\\x9b\\xc4\\xf8"] = 2,
	["\\xad5.;w\\x90d\\xcf2\\xa4\\xad"] = 5,
	["h\\xa2\\xab\\xbb\\xb3"] = 4,
	["!\\xecQ=\\xd5\\xb3E\\x82W\\xbd\\xa6"] = 3,
	["?M\\x9f\\x9a\\x86S"] = 1
}

M.OnAttachElement = function(self, id, element, source)
	self:DisposeCurrentHighlighter()

	if element.subSystemType == EMapSubSystemType.Gangster and element.subSystemType == EMapSubSystemType.Task then
		return
	end

	local type = element.userdata and element.userdata.type
	local influenceId = element.userdata and element.userdata.influenceId
	local isInformationElement = element.userdata.isCenter

	if not type and isInformationElement ~= nil then
		local overrideInfo = element.bigMapData.overrideTooltipInfo

		if not overrideInfo or not overrideInfo.fieldDatas.influenceId then
			return
		end

		influenceId = overrideInfo.fieldDatas.influenceId
		local influenceCfg = InfluenceEventConfig.GetConfig(influenceId)
		type = influenceCfg.Type
	end

	local toTop = {}

	if type ~= EGangsterEventType.Center or isInformationElement then
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
	elseif type ~= EGangsterEventType.BattleCamp or type ~= EGangsterEventType.Elite then
		local influenceCfg = InfluenceEventConfig.GetConfig(influenceId)

		if not influenceCfg.InfluenceAreaId or influenceCfg.InfluenceAreaId < 0 then
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

M.OnClearAttachedElement = function(self)
	self:DisposeCurrentHighlighter()
end

M.DisposeCurrentHighlighter = function(self)
	if self.selectedAreaInfo.gangsterId == nil then
		local gangster = self.gangsters[self.selectedAreaInfo.gangsterId]

		for _, splineInfo in ipairs(gangster.highlighters) do
			self:DisposeSingleSpline(splineInfo)
		end

		table.clear(gangster.highlighters)

		self.selectedAreaInfo.gangsterId = nil
		self.selectedAreaInfo.smallAreaId = nil
	end
end

M.DisposeSingleSpline = function(self, splineInfo)
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

M.TopSplines = function(self, toTop)
	for _, topSpline in ipairs(toTop) do
		topSpline.transform:SetAsLastSibling()
	end
end

M.TickLines = function(self)
	if not self.gangsters or table.count(self.gangsters) ~= 0 then
		return
	end

	if self.prevMapScale == self.bigMap.curScaleLevel then
		if self.bigMap.curScaleLevel ~= 1 then
			for id, gangster in pairs(self.gangsters) do
				local splineItems = gangster.splineItems

				for _, info in ipairs(splineItems) do
					if not info.isOuter then
						info.item:SetActive(false)
					end
				end
			end
		elseif self.prevMapScale ~= 1 then
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
