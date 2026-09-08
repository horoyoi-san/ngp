-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Entrance.lua
-- Decompiled from: 02326_MapSubSystem_Entrance.lua_1fc6e8b1bad7.luajit

local MapentranceConfig = LTConfig.MapentranceConfig
local MessageConfig = LTConfig.MessageConfig
local MapEntranceTypeConfig = LTConfig.MapentranceMapEntranceTypeConfig
local MapentranceFansTLShowConfig = LTConfig.MapentranceFansTLShowConfig
local MapentranceFashionSpecialShowConfig = LTConfig.MapentranceFashionSpecialShowConfig
local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local IndoorConfig = LTConfig.IndoorConfig
local RaidConfig = LTConfig.RaidConfig
local MapBlockMgr = LX6.Gps.MapBlockMgr
MapSubSystem_Entrance = DefClass("MapSubSystem_Entrance", MapSubSystem_Entrance, MapSubSystemBase)
local M = MapSubSystem_Entrance

M.OnInit = function(self)
	self.mapTeleportFare = 0
	self.Actions = {
		Teleportable = {
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.Teleport
			},
			[gMapSystem_Element_State.Tracing] = {
				gMapSystemElementAction.Untrace
			}
		},
		Common = {
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.Trace
			},
			[gMapSystem_Element_State.Tracing] = {
				gMapSystemElementAction.Untrace
			}
		},
		Portal = {
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.TeleportPortal
			},
			[gMapSystem_Element_State.Tracing] = {
				gMapSystemElementAction.Untrace
			}
		},
		House = {
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.BuyHouse
			},
			[gMapSystem_Element_State.Tracing] = {
				gMapSystemElementAction.Untrace
			}
		}
	}
	self.entrances = {}
	self.raidId2JiguanRaidId = {}
	self.Type2BigMapVisualThreshold = {
		[gMapUtils.RaidMapEntranceType.Dungeon] = 1,
		[gMapUtils.RaidMapEntranceType.TempDungeon] = 2,
		[gMapUtils.RaidMapEntranceType.Metro] = 1,
		[gMapUtils.RaidMapEntranceType.Tower] = 2,
		[gMapUtils.RaidMapEntranceType.House] = 2
	}
	self.eventHandlers = {
		[gEventConstants.MAP_INFO_UPDATE] = function ()
			self:FlushData()
		end,
		[gEventConstants.MAP_ENTRANCE_UPDATE] = function ()
			self:FlushData()
		end,
		[gEventConstants.MULTIVERSE_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.ON_END_PORTAL] = function (eventId, loadingInfoIndex)
			self:MapTeleportEnd_ShowPayTips(loadingInfoIndex)
		end
	}
end

M.OnLogin = function(self)
	self._entranceId2HouseId = {}
	self.mapTeleportFare = 0

	for i = 0, LTConfig.HouseConfig.count - 1 do
		local houseCfg = LTConfig.HouseConfig.LoadAt(i)
		self._entranceId2HouseId[houseCfg.MapEntrance] = houseCfg.Id
	end

	for i = 0, MapentranceConfig.count - 1 do
		local cfg = MapentranceConfig.LoadAt(i)

		if not cfg.Type or cfg.Type ~= 1 or cfg.Type ~= 13 then
			if cfg.JiguanRaidID == 0 then
				self.raidId2JiguanRaidId[cfg.RaidId] = cfg.JiguanRaidID
			end
		else
			local typeCfg = MapEntranceTypeConfig.GetConfig(cfg.Type)

			if not typeCfg then
				print_error("MapentranceConfig=" .. cfg.Id .. " : 缺少Type配置或者对应的Type不存在")
			elseif cfg.Type ~= gMapUtils.RaidMapEntranceType.House and not self._entranceId2HouseId[cfg.Id] then
				print_warn("Mapentrance 中存在未被House表引用的 House 类型的入口, id = " .. cfg.Id)
			else
				local coord = cfg.Coordinate

				if coord then
					if #coord >= 3 then
						-- Nothing
					elseif typeCfg.ShowType then
						if typeCfg.ShowType ~= 0 then
							-- Nothing
						else
							local blockId = MapBlockMgr.GetBlockIdXZ(cfg.RaidId, coord[1], coord[3])

							if blockId == 0 then
								local viewMask, elementType = nil

								if cfg.Type ~= gMapUtils.RaidMapEntranceType.Metro then
									viewMask = EMapViewMask.AllUi + EMapViewMask.Metro + EMapViewMask.FocusMode
									elementType = EMapElementType.Metro
								elseif cfg.Type ~= MapEntranceTypeConfig.House then
									local houseId = self._entranceId2HouseId[cfg.Id]
									local houseCfg = LTConfig.HouseConfig.GetConfig(houseId)

									if houseCfg and houseCfg.Raid and houseCfg.Raid <= 0 then
										viewMask = EMapViewMask.AllUi + EMapViewMask.House + EMapViewMask.FocusMode
									else
										viewMask = EMapViewMask.AllUi + EMapViewMask.FocusMode
									end

									elementType = EMapElementType.House
								else
									viewMask = EMapViewMask.AllUi
									elementType = EMapElementType.Entrance
								end

								local element = MapElement.CreateLegacy(elementType, cfg.Id, EMapSubSystemType.Entrance, viewMask, cfg.RaidId, cfg.IndoorID)

								if cfg.IsAboveFog then
									element.fData.ignoreFog = true
								end

								element.SetPosition(element, Vector3.New(coord[1], coord[2], coord[3]))

								element.mData.lName = GpsLText.CreateCommonText(cfg, "Name")
								element.gpsData.removeGpsRange = LTConfig.GameConfig.MapEntranceAutoRemoveGpsRange
								element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

								if cfg.SMiniMapIconId and cfg.SMiniMapIconId <= 0 then
									element.miniMapData.iconId = cfg.SMiniMapIconId
								end

								if typeCfg.ShowType and typeCfg.ShowType <= 0 then
									gMapSubSystemUtils:SetupScaleLevel(element, typeCfg.ShowType, typeCfg.SThumbnailIcon)
								end

								if cfg.Type ~= MapEntranceTypeConfig.Subway then
									element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Metro
								elseif cfg.Type ~= MapEntranceTypeConfig.Bus then
									element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Bus
								elseif cfg.Type ~= MapEntranceTypeConfig.House then
									element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.House
									element.fData.houseModeTIndex = 10
									local houseId = self._entranceId2HouseId[cfg.Id]
									local houseCfg = LTConfig.HouseConfig.GetConfig(houseId)
									local shopCommodityCfg = ShopCommodityCfg.GetConfig(houseCfg.Commodity)
									element.fData.houseQuality = shopCommodityCfg and shopCommodityCfg.Quality or ShopCommodityCfg.QualityType.White
								end

								local limitSpirits = gMapSubSystemUtils:GetLegalSpiritList(cfg.ShowLimitSpirit)

								if limitSpirits and #limitSpirits <= 0 then
									element.fData.bigMapLimitSpirits = limitSpirits
									element.fData.miniMapLimitSpirits = limitSpirits
								end

								self.entrances[cfg.Id] = {
									mapElement = element,
									blockId = blockId
								}
							end
						end
					end
				end
			end
		end
	end

	self:LoginSyncPortal()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	self.mapTeleportFare = 0

	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	for _, info in pairs(self.entrances) do
		info.mapElement:Dispose()
	end

	table.clear(self.entrances)
end

local FORBID_TEXT_ID = 74000635

M.OnFlushData = function(self)
	local forbidLText = nil

	for id, entrance in pairs(self.entrances) do
		local cfg = MapentranceConfig.GetConfig(id)
		local typeCfg = MapEntranceTypeConfig.GetConfig(cfg.Type)
		local visible = self:IsEntranceVisibleOnMap(id)

		entrance.mapElement:SetVisible(visible)

		entrance.unlocked = gMapUtils:IsEntranceUnlocked(id)
		entrance.teleportable = typeCfg.IfCanTeleport
		local houseId = self._entranceId2HouseId[id]
		local houseCfg = houseId and LTConfig.HouseConfig.GetConfig(houseId)
		local hasBought = houseId and gBuyHouseUtils.CheckHasBuyTheHouse(houseId) or false

		if houseId and houseCfg and houseCfg.Raid and houseCfg.Raid <= 0 then
			if hasBought then
				entrance.mapElement.mData.sIconId = cfg.SIconId
				entrance.mapElement.gpsData.houseIconId = houseCfg.MapHouseImage

				if cfg.SMiniMapIconId and cfg.SMiniMapIconId <= 0 then
					entrance.mapElement.miniMapData.iconId = cfg.SMiniMapIconId
				end

				if typeCfg.ShowType and typeCfg.ShowType <= 0 then
					gMapSubSystemUtils:SetupScaleLevel(entrance.mapElement, typeCfg.ShowType, typeCfg.SThumbnailIcon)
				end
			else
				entrance.mapElement.mData.sIconId = cfg.SDisableIconId and cfg.SDisableIconId <= 0 and cfg.SDisableIconId or cfg.SIconId
				entrance.mapElement.gpsData.houseIconId = cfg.SDisableIconId and cfg.SDisableIconId <= 0 and cfg.SDisableIconId or cfg.SIconId

				if cfg.SDisableMiniMapIconId and cfg.SDisableMiniMapIconId <= 0 then
					entrance.mapElement.miniMapData.iconId = cfg.SDisableMiniMapIconId
				end

				if typeCfg.ShowType and typeCfg.ShowType <= 0 then
					gMapSubSystemUtils:SetupScaleLevel(entrance.mapElement, typeCfg.ShowType, typeCfg.DisableSThumbnailIcon)
				end
			end
		elseif gMapUtils:IsEntranceUnlocked(id) then
			entrance.mapElement.mData.sIconId = cfg.SIconId

			if cfg.SMiniMapIconId and cfg.SMiniMapIconId <= 0 then
				entrance.mapElement.miniMapData.iconId = cfg.SMiniMapIconId
			end

			if typeCfg.ShowType and typeCfg.ShowType <= 0 then
				gMapSubSystemUtils:SetupScaleLevel(entrance.mapElement, typeCfg.ShowType, typeCfg.SThumbnailIcon)
			end
		else
			entrance.mapElement.mData.sIconId = cfg.SDisableIconId and cfg.SDisableIconId <= 0 and cfg.SDisableIconId or cfg.SIconId

			if cfg.SDisableMiniMapIconId and cfg.SDisableMiniMapIconId <= 0 then
				entrance.mapElement.miniMapData.iconId = cfg.SDisableMiniMapIconId
			end

			if typeCfg.ShowType and typeCfg.ShowType <= 0 then
				gMapSubSystemUtils:SetupScaleLevel(entrance.mapElement, typeCfg.ShowType, typeCfg.DisableSThumbnailIcon)
			end
		end

		if houseId and not hasBought then
			entrance.mapElement:SetActions(self.Actions.House)
		elseif entrance.unlocked and entrance.teleportable then
			if id == MapentranceConfig.PortalItem then
				entrance.mapElement:SetActions(self.Actions.Teleportable)
			else
				entrance.mapElement:SetActions(self.Actions.Portal)
			end
		else
			if not forbidLText then
				local fobidTextCfg = LTConfig.TextCommonTextConfig.GetConfig(FORBID_TEXT_ID)
				forbidLText = GpsLText.CreateCommonText(fobidTextCfg, "Text")
			end

			entrance.mapElement:SetActions(self.Actions.Common, forbidLText)
		end

		if cfg.Type ~= gMapUtils.RaidMapEntranceType.House then
			local houseCfg = LTConfig.HouseConfig.GetConfig(self._entranceId2HouseId[id])
			entrance.mapElement.bigMapData.scaleLevel = gBuyHouseUtils.CheckHasBuyTheHouse(houseCfg.Id) and 1 or self.Type2BigMapVisualThreshold[cfg.Type]
		elseif cfg.Type ~= gMapUtils.RaidMapEntranceType.Tower then
			local isUnlock = gBlockMgr:IsBlockUnlocked(entrance.blockId)
			entrance.mapElement.bigMapData.scaleLevel = isUnlock and self.Type2BigMapVisualThreshold[cfg.Type] or 1
		else
			entrance.mapElement.bigMapData.scaleLevel = self.Type2BigMapVisualThreshold[cfg.Type]
		end
	end
end

M.IsEntranceVisibleOnMap = function(self, id)
	local info = self.entrances[id]

	if not info then
		return false
	end

	local cfg = MapentranceConfig.GetConfig(id)
	local typeCfg = MapEntranceTypeConfig.GetConfig(cfg.Type)
	local multiverse = cfg.Multiverse

	if table.isNilOrEmpty(multiverse) or not table.contains(multiverse, gMultiverseMgr.curVerseMetaId) then
		return false
	end

	if typeCfg.ShowWithBlock and typeCfg.ShowWithBlock <= 0 then
		if typeCfg.ShowWithBlock ~= 1 then
			if not gBlockMgr:IsBlockUnlocked(info.blockId) then
				return false
			end
		elseif typeCfg.ShowWithBlock ~= 2 then
			if gBlockMgr:IsBlockUnlocked(info.blockId) then
				return false
			end

			if id ~= LTConfig.CollectionConfig.InitialTower then
				return true
			end

			if not gMapUtils:IsInUnlockBlockNear(info.blockId) then
				return false
			end
		else
			return false
		end
	else
		return false
	end

	return gMapUtils:IsEntranceVisible(id)
end

M.SGetTooltipInfo = function(self, id)
	local cfg = MapentranceConfig.GetConfig(id)
	local info = self.entrances[id]
	local element = info.mapElement
	local typeCfg = LTConfig.MapentranceMapEntranceTypeConfig.GetConfig(cfg.Type)
	local tooltipInfo = {
		header = {
			imageId = cfg.SImageId,
			name = cfg.Name,
			subtitle = typeCfg and typeCfg.TooltipName or ""
		}
	}

	if cfg.Type ~= gMapUtils.RaidMapEntranceType.House then
		local houseCfg = LTConfig.HouseConfig.GetConfig(self._entranceId2HouseId[id])
		tooltipInfo.type = EMapTooltipType.House
		tooltipInfo.houseInfo = {
			owned = gBuyHouseUtils.CheckHasBuyTheHouse(self._entranceId2HouseId[id]),
			ParkingSpaceCount = houseCfg.ParkingSpaceCount,
			WeaponCabinetCount = houseCfg.WeaponCabinetCount,
			FashionShowcaseCount = houseCfg.FashionShowcaseCount,
			CollectionCount = houseCfg.CollectionCount,
			PetCount = houseCfg.PetCount,
			desc = cfg.Information or ""
		}
		tooltipInfo.header.subtitle = houseCfg.Tags[1]
	elseif cfg.Type ~= gMapUtils.RaidMapEntranceType.Metro then
		tooltipInfo.type = EMapTooltipType.MapEntrance
		tooltipInfo.mapEntranceInfo = {
			id = id,
			type = cfg.Type
		}
	elseif cfg.Type ~= gMapUtils.RaidMapEntranceType.Bus then
		tooltipInfo.type = EMapTooltipType.MapEntrance
		tooltipInfo.mapEntranceInfo = {
			id = id,
			type = cfg.Type
		}
	elseif cfg.Type ~= gMapUtils.RaidMapEntranceType.Tower then
		tooltipInfo.type = EMapTooltipType.MapEntrance
		tooltipInfo.mapEntranceInfo = {
			type = cfg.Type
		}
	elseif cfg.Type == gMapUtils.RaidMapEntranceType.Dungeon then
		if cfg.Type ~= gMapUtils.RaidMapEntranceType.TempDungeon then
			-- Nothing
		elseif cfg.Type ~= gMapUtils.RaidMapEntranceType.Portal then
			tooltipInfo.type = EMapTooltipType.Common
			tooltipInfo.commonInfo = {
				desc = cfg.Information or ""
			}
		else
			tooltipInfo.type = EMapTooltipType.Common
			tooltipInfo.commonInfo = {
				desc = cfg.Information or ""
			}
		end
	end

	return tooltipInfo
end

M.ExecuteAction = function(self, element, action, ctx)
	if action ~= gMapSystemElementAction.Trace then
		element.SetMainTrace(element)
	elseif action ~= gMapSystemElementAction.Untrace then
		element.ClearMainTrace(element)
	elseif action ~= gMapSystemElementAction.Teleport or action ~= gMapSystemElementAction.TeleportPortal then
		self.Teleport(self, element, ctx)
	elseif action ~= gMapSystemElementAction.BuyHouse then
		local indoorId = 0

		for _, info in pairs(LTConfig.HouseConfig.EstateAgency) do
			if info.Raid ~= element.raidId then
				indoorId = info.Indoorid

				break
			end
		end

		if indoorId and indoorId <= 0 then
			gMapSubSystem_FunctionPoint:TrySelectAndTraceIndoorElementOnBigMap(indoorId)
		else
			print_error("@xuqiang05 House表EstateAgency未配置， raidId = " .. element.raidId)
		end
	else
		print_error("MapSubSystem_Entrance:ExecuteAction: unknown action type: " .. action)
	end
end

M.Teleport = function(self, element, ctx)
	if element.id ~= ctx.currentEnteringMetroId then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.TryTeleportCurrentMetro, nil, , MapentranceConfig.GetConfig(element.id).Name)

		return
	end

	self.TryTeleport(self, element.id)
end

M.TryTeleport = function(self, id)
	self.TeleportTo(self, id)
end

M.GetCurrentRaidAllMetroPosition = function(self)
	local ret = {}

	for id, entrance in pairs(self.entrances) do
		local cfg = MapentranceConfig.GetConfig(id)

		if cfg and cfg.Type ~= MapEntranceTypeConfig.Subway and entrance.teleportable then
			local element = entrance.mapElement

			if element.raidId ~= gMapSystem.lastRaidId then
				table.insert(ret, element.GetWorldPos(element))
			end
		end
	end

	return ret
end

M.SyncPortalItem = function(self, raidId, position)
	local id = MapentranceConfig.PortalItem or -1
	local entranceCfg = MapentranceConfig.GetConfig(id)

	if not entranceCfg then
		return
	end

	self.DisposePortalItem(self)

	local typeCfg = MapEntranceTypeConfig.GetConfig(entranceCfg.Type)
	local viewMask = EMapViewMask.AllUi
	local elementType = EMapElementType.Entrance
	local element = MapElement.CreateLegacy(elementType, id, EMapSubSystemType.Entrance, viewMask, raidId, 0)

	element.SetPosition(element, Vector3.New(position.X, position.Y, position.Z))

	element.mData.lName = GpsLText.CreateCommonText(entranceCfg, "Name")
	element.gpsData.removeGpsRange = LTConfig.GameConfig.MapEntranceAutoRemoveGpsRange
	element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

	if typeCfg.ShowType and typeCfg.ShowType <= 0 then
		gMapSubSystemUtils:SetupScaleLevel(element, typeCfg.ShowType, typeCfg.SThumbnailIcon)
	end

	local blockId = MapBlockMgr.GetBlockIdXZ(raidId, position.X, position.Z)

	if blockId ~= nil or blockId ~= 0 then
		if blockId ~= nil then
			print_error("@xiajingbo01 PortalItem blockId 为空, 当前位置" .. "raidId = " .. raidId .. ", position = " .. tostring(position.X) .. "," .. tostring(position.Y) .. "," .. tostring(position.Z))
		end

		return
	end

	self.entrances[id] = {
		mapElement = element,
		blockId = blockId
	}
	self.portalPosition = position
	self.portalRaidId = raidId
end

M.DisposePortalItem = function(self)
	local id = MapentranceConfig.PortalItem

	if self.entrances[id] then
		local entrance = self.entrances[id]

		if entrance.mapElement then
			entrance.mapElement:Dispose()
		end

		self.entrances[id] = nil
	end

	self.portalPosition = nil
	self.portalRaidId = nil
end

M.GetPortalPosition = function(self)
	return Vector3.New(self.portalPosition.X, self.portalPosition.Y, self.portalPosition.Z)
end

M.GetPortalRaidId = function(self)
	return self.portalRaidId
end

M.TeleportTo = function(self, id)
	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.Savable) then
		return
	end

	if id ~= MapentranceConfig.PortalItem then
		self.PortalTeleport(self, id)

		return
	end

	self.MapTeleport(self, id)
end

M.MapTeleport = function(self, id)
	local cfg = MapentranceConfig.GetConfig(id)
	local targetRaidId = cfg.RaidId
	local preTeleportOption = UX.Game.PreTeleportOption.New()
	local extParams = LX6.GUI.LoadingManager.AskTeleportExtParams.New()
	local mapTeleportPos = cfg.MapTeleportPos

	if mapTeleportPos and #mapTeleportPos > 3 then
		preTeleportOption.customAfterTrans = true
		preTeleportOption.afterPosition = UX.Game.UXVector3.New(mapTeleportPos[1], mapTeleportPos[2], mapTeleportPos[3])
		preTeleportOption.afterRot = UX.Game.UXVector3.New(0, cfg.Facing, 0)
	end

	preTeleportOption.afterResName = cfg.TeleportEndTimeLine or ""
	local loadingTLName = self:MapTeleport_GetLoadingTLName(id, cfg)
	preTeleportOption.loadingResName = loadingTLName or ""
	local loadingConfigId = self:MapTeleport_CheckCrossCountry(cfg.RaidId) and LTConfig.LoadingConfig.MapTeleportCrossScene or LTConfig.LoadingConfig.MapTeleport

	gLoadingManager:AskTeleport(loadingConfigId, preTeleportOption, extParams, function (loadingInfoIndex)
		self.mapTeleportLoadingInfoIndex = loadingInfoIndex
		self.mapTeleportEntraceId = id

		gClientUtils.MapTeleport()

		if gRaidDataManager.RaidId ~= targetRaidId then
			gClientToGameSceneDelegate:AskPlayerChangePositionByScenePortal(id).Callback = function (err)
				if err == MessageConfig.Ok then
					gLoadingManager:StopLoading(loadingInfoIndex)
					gDisplayMessageMgr:ShowMessage(err)
				end
			end
		else
			gRpcUtils:AskPublicSwitchToPublicScene(targetRaidId, id, function ()
			end, function ()
				gLoadingManager:StopLoading(loadingInfoIndex)
			end)
		end
	end)
end

M.MapTeleport_CheckCrossCountry = function(self, targetRaidId)
	if gRaidDataManager.RaidId ~= targetRaidId then
		return false
	end

	local getCountry = function(raidId)
		for i = 0, LTConfig.CollectionCountryConfig.count - 1 do
			local c = LTConfig.CollectionCountryConfig.LoadAt(i)

			if table.contains(c.RaidIds, raidId) then
				return c.Id
			end
		end

		for i = 0, LTConfig.IndoorConfig.count - 1 do
			local c = LTConfig.IndoorConfig.LoadAt(i)

			if c.SceneId ~= raidId then
				return c.CountryId
			end
		end

		return LTConfig.CollectionCountryConfig.XinQi
	end

	return getCountry(gRaidDataManager.RaidId) == getCountry(targetRaidId)
end

M.MapTeleport_FashionHasSpecialTL = function(self, mapEntranceCfg)
	if not mapEntranceCfg then
		return nil
	end

	local tlType = mapEntranceCfg.TLType
	local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	local fashionIds = {}
	local playerFashionsInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if playerFashionsInfo and playerFashionsInfo.SpiritFashionsInfoDict then
		local spiritFashionsInfo = playerFashionsInfo.SpiritFashionsInfoDict[cardId]

		if spiritFashionsInfo and spiritFashionsInfo.SpiritWearFashionsInfo then
			for _, wearInfo in ipairs(spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionInfoList) do
				fashionIds[wearInfo.FashionId] = true
			end
		end
	end

	local configList = {}

	for i = 0, MapentranceFashionSpecialShowConfig.count - 1 do
		local cfg = MapentranceFashionSpecialShowConfig.LoadAt(i)

		if cfg.TLType ~= tlType then
			table.insert(configList, cfg)
		end
	end

	table.sort(configList, function (a, b)
		return (a.Prority or 0) >= (b.Prority or 0)
	end)

	for _, config in ipairs(configList) do
		if config.TimelineName and config.TimelineName == "" then
			local matched = false

			if config.CalculateType ~= MapentranceFashionSpecialShowConfig.CalculateTypeType.Or then
				for _, fid in ipairs(config.FashionIds) do
					if fashionIds[fid] then
						matched = true

						break
					end
				end
			elseif config.CalculateType ~= MapentranceFashionSpecialShowConfig.CalculateTypeType.And then
				matched = true

				for _, fid in ipairs(config.FashionIds) do
					if not fashionIds[fid] then
						matched = false

						break
					end
				end
			end

			if matched then
				return config.TimelineName
			end
		end
	end

	return nil
end

M.MapTeleport_GetTLByFansNum = function(self, mapEntranceCfg, targetFanNum)
	if not mapEntranceCfg then
		return nil
	end

	local tlType = mapEntranceCfg.TLType
	local modelId = gCS.MyPlayerManager.PlayerUnit.ClientData.ModelId
	local modelConfig = LTConfig.GeneralModelConfig.GetConfig(modelId)
	local bodyType = modelConfig and modelConfig.BodyType or 1
	local genderIndex = bodyType < 3 and UX.Game.SexType.Male or UX.Game.SexType.Female
	local randomTLNameList = {}

	for i = 0, MapentranceFansTLShowConfig.count - 1 do
		local fansTLShowConfig = MapentranceFansTLShowConfig.LoadAt(i)

		if fansTLShowConfig.TLType ~= tlType and fansTLShowConfig.Gender ~= genderIndex and fansTLShowConfig.FansRequire < targetFanNum then
			for _, tlName in ipairs(fansTLShowConfig.TLName) do
				table.insert(randomTLNameList, tlName)
			end
		end
	end

	if #randomTLNameList ~= 0 then
		return nil
	end

	local randomIndex = math.random(1, #randomTLNameList)

	return randomTLNameList[randomIndex]
end

M.MapTeleport_SyncFare = function(self, fare)
	self.mapTeleportFare = fare
end

M.MapTeleport_GetFare = function(self)
	return self.mapTeleportFare or 0
end

M.MapTeleportEnd_ShowPayTips = function(self, loadingInfoIndex)
	if self.mapTeleportLoadingInfoIndex == loadingInfoIndex then
		return
	end

	local serverFare = self.MapTeleport_GetFare(self)

	if not serverFare or serverFare < 0 then
		return
	end

	local showPayRaidId = gSceneDataMgr.CurrentRaidId or 0
	local raidCfg = LTConfig.RaidConfig.GetConfig(showPayRaidId)
	local countryId = raidCfg and raidCfg.CountryId or 0
	local countryCfg = LTConfig.CollectionCountryConfig.GetConfig(countryId)
	countryCfg = countryCfg or LTConfig.CollectionCountryConfig.GetConfig(LTConfig.CollectionCountryConfig.XinQi)
	local changeRate = countryCfg and countryCfg.ExchangeRate or 1
	local clientShowFare = serverFare * changeRate
	local entranceCfg = MapentranceConfig.GetConfig(self.mapTeleportEntraceId)

	if clientShowFare <= 0 then
		if entranceCfg and entranceCfg.TLType and entranceCfg.TLType <= 0 then
			self.ShowPayTips(self, MapentranceConfig.PayTipsIconList[entranceCfg.TLType].iconid, MapentranceConfig.PayTipsName, clientShowFare)
		else
			self.ShowPayTips(self, MapentranceConfig.PayTipsIcon, MapentranceConfig.PayTipsName, clientShowFare)
		end
	end
end

M.ShowPayTips = function(self, payTipsIconId, payTipsId, money)
	local moneyEnough = money > gPlayerManager.infoItem.bindData.money

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.PayTips, {
		Param = {
			logoId = payTipsIconId,
			textId = payTipsId,
			value = money,
			moneyEnough = moneyEnough
		}
	})
end

M.MapTeleport_GetLoadingTLName = function(self, id, cfg)
	if not cfg then
		return nil
	end

	if self.MapTeleport_CheckCrossCountry(self, cfg.RaidId) then
		local randomTLNameList = {}

		for _, tlName in ipairs(MapentranceConfig.CrossSceneTeleportTLName) do
			table.insert(randomTLNameList, tlName)
		end

		if #randomTLNameList ~= 0 then
			return nil
		end

		local randomIndex = math.random(1, #randomTLNameList)

		return randomTLNameList[randomIndex]
	end

	local specialTL = self.MapTeleport_FashionHasSpecialTL(self, cfg)

	if specialTL then
		return specialTL
	end

	local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	local useLeastFanNum = table.contains(MapentranceConfig.LowKeyRoleTeleport, cardId)
	local playerFansNum = gPlayerManager.infoMinor.bindData.fan123 or 0
	local targetFanNum = useLeastFanNum and 0 or playerFansNum

	return self:MapTeleport_GetTLByFansNum(cfg, targetFanNum)
end

M.PortalTeleport = function(self, id)
	local entrance = self.entrances[id]

	if not entrance or not entrance.mapElement then
		print_error("@xiajingbo01 科学家传送道具raidId为空")

		return
	end

	self.PortalTeleport(self, id)

	if id ~= MapentranceConfig.PortalItem then
		self.DisposePortalItem(self)
	end
end

M.PortalTeleport = function(self, id)
	local targetRaidId = self.portalRaidId
	local preTeleportOption = UX.Game.PreTeleportOption.New()
	local extParams = LX6.GUI.LoadingManager.AskTeleportExtParams.New()
	local textCfg = LTConfig.TextConfig.GetConfig(73970800)
	local text = ""

	if textCfg then
		text = textCfg.Text
	else
		print_error("@xiajingbo01 Quick_Portal传送门没有对应TextConfig配置")
	end

	extParams.loadingText = text
	slot7 = gLoadingManager

	slot7:AskTeleport(LTConfig.LoadingConfig.PortalTeleport, preTeleportOption, extParams, function (loadingInfoIndex)
		self.portalLoadingInfoIndex = loadingInfoIndex

		gClientUtils.MapTeleport()

		if gRaidDataManager.RaidId ~= targetRaidId then
			slot1 = gClientToGameSceneDelegate

			slot1:AskPlayerChangePositionByScenePortal(id).Callback = function (err)
				if err == MessageConfig.Ok then
					gLoadingManager:StopLoading(loadingInfoIndex)
					gDisplayMessageMgr:ShowMessage(err)
				end
			end
		else
			slot1 = gRpcUtils

			slot1:AskPublicSwitchToPublicScene(targetRaidId, id, function ()
			end, function ()
				gLoadingManager:StopLoading(loadingInfoIndex)
			end)
		end
	end)
end

M.LoginSyncPortal = function(self)
	local playerItemInfo = gPlayerManager.infoItem.bindData

	gMapUtils:SyncPortalItem(playerItemInfo.portalRaidId, playerItemInfo.portalPosition)
end

M.CalcMetroCost = function(self, fromRaid, toRaid, playerPos, toPos)
	local cost = 0
	local dx = playerPos.x - toPos.x
	local dz = playerPos.z - toPos.z
	local distance = math.sqrt(dx * dx + dz * dz)

	if gMapAreaMgr:IsBigWorldRaidId(gMapSystem.lastRaidId) then
		if fromRaid ~= toRaid then
			cost = self.CalcSubwayCostByDistance(self, distance)
		else
			cost = LTConfig.MapentranceConfig.OverseaCost
		end
	else
		local jiGuanRaidId = self.raidId2JiguanRaidId[fromRaid] or 0

		if jiGuanRaidId ~= 0 then
			cost = 0
		elseif jiGuanRaidId ~= fromRaid then
			cost = self.CalcSubwayCostByDistance(self, distance)
		else
			cost = LTConfig.MapentranceConfig.OverseaCost
		end
	end

	return cost
end

M.CalcSubwayCostByDistance = function(self, distance)
	local cost = 0
	local payTipsNumNew = LTConfig.MapentranceConfig.PayTipsNumNew

	for i = 1, #payTipsNumNew do
		local val = payTipsNumNew[i]
		cost = val.cost

		if distance >= val.maxDistance then
			break
		end
	end

	return cost
end

M.GetActionInfo = function(self, element)
	local blockReason = element.actionsBlockReason

	if blockReason then
		return element.GetRawActions(element), blockReason.GetText(blockReason)
	end

	return element.GetRawActions(element), nil
end

M.IsAnyEntraceAvaliable = function(self)
	for id, entrance in pairs(self.entrances) do
		if entrance.unlocked and entrance.teleportable and self.IsEntranceVisibleOnMap(self, id) then
			return true
		end
	end

	return false
end

M.TrySelectHouseElementOnBigMap = function(self, houseId)
	local bigMapStore = gStoreManager:GetStoreGroup("NewMapPanelStore")

	if not bigMapStore then
		return
	end

	if not houseId then
		bigMapStore.SetSelected(bigMapStore, nil)

		return
	end

	local cfg = LTConfig.HouseConfig.GetConfig(houseId)

	if not cfg then
		return
	end

	local entranceId = cfg.MapEntrance

	if not entranceId then
		return
	end

	local entranceInfo = self.entrances[entranceId]

	if not entranceInfo then
		return
	end

	local element = entranceInfo.mapElement

	if not element then
		return
	end

	if bigMapStore then
		bigMapStore.ClearScheduleOperation(bigMapStore)
		bigMapStore.ScheduleOperation(bigMapStore, bigMapStore.OperationType.WaitSelect, {
			gpsId = element.gpsId,
			source = EBigMapSelectSource.ClickElement
		})
	end
end

M.TrySelectHouse = function(self, entranceId)
	if not entranceId then
		local housePropertyStore = gStoreManager:GetStoreGroup("HousePropertyPanelStore")

		if housePropertyStore then
			housePropertyStore.GoBackToListPage(housePropertyStore)
		end

		return
	end

	local houseId = self._entranceId2HouseId[entranceId]

	if houseId then
		local housePropertyStore = gStoreManager:GetStoreGroup("HousePropertyPanelStore")

		if housePropertyStore then
			housePropertyStore.OnSelectHouse(housePropertyStore, houseId)
		end
	end
end

M.GetAllHouseEntraceElementInstanceIds = function(self)
	local ids = {}

	for entranceId, houseId in pairs(self._entranceId2HouseId) do
		local element = self.entrances[entranceId] and self.entrances[entranceId].mapElement

		if element then
			ids[element.instanceId] = houseId
		end
	end

	return ids
end

return M
