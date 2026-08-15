local MapentranceConfig = LTConfig.MapentranceConfig
local MessageConfig = LTConfig.MessageConfig
local MapEntranceTypeConfig = LTConfig.MapentranceMapEntranceTypeConfig
local actionHelper = require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")
local MapBlockMgr = LX6.Gps.MapBlockMgr
MapSubSystem_Entrance = DefClass("MapSubSystem_Entrance", MapSubSystem_Entrance, MapSubSystemBase)
local M = MapSubSystem_Entrance

function M:OnInit()
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
		end
	}
end

function M:OnLogin()
	self._entranceId2HouseId = {}

	for i = 0, LTConfig.HouseConfig.count - 1 do
		local houseCfg = LTConfig.HouseConfig.LoadAt(i)
		self._entranceId2HouseId[houseCfg.MapEntrance] = houseCfg.Id
	end

	for i = 0, MapentranceConfig.count - 1 do
		local cfg = MapentranceConfig.LoadAt(i)

		if not cfg.Type or cfg.Type == 1 or cfg.Type == 13 then
			if cfg.JiguanRaidID ~= 0 then
				self.raidId2JiguanRaidId[cfg.RaidId] = cfg.JiguanRaidID
			end
		else
			local typeCfg = MapEntranceTypeConfig.GetConfig(cfg.Type)

			if not typeCfg then
				print_error("MapentranceConfig=" .. cfg.Id .. " : 缺少Type配置或者对应的Type不存在")
			elseif cfg.Type == gMapUtils.RaidMapEntranceType.House and not self._entranceId2HouseId[cfg.Id] then
				print_warn("Mapentrance 中存在未被House表引用的 House 类型的入口, id = " .. cfg.Id)
			else
				local coord = cfg.Coordinate

				if coord then
					if #coord < 3 then
						-- Nothing
					elseif typeCfg.ShowType then
						if typeCfg.ShowType == 0 then
							-- Nothing
						else
							local blockId = MapBlockMgr.GetBlockIdXZ(cfg.RaidId, coord[1], coord[3])

							if blockId ~= 0 then
								local viewMask, elementType = nil

								if cfg.Type == gMapUtils.RaidMapEntranceType.Metro then
									viewMask = EMapViewMask.AllUi + EMapViewMask.Metro + EMapViewMask.FocusMode
									elementType = EMapElementType.Metro
								else
									viewMask = EMapViewMask.AllUi
									elementType = EMapElementType.Entrance
								end

								local element = MapElement.CreateLegacy(elementType, cfg.Id, EMapSubSystemType.Entrance, viewMask, cfg.RaidId, cfg.IndoorID)

								if cfg.IsAboveFog then
									element.fData.ignoreFog = true
								end

								element:SetPosition(Vector3.New(coord[1], coord[2], coord[3]))

								element.mData.lName = GpsLText.CreateCommonText(cfg, "Name")
								element.gpsData.removeGpsRange = LTConfig.GameConfig.MapEntranceAutoRemoveGpsRange
								element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

								if cfg.SMiniMapIconId and cfg.SMiniMapIconId > 0 then
									element.miniMapData.iconId = cfg.SMiniMapIconId
								end

								if typeCfg.ShowType and typeCfg.ShowType > 0 then
									gMapSubSystemUtils:SetupScaleLevel(element, typeCfg.ShowType, typeCfg.SThumbnailIcon)
								end

								if cfg.Type == gMapUtils.RaidMapEntranceType.Metro then
									element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Metro
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

function M:OnLogout()
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	for _, info in pairs(self.entrances) do
		info.mapElement:Dispose()
	end

	table.clear(self.entrances)
end

local FORBID_TEXT_ID = 74000635

function M:OnFlushData()
	local forbidLText = nil

	for id, entrance in pairs(self.entrances) do
		local cfg = MapentranceConfig.GetConfig(id)
		local typeCfg = MapEntranceTypeConfig.GetConfig(cfg.Type)
		local visible = self:IsEntranceVisibleOnMap(id)

		entrance.mapElement:SetVisible(visible)

		entrance.unlocked = gMapUtils:IsEntranceUnlocked(id)
		entrance.teleportable = typeCfg.IfCanTeleport

		if entrance.unlocked and entrance.teleportable then
			if id ~= MapentranceConfig.PortalItem then
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

		if gMapUtils:IsEntranceUnlocked(id) then
			entrance.mapElement.mData.sIconId = cfg.SIconId
		else
			entrance.mapElement.mData.sIconId = cfg.SDisableIconId and cfg.SDisableIconId > 0 and cfg.SDisableIconId or cfg.SIconId
		end

		if cfg.Type == gMapUtils.RaidMapEntranceType.House then
			local houseCfg = LTConfig.HouseConfig.GetConfig(self._entranceId2HouseId[id])
			entrance.mapElement.bigMapData.scaleLevel = gBuyHouseUtils.CheckHasBuyTheHouse(houseCfg.Id) and 1 or self.Type2BigMapVisualThreshold[cfg.Type]
		elseif cfg.Type == gMapUtils.RaidMapEntranceType.Tower then
			local isUnlock = gBlockMgr:IsBlockUnlocked(entrance.blockId)
			entrance.mapElement.bigMapData.scaleLevel = isUnlock and self.Type2BigMapVisualThreshold[cfg.Type] or 1
		else
			entrance.mapElement.bigMapData.scaleLevel = self.Type2BigMapVisualThreshold[cfg.Type]
		end
	end
end

function M:IsEntranceVisibleOnMap(id)
	local info = self.entrances[id]

	if not info then
		return false
	end

	local cfg = MapentranceConfig.GetConfig(id)
	local typeCfg = MapEntranceTypeConfig.GetConfig(cfg.Type)

	if typeCfg.ShowWithBlock and typeCfg.ShowWithBlock > 0 then
		if typeCfg.ShowWithBlock == 1 then
			if not gBlockMgr:IsBlockUnlocked(info.blockId) then
				return false
			end
		elseif typeCfg.ShowWithBlock == 2 then
			if gBlockMgr:IsBlockUnlocked(info.blockId) then
				return false
			end

			if id == LTConfig.CollectionConfig.InitialTower then
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

function M:SGetTooltipInfo(id)
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

	if cfg.Type == gMapUtils.RaidMapEntranceType.House then
		local houseCfg = LTConfig.HouseConfig.GetConfig(self._entranceId2HouseId[id])
		tooltipInfo.type = EMapTooltipType.House
		tooltipInfo.houseInfo = {
			owned = gBuyHouseUtils.CheckHasBuyTheHouse(self._entranceId2HouseId[id]),
			parkingSpaceCount = houseCfg.ParkingSpaceCount,
			bedroomCount = houseCfg.BedRoomCount,
			petCount = houseCfg.PetCount,
			desc = cfg.Information or ""
		}
		tooltipInfo.header.subtitle = houseCfg.Tags[1]
	elseif cfg.Type == gMapUtils.RaidMapEntranceType.Metro then
		tooltipInfo.type = EMapTooltipType.MapEntrance
		tooltipInfo.mapEntranceInfo = {
			id = id,
			type = cfg.Type
		}
	elseif cfg.Type == gMapUtils.RaidMapEntranceType.Tower then
		tooltipInfo.type = EMapTooltipType.MapEntrance
		tooltipInfo.mapEntranceInfo = {
			simpleDropId = LTConfig.CollectionBlockConfig.GetConfig(info.blockId).DropId,
			type = cfg.Type
		}
	elseif cfg.Type ~= gMapUtils.RaidMapEntranceType.Dungeon then
		if cfg.Type == gMapUtils.RaidMapEntranceType.TempDungeon then
			-- Nothing
		elseif cfg.Type == gMapUtils.RaidMapEntranceType.Portal then
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

function M:ExecuteAction(element, action, ctx)
	if action == gMapSystemElementAction.Trace then
		actionHelper.Trace(element, ctx)
	elseif action == gMapSystemElementAction.Untrace then
		actionHelper.Untrace(element, ctx)
	elseif action == gMapSystemElementAction.Teleport or action == gMapSystemElementAction.TeleportPortal then
		self:Teleport(element, ctx)
	else
		print_error("MapSubSystem_Entrance:ExecuteAction: unknown action type: " .. action)
	end
end

function M:Teleport(element, ctx)
	if element.id == ctx.currentEnteringMetroId then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.TryTeleportCurrentMetro, nil, nil, MapentranceConfig.GetConfig(element.id).Name)

		return
	end

	self:TryTeleport(element.id)
end

function M:TryTeleport(id)
	self:TeleportTo(id)
end

function M:GetCurrentRaidAllMetroPosition()
	local ret = {}

	for id, entrance in pairs(self.entrances) do
		if entrance.teleportable then
			local element = entrance.mapElement

			if element.raidId == gMapSystem.lastRaidId then
				table.insert(ret, element:GetWorldPos())
			end
		end
	end

	return ret
end

function M:SyncPortalItem(raidId, position)
	local id = MapentranceConfig.PortalItem or -1
	local entranceCfg = MapentranceConfig.GetConfig(id)

	if not entranceCfg then
		return
	end

	self:DisposePortalItem()

	local typeCfg = MapEntranceTypeConfig.GetConfig(entranceCfg.Type)
	local viewMask = EMapViewMask.AllUi
	local elementType = EMapElementType.Entrance
	local element = MapElement.CreateLegacy(elementType, id, EMapSubSystemType.Entrance, viewMask, raidId, 0)

	element:SetPosition(Vector3.New(position.X, position.Y, position.Z))

	element.mData.lName = GpsLText.CreateCommonText(entranceCfg, "Name")
	element.gpsData.removeGpsRange = LTConfig.GameConfig.MapEntranceAutoRemoveGpsRange
	element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

	if typeCfg.ShowType and typeCfg.ShowType > 0 then
		gMapSubSystemUtils:SetupScaleLevel(element, typeCfg.ShowType, typeCfg.SThumbnailIcon)
	end

	local blockId = MapBlockMgr.GetBlockIdXZ(raidId, position.X, position.Z)

	if blockId == nil or blockId == 0 then
		if blockId == nil then
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

function M:DisposePortalItem()
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

function M:GetPortalPosition()
	return Vector3.New(self.portalPosition.X, self.portalPosition.Y, self.portalPosition.Z)
end

function M:GetPortalRaidId()
	return self.portalRaidId
end

function M:TeleportTo(id)
	if gDriveVehiclesManager.cs_manager.isDriveMode then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.VehicleBanTeleport)

		return
	end

	if id == MapentranceConfig.PortalItem then
		self:PortalTeleport(id)

		return
	end

	local targetRaidId = MapentranceConfig.GetConfig(id).RaidId

	if gRaidDataManager.RaidId == targetRaidId then
		local loadingInfoIndex = nil
		loadingInfoIndex = gLoadingManager:Quick_MapTeleport(id, false, function ()
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			gMainPhoneUtils.CloseMainPhonePanel(true)

			gClientToGameSceneDelegate:AskPlayerChangePositionByScenePortal(id).Callback = function (err)
				if err ~= MessageConfig.Ok then
					if gLoadingManager:CheckLoadingInfoIndexIsLoading(loadingInfoIndex) then
						gLoadingManager:StopWaitLoading(loadingInfoIndex)
					else
						gLoadingManager:StopLoading(loadingInfoIndex, false)
						gDisplayMessageMgr:ShowMessage(err)
					end

					return
				end
			end
		end)

		return
	end

	local loadingInfoIndex = nil
	loadingInfoIndex = gLoadingManager:Quick_MapTeleport(id, true, function ()
		gRpcUtils:AskPublicSwitchToPublicScene(targetRaidId, id, function ()
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			gMainPhoneUtils.CloseMainPhonePanel(true)
		end, function ()
			if gLoadingManager:CheckLoadingInfoIndexIsLoading(loadingInfoIndex) then
				gLoadingManager:StopWaitLoading(loadingInfoIndex)
			else
				gLoadingManager:StopLoading(loadingInfoIndex, false)
			end
		end)
	end)
end

function M:PortalTeleport(id)
	local entrance = self.entrances[id]

	if not entrance or not entrance.mapElement then
		print_error("@xiajingbo01 科学家传送道具raidId为空")

		return
	end

	local targetRaidId = self.portalRaidId
	local textCfg = LTConfig.TextConfig.GetConfig(73970800)
	local text = ""

	if textCfg then
		text = textCfg.Text
	else
		print_error("@xiajingbo01 Quick_Portal传送门没有对应TextConfig配置")
	end

	if gRaidDataManager.RaidId == targetRaidId then
		local textTeleportParams = gLoadingManager:Create_TextTeleportParams()
		textTeleportParams.text = text
		textTeleportParams.targetPos = self:GetPortalPosition()
		textTeleportParams.forceLoading = false

		function textTeleportParams.beforeLoadingPlayCb()
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			gMainPhoneUtils.CloseMainPhonePanel(true)

			gClientToGameSceneDelegate:AskPlayerChangePositionByScenePortal(id).Callback = function (err)
				if err ~= MessageConfig.Ok then
					if gLoadingManager:CheckLoadingInfoIndexIsLoading(self.portalLoadingInfoIndex) then
						gLoadingManager:StopWaitLoading(self.portalLoadingInfoIndex)
					else
						gLoadingManager:StopLoading(self.portalLoadingInfoIndex, false)
						gDisplayMessageMgr:ShowMessage(err)
					end

					return
				end
			end
		end

		self.portalLoadingInfoIndex = gLoadingManager:Quick_TextTeleport(textTeleportParams)
	else
		local textTeleportParams = gLoadingManager:Create_TextTeleportParams()
		textTeleportParams.text = text
		textTeleportParams.targetPos = self:GetPortalPosition()
		textTeleportParams.forceLoading = true

		function textTeleportParams.beforeLoadingPlayCb()
			gRpcUtils:AskPublicSwitchToPublicScene(targetRaidId, id, function ()
				gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
				gMainPhoneUtils.CloseMainPhonePanel()
			end, function ()
				if gLoadingManager:CheckLoadingInfoIndexIsLoading(self.portalLoadingInfoIndex) then
					gLoadingManager:StopWaitLoading(self.portalLoadingInfoIndex)
				else
					gLoadingManager:StopLoading(self.portalLoadingInfoIndex, false)
				end
			end)
		end

		self.portalLoadingInfoIndex = gLoadingManager:Quick_TextTeleport(textTeleportParams)
	end

	if id == MapentranceConfig.PortalItem then
		self:DisposePortalItem()
	end
end

function M:LoginSyncPortal()
	local playerItemInfo = gPlayerManager.infoItem.bindData

	gMapUtils:SyncPortalItem(playerItemInfo.portalRaidId, playerItemInfo.portalPosition)
end

function M:CalcMetroCost(fromRaid, toRaid, playerPos, toPos)
	local cost = 0
	local dx = playerPos.x - toPos.x
	local dz = playerPos.z - toPos.z
	local distance = math.sqrt(dx * dx + dz * dz)

	if gMapAreaMgr:IsBigWorldRaidId(gMapSystem.lastRaidId) then
		if fromRaid == toRaid then
			cost = self:CalcSubwayCostByDistance(distance)
		else
			cost = LTConfig.MapentranceConfig.OverseaCost
		end
	else
		local jiGuanRaidId = self.raidId2JiguanRaidId[fromRaid] or 0

		if jiGuanRaidId == 0 then
			cost = 0
		elseif jiGuanRaidId == fromRaid then
			cost = self:CalcSubwayCostByDistance(distance)
		else
			cost = LTConfig.MapentranceConfig.OverseaCost
		end
	end

	return cost
end

function M:CalcSubwayCostByDistance(distance)
	local cost = 0
	local payTipsNumNew = LTConfig.MapentranceConfig.PayTipsNumNew

	for i = 1, #payTipsNumNew do
		local val = payTipsNumNew[i]
		cost = val.cost

		if distance < val.maxDistance then
			break
		end
	end

	return cost
end

function M:GetActionInfo(element)
	local blockReason = element.actionsBlockReason

	if blockReason then
		return element:GetRawActions(), blockReason:GetText()
	end

	return element:GetRawActions(), nil
end

return M
