local IndoorMapFunctionPoint = LTConfig.IndoorMapFunctionPointConfig
local IndoorConfig = LTConfig.IndoorConfig
local actionHelper = require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")
local MapBlockMgr = LX6.Gps.MapBlockMgr
MapSubSystem_FunctionPoint = DefClass("MapSubSystem_FunctionPoint", MapSubSystem_FunctionPoint, MapSubSystemBase)
local M = MapSubSystem_FunctionPoint

function M:OnInit()
	self.functionPointInfos = {}
	self.indoorInfos = {}
	self._inviteRidePointInfos = {}
	self._raidType2IdToCountryId = {}
	self.eventHandler = {
		[gEventConstants.MAP_BLOCK_UPDATE] = function ()
			self:FlushData("BlockUpdate")
		end,
		[gEventConstants.MAP_INFO_UPDATE] = function ()
			self:FlushData("LegacyMapInfoUpdate")
		end,
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = function ()
			self:FlushData("SystemUnlock")
		end
	}
	self._inviteRideHighlight = false

	self:SetUpInviteRideFailCb()
end

function M:OnLogin()
	gMessageManager:RegisterEventHandlers(self.eventHandler)

	for i = 0, IndoorMapFunctionPoint.count - 1 do
		local cfg = IndoorMapFunctionPoint.LoadAt(i)

		if cfg.ShowType then
			if cfg.ShowType == 0 then
				-- Nothing
			elseif not cfg.Coordinate or #cfg.Coordinate < 3 then
				print_error("配表错误 IndoorMapFunctionPointConfig=" .. cfg.Id .. " Coordinate未配置")
			else
				local coord = cfg.Coordinate
				local worldPos = Vector3.New(coord[1], coord[2], coord[3])
				local raidId = cfg.RaidId and cfg.RaidId > 0 and cfg.RaidId or LTConfig.RaidConfig.WorldMap
				local blockId = MapBlockMgr.GetBlockIdXZ(raidId, coord[1], coord[3])
				local element = MapElement.CreateLegacy(EMapElementType.Compound, cfg.Id, EMapSubSystemType.FunctionPoint, EMapViewMask.AllSgui, raidId, 0)

				if cfg.SIconId and array.contains(LTConfig.GpsConfig.MainStoreIcon, cfg.SIconId) then
					element.bigMapData.iconSizeType = 1
				end

				if cfg.IsAboveFog then
					element.fData.ignoreFog = true
				end

				element.userdata = {
					type = "FunctionPoint",
					cfgId = cfg.Id
				}

				if cfg.BadgeRequired and cfg.BadgeRequired > 0 then
					element.fData.requireBadges = {
						cfg.BadgeRequired
					}
				end

				local limitSpirits = gMapSubSystemUtils:GetLegalSpiritList(cfg.ShowLimitSpirit)

				if limitSpirits and #limitSpirits > 0 then
					element.fData.bigMapLimitSpirits = limitSpirits
					element.fData.miniMapLimitSpirits = limitSpirits
				end

				if #cfg.LinkShowMode > 0 then
					element.fData.linkShowModes = cfg.LinkShowMode
				end

				element.fData.showInBigWorld = true

				element:SetPosition(worldPos)

				element.mData.sIconId = cfg.SIconId
				element.mData.lName = GpsLText.CreateCommonText(cfg, "Name")
				element.gpsData.removeGpsRange = LTConfig.GameConfig.FunctionPointAutoRemoveGpsRange
				element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

				if cfg.SMiniMapIconId and cfg.SMiniMapIconId > 0 then
					element.miniMapData.iconId = cfg.SMiniMapIconId
				end

				gMapSubSystemUtils:SetupScaleLevel(element, cfg.ShowType, cfg.SQuestIcon2)

				self.functionPointInfos[cfg.Id] = {
					mapElement = element,
					blockId = blockId
				}

				if cfg.InviteRideTaskId and cfg.InviteRideTaskId ~= 0 then
					local highlightInfo = {
						mapElement = element,
						originIconId = cfg.SIconId,
						highlightIconId = cfg.InviteRideHighlightIconId,
						taskId = cfg.InviteRideTaskId,
						originIconScaleLevel = element.bigMapData.iconScaleType
					}
					self._inviteRidePointInfos[cfg.Id] = highlightInfo
				end
			end
		end
	end

	table.clear(self._raidType2IdToCountryId)

	for i = 0, IndoorConfig.count - 1 do
		local cfg = IndoorConfig.LoadAt(i)

		if cfg.SceneId and cfg.SceneId > 0 then
			self._raidType2IdToCountryId[cfg.SceneId] = cfg.CountryId
		end

		if cfg.ShowType then
			if cfg.ShowType == 0 then
				-- Nothing
			elseif not cfg.Coordinate or #cfg.Coordinate < 3 then
				print_error("配表错误 IndoorConfig=" .. cfg.Id .. " Coordinate未配置")
			else
				local coord = cfg.Coordinate
				local worldPos = Vector3.New(coord[1], coord[2], coord[3])
				local raidId = cfg.ParentRaid and cfg.ParentRaid > 0 and cfg.ParentRaid or LTConfig.RaidConfig.WorldMap
				local blockId = MapBlockMgr.GetBlockIdXZ(raidId, coord[1], coord[3])
				local element = MapElement.CreateLegacy(EMapElementType.Compound, cfg.Id, EMapSubSystemType.FunctionPoint, EMapViewMask.AllSgui, raidId)

				if cfg.SIconId and array.contains(LTConfig.GpsConfig.MainStoreIcon, cfg.SIconId) then
					element.bigMapData.iconSizeType = 1
				end

				if cfg.IsAboveFog then
					element.fData.ignoreFog = true
				end

				element.userdata = {
					type = "Indoor",
					cfgId = cfg.Id
				}

				element:SetOverrideBoundInfo(0, 0)
				element:SetPosition(worldPos)

				element.mData.lName = GpsLText.CreateCommonText(cfg, "Name")
				element.mData.sIconId = cfg.SIconId
				element.gpsData.removeGpsRange = LTConfig.GameConfig.FunctionPointAutoRemoveGpsRange
				element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect
				element.fData.representGBoundId = gMapSystem.area:GetGBoundId(raidId, cfg.Id, 0)
				local limitSpirits = gMapSubSystemUtils:GetLegalSpiritList(cfg.ShowLimitSpirit)

				if limitSpirits and #limitSpirits > 0 then
					element.fData.bigMapLimitSpirits = limitSpirits
					element.fData.miniMapLimitSpirits = limitSpirits
				end

				if #cfg.LinkShowMode > 0 then
					element.fData.linkShowModes = cfg.LinkShowMode
				end

				if cfg.SMiniMapIconId and cfg.SMiniMapIconId > 0 then
					element.miniMapData.iconId = cfg.SMiniMapIconId
				end

				gMapSubSystemUtils:SetupScaleLevel(element, cfg.ShowType, 28001287)

				self.indoorInfos[cfg.Id] = {
					mapElement = element,
					blockId = blockId
				}

				if cfg.InviteRideTaskId and cfg.InviteRideTaskId ~= 0 then
					local highlightInfo = {
						mapElement = element,
						originIconId = cfg.SIconId,
						highlightIconId = cfg.InviteRideHighlightIconId,
						taskId = cfg.InviteRideTaskId,
						originIconScaleLevel = element.bigMapData.iconScaleType
					}
					self._inviteRidePointInfos[cfg.Id] = highlightInfo
				end
			end
		end
	end
end

function M:OnLogout()
	gMessageManager:UnregisterEventHandlers(self.eventHandler)

	for _, info in pairs(self.functionPointInfos) do
		info.mapElement:Dispose()
	end

	for _, info in pairs(self.indoorInfos) do
		info.mapElement:Dispose()
	end

	table.clear(self.functionPointInfos)
	table.clear(self.indoorInfos)
end

function M:OnFlushData()
	for id, info in pairs(self.functionPointInfos) do
		local cfg = IndoorMapFunctionPoint.GetConfig(id)
		local visible = (not cfg.SystemUnlock or cfg.SystemUnlock == 0 or gSystemUnlockMgr:IsUnlock(cfg.SystemUnlock)) and (not info.blockId or info.blockId == 0 or gBlockMgr:IsBlockUnlocked(info.blockId))
		local element = info.mapElement

		element:SetActions(self.NormalTraceableActions)
		element:SetVisible(visible)
	end

	for id, info in pairs(self.indoorInfos) do
		local cfg = IndoorConfig.GetConfig(id)
		local visible = (not cfg.SystemUnlock or cfg.SystemUnlock == 0 or gSystemUnlockMgr:IsUnlock(cfg.SystemUnlock)) and (not info.blockId or info.blockId == 0 or gBlockMgr:IsBlockUnlocked(info.blockId))
		local element = info.mapElement

		element:SetActions(self.NormalTraceableActions)
		element:SetVisible(visible)
	end
end

function M:SGetTooltipInfo(id, element)
	local cfgId = element.userdata.cfgId
	local type = element.userdata.type

	if type == "FunctionPoint" then
		local cfg = IndoorMapFunctionPoint.GetConfig(cfgId)
		local tooltipInfo = {
			type = EMapTooltipType.Indoor,
			header = {
				name = cfg.Name,
				imageId = cfg.SImageId
			},
			indoorInfo = {
				indoorType = 1,
				id = cfg.Id
			}
		}

		return tooltipInfo
	else
		local cfg = IndoorConfig.GetConfig(cfgId)
		local shopTypeCfg = nil

		if cfg.ShopType and cfg.ShopType > 0 then
			shopTypeCfg = LTConfig.IndoorShopTypeConfig.GetConfig(cfg.ShopType)
		end

		local subtitle = ""

		if shopTypeCfg then
			subtitle = shopTypeCfg.TypeName
		end

		local tooltipInfo = {
			type = EMapTooltipType.Indoor,
			header = {
				name = cfg.Name,
				imageId = cfg.SImageId,
				subtitle = subtitle
			},
			indoorInfo = {
				indoorType = 0,
				id = cfg.Id,
				factionId = cfg.FactionId and cfg.FactionId > 0 and cfg.FactionId or nil
			}
		}

		return tooltipInfo
	end
end

function M:TryTraceByFunctionPointId(id)
	local info = self.functionPointInfos[id]

	if not info then
		return false
	end

	local element = info.mapElement

	actionHelper.Trace(element)

	return true
end

function M:ExecuteAction(element, action, ctx)
	if self._inviteRideHighlight then
		if action == gMapSystemElementAction.Trace then
			actionHelper.Trace(element)
			self:TryAcceptInviteRideTask(element)
		elseif action == gMapSystemElementAction.Untrace then
			actionHelper.Untrace(element)
			self:TryGiveUpInviteRideTask(element)
		end
	else
		actionHelper.TryExecuteTraceAction(element, action, ctx)
	end
end

function M:IsInInviteRiding()
	local gpsId = self.env.trace.mainTraceGpsId

	if not gpsId then
		return false
	end

	local element = gMapSystem.container:GetByGpsId(gpsId)

	if element and element.userdata and element.userdata.cfgId then
		local cfgId = element.userdata.cfgId

		if self._inviteRidePointInfos[cfgId] then
			return true
		end
	end

	return false
end

function M:EnableInviteRideHighlight(enable)
	local oldEnable = self._inviteRideHighlight
	self._inviteRideHighlight = enable

	if enable then
		for _, highlightInfo in pairs(self._inviteRidePointInfos) do
			local element = highlightInfo.mapElement

			if element then
				element.mData.sIconId = highlightInfo.highlightIconId
				element.bigMapData.iconScaleType = 1
			end
		end
	else
		for _, highlightInfo in pairs(self._inviteRidePointInfos) do
			local element = highlightInfo.mapElement

			if element then
				element.mData.sIconId = highlightInfo.originIconId
				element.bigMapData.iconScaleType = highlightInfo.originIconScaleLevel
			end
		end

		self._curInviteRideAcceptInfo = nil
	end

	if not oldEnable ~= not enable then
		gMessageManager:SendMessage(gEventConstants.INVITE_RIDING_STATE_CHANGE)
	end
end

function M:TryAcceptInviteRideTask(element)
	if not element.userdata or not element.userdata.cfgId then
		return
	end

	local cfgId = element.userdata.cfgId

	if not self._inviteRidePointInfos[cfgId] then
		return
	end

	local highlightInfo = self._inviteRidePointInfos[cfgId]

	if self._curInviteRideAcceptInfo and self._curInviteRideAcceptInfo.taskId ~= highlightInfo.taskId then
		gMapUtils:DoGiveUpTask(self._curInviteRideAcceptInfo.taskId, function ()
			print_debug("InviteRide:Give up invite ride task:" .. self._curInviteRideAcceptInfo.taskId .. " success")

			self._curInviteRideAcceptInfo = nil

			gMapUtils:DoAcceptTask(highlightInfo.taskId, function ()
				self._curInviteRideAcceptInfo = highlightInfo

				print_debug("InviteRide:Accept invite ride task:" .. highlightInfo.taskId .. " success")
			end, self._inviteRideAcceptFailCb)
		end, self._inviteRideGiveUpFailCb)
	else
		gMapUtils:DoAcceptTask(highlightInfo.taskId, function ()
			self._curInviteRideAcceptInfo = highlightInfo

			print_debug("InviteRide:Accept invite ride task:" .. highlightInfo.taskId .. " success")
		end, self._inviteRideAcceptFailCb)
	end
end

function M:TryGiveUpInviteRideTask(element)
	if not element.userdata or not element.userdata.cfgId then
		return
	end

	local cfgId = element.userdata.cfgId

	if not self._inviteRidePointInfos[cfgId] then
		return
	end

	local highlightInfo = self._inviteRidePointInfos[cfgId]

	if self._curInviteRideAcceptInfo.taskId == highlightInfo.taskId then
		gMapUtils:DoGiveUpTask(highlightInfo.taskId, function ()
			self._curInviteRideAcceptInfo = nil

			print_debug("InviteRide:Give up invite ride task:" .. highlightInfo.taskId .. " success")
		end, self._inviteRideGiveUpFailCb)
	end
end

function M:SetUpInviteRideFailCb()
	function self._inviteRideGiveUpFailCb(err, taskId)
		print_error("InviteRide:Give up invite ride task:" .. taskId .. " fail for reason:" .. gCS.Error.GetNameById(err))
	end

	function self._inviteRideAcceptFailCb(err, taskId)
		print_error("InviteRide:Accept invite ride task:" .. taskId .. " fail for reason:" .. gCS.Error.GetNameById(err))
	end
end

function M:Plan3RaidIdToCountryId(raidId)
	if not self._raidType2IdToCountryId[raidId] then
		print_error("未找到方案3 raidId映射的countryId raidId:" .. raidId .. " 请检查是否有在IndoorConfig中配置该室内")

		return LTConfig.CollectionCountryConfig.XinQi
	end

	return self._raidType2IdToCountryId[raidId]
end

return M
