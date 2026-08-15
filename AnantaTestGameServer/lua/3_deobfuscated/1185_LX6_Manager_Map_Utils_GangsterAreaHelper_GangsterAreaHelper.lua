require("LX6/Manager/Map/Utils/GangsterAreaHelper/GangsterAreaRenderHandler")

local FactionConfig = LTConfig.FactionConfig
local PointConfig = LTConfig.FactionAreaPointConfig
local SmallAreaConfig = LTConfig.FactionInfluenceAreaConfig
local Vector2 = Vector2
local MY_GANGSTER = FactionConfig.JiaMuFaction
GangsterAreaHelper = DefClass("GangsterAreaHelper", GangsterAreaHelper)
local M = GangsterAreaHelper

function M:ctor()
	self.points = {}
	self.gangsterElements = {}
end

function M:OnLogin()
	self:LoadPoints()
	self:InitGangsters()
	self:RecreateGangsterElements()
end

function M:Clear()
	for _, element in pairs(self.gangsterElements) do
		element:Dispose()
	end
end

function M:LoadPoints()
	table.clear(self.points)

	for i = 0, PointConfig.count - 1 do
		local cfg = PointConfig.LoadAt(i)
		local pos = cfg.PosXZ
		self.points[cfg.Id] = Vector2.New(pos.x, pos.y)
	end
end

function M:InitGangsters()
	self.gangsters = {}
	local gangsterAreaMap = {}

	for i = 0, FactionConfig.count - 1 do
		local cfg = FactionConfig.LoadAt(i)
		local id = cfg.Id

		if id >= 18000000 and id < 18009999 then
			if (not cfg.BaseCampLocation or #cfg.BaseCampLocation) ~= 0 then
				gangsterAreaMap[id] = {}
			end
		end
	end

	local occupiedAreas = gPlayerManager.infoAchievement.bindData.OccupiedInfluenceArea

	for i = 0, SmallAreaConfig.count - 1 do
		local cfg = SmallAreaConfig.LoadAt(i)
		local factionId = cfg.FactionId

		if not gangsterAreaMap[factionId] then
			-- Nothing
		elseif factionId == MY_GANGSTER then
			gangsterAreaMap[factionId][cfg.Id] = true
		elseif array.contains(occupiedAreas, cfg.Id) then
			gangsterAreaMap[MY_GANGSTER][cfg.Id] = true
		else
			gangsterAreaMap[factionId][cfg.Id] = true
		end
	end

	for id, initAreas in pairs(gangsterAreaMap) do
		self.gangsters[id] = GangsterAreaRenderHandler.new(id, initAreas, self.points)
	end
end

function M:OnOccupyArea(areaId, occupy)
	local cfg = SmallAreaConfig.GetConfig(areaId)
	local factionId = cfg and cfg.FactionId

	if not factionId or factionId == MY_GANGSTER then
		print_error("GangsterAreaHelper: OnOccupyArea: areaId =" .. areaId .. " 配置错误 factionId=" .. tostring(factionId))

		return
	end

	if occupy then
		self.gangsters[factionId]:TryRemoveArea(areaId)
		self.gangsters[MY_GANGSTER]:TryAddArea(areaId)
	else
		self.gangsters[MY_GANGSTER]:TryRemoveArea(areaId)
		self.gangsters[factionId]:TryAddArea(areaId)
	end

	self:RecreateGangsterElements()
end

function M:GetRenderHandler(gangsterId)
	return self.gangsters[gangsterId]
end

function M:GetSmallAreaBelongGangster(areaId)
	for gangsterId, handler in pairs(self.gangsters) do
		if handler.smallAreas[areaId] then
			return gangsterId
		end
	end

	return nil
end

function M:RecreateGangsterElements()
	for _, element in pairs(self.gangsterElements) do
		element:Dispose()
	end

	table.clear(self.gangsterElements)

	for gangsterId, handler in pairs(self.gangsters) do
		local elemIndex = 0

		for _, areaGroup in pairs(handler.areaGroups) do
			if gangsterId == MY_GANGSTER and not handler:IsMyInitAreaGroup(areaGroup) then
				-- Nothing
			else
				local pos = handler:GetMidOfAreaGroup(areaGroup)

				if not pos then
					print_error("GangsterAreaHelper: RecreateGangsterElements: gangsterId =" .. gangsterId .. " 计算区域中心点失败")
				else
					elemIndex = elemIndex + 1
					local gangsterCfg = FactionConfig.GetConfig(gangsterId)
					local element = MapElement.CreateLegacy(EMapElementType.Gangster, "GangsterCenter_" .. gangsterId .. elemIndex, EMapSubSystemType.Gangster, EMapViewMask.Gangster + EMapViewMask.HudGps, 23300888)
					element.fData.ignoreFog = false
					element.fData.bigMapTIndex = 6
					element.mData.sIconId = gangsterCfg.imageId
					element.userdata = {
						isCenter = true,
						gangsterId = gangsterId
					}

					element:SetPosition(pos)
					element:SetVisible(true)

					element.bigMapData.customRenderFuncKey = "OnCustomRenderGangsterIcon"
					element.bigMapData.customAddElemFuncKey = "OnCustomAddGangsterIcon"
					element.mData.lName = GpsLText.CreateCommonText(gangsterCfg, "name", gangsterCfg.name)

					gMapSubSystemUtils:SetupScaleLevel(element, 2, nil)
					table.insert(self.gangsterElements, element)
				end
			end
		end
	end
end

function M:BuildColorWidthCache()
	for _, handler in pairs(self.gangsters) do
		handler:BuildColorWidthCache()
	end
end

function M:ClearColorWidthCache()
	for _, handler in pairs(self.gangsters) do
		handler:ClearColorWidthCache()
	end
end
