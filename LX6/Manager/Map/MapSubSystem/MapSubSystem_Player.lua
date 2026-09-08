-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Player.lua
-- Decompiled from: 02340_MapSubSystem_Player.lua_236b12d1d00e.luajit

local GpsConfig = LTConfig.GpsConfig
MapSubSystem_Player = DefClass("MapSubSystem_Player", MapSubSystem_Player, MapSubSystemBase)
local M = MapSubSystem_Player

M.OnInit = function(self)
	self.playerItems = {}
	self.vehicleItems = {}

	self.InitEventHandlers(self)

	self.hideTeamMember = false
	self.enableTeamMemberAlphaController = 0
	self.myTemplateId = 0
	self.pidToVehicleIdList = {}
	self.inCarRacing = false
end

M.OnLogin = function(self)
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	for pid, _ in pairs(self.playerItems) do
		self.DisposePlayerItem(self, pid)
	end

	if next(self.vehicleItems) then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapSubSystem_Player:OnLogout - Vehicle items not cleared")

		for pid, mapElement in pairs(self.vehicleItems) do
			mapElement.Dispose(mapElement)

			self.vehicleItems[pid] = nil
		end
	end
end

M.InitEventHandlers = function(self)
	self.eventHandlers = {
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:FlushData("LinkModeChange")
		end,
		[gEventConstants.LINK_MEMBER_INFO_CHANGE] = function ()
			self:FlushData("LinkMemberInfoChange")
		end,
		[gEventConstants.TEAM_REFRESH_DATA] = function ()
			self:FlushData("TeamRefreshData")
		end,
		[gEventConstants.MAP_CHANGE_TO_INDOOR_MAP] = function ()
			self:OnLocalPlayerIndoorChanged()
		end
	}
end

M.OnFlushData = function(self)
	local linkMemberInfo = gLinkManager.LinkMemberInfo or {}

	for pid, _ in pairs(self.playerItems) do
		self.RefreshPlayerItem(self, pid)
	end

	for pid, memberInfo in pairs(linkMemberInfo) do
		if not self.playerItems[pid] then
			self.RefreshPlayerItem(self, pid)
		end
	end
end

M.RefreshPlayerVehicle = function(self, pid)
	if not self.inCarRacing then
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if gGpsTools:UnitIsNull(unit) then
			return
		end

		local isOnVehicle, vehicleId, index = unit:IsBindOnVehicle(nil, )

		self:SetPlayerVehicle(pid, isOnVehicle and vehicleId or nil)
	end
end

M.SetPlayerVehicle = function(self, pid, vehicleId)
	local playerItem = self.playerItems[pid]

	if playerItem.vehicleId ~= vehicleId then
		return
	end

	local oldVehicleId = playerItem.vehicleId
	playerItem.vehicleId = vehicleId

	if oldVehicleId then
		self.RemovePlayerFromVehicle(self, pid, oldVehicleId)
	end

	if vehicleId then
		self.AddPlayerToVehicle(self, pid, vehicleId, playerItem.playerElement.raidId)
	end

	self.RefreshPlayerVisible(self, pid)
end

M.RefreshPlayerVisible = function(self, pid)
	local playerItem = self.playerItems[pid]
	local linkMemberInfo = gLinkManager.LinkMemberInfo or {}
	local hideMember = linkMemberInfo[pid] == nil and self.hideTeamMember

	playerItem.playerElement:SetVisible((self.inCarRacing or not playerItem.vehicleId) and playerItem.hasCoordInfo and not hideMember)
	self:RefreshVehicleVisible()
end

M.RefreshVehicleVisible = function(self, pid)
	local vehicleItem = self.vehicleItems[pid]

	if vehicleItem then
		vehicleItem.SetVisible(vehicleItem, not self.inCarRacing)
	end
end

M.SetPlayerTeamAlphaController = function(self, enable)
	self.enableTeamMemberAlphaController = enable
	local instanceIds = {}

	for pid, _ in pairs(self.playerItems) do
		local instanceId = self.RefreshPlayerAlphaController(self, pid, enable)

		if instanceId then
			table.insert(instanceIds, instanceId)
		end
	end

	local linkMemberInfo = gLinkManager.LinkMemberInfo or {}

	for pid, memberInfo in pairs(linkMemberInfo) do
		if not self.playerItems[pid] then
			local instanceId = self.RefreshPlayerAlphaController(self, pid, enable)

			if instanceId then
				table.insert(instanceIds, instanceId)
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.TEAM_MEMBER_GPS_ALPHA_CHANGE, instanceIds)
end

M.RefreshPlayerAlphaController = function(self, pid, enable)
	local linkMemberInfo = gLinkManager.LinkMemberInfo or {}

	if linkMemberInfo[pid] then
		local playerItem = self.playerItems[pid]
		playerItem.playerElement.fData.enableGpsAlphaCtrl = enable

		return playerItem.playerElement.instanceId
	end

	return nil
end

M.RemovePlayerFromVehicle = function(self, pid, vehicleId)
	if not self.vehicleItems[vehicleId] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapSubSystem_Player:RemovePlayerFromVehicle - Vehicle not found", vehicleId)

		return
	end

	local vehicleItem = self.vehicleItems[vehicleId]

	if not vehicleItem.playerMap[pid] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapSubSystem_Player:RemovePlayerFromVehicle - Player not found in vehicle", pid, vehicleId)

		return
	end

	vehicleItem.playerMap[pid] = nil

	if not next(vehicleItem.playerMap) then
		vehicleItem.vehicleElement:Dispose()
		gGpsTools.ReleaseTable(vehicleItem.playerMap)
		gGpsTools.ReleaseTable(vehicleItem)

		self.vehicleItems[vehicleId] = nil
	end
end

M.AddPlayerToVehicle = function(self, pid, vehicleId, raidId)
	local vehicleItem = self.vehicleItems[vehicleId]

	if vehicleItem then
		vehicleItem.playerMap[pid] = true

		return
	end

	vehicleItem = gGpsTools.GetTable()
	vehicleItem.playerMap = gGpsTools.GetTable()
	local playerItem = self.playerItems[pid]
	local vehicleElement = MapElement.CreateLegacy(EMapElementType.Player, vehicleId, EMapSubSystemType.Player, EMapViewMask.HudGps + EMapViewMask.BigMap + EMapViewMask.MiniMap + EMapViewMask.FocusMode, playerItem.playerElement.raidId)
	vehicleElement.gpsData.tmp_HudAutoHideDistance = LTConfig.LinkConfig.TeamMemberSwitchShowDistance
	vehicleElement.gpsData.tmp_DisableHideRangeWhenClamped = true

	if playerItem.needWeakGuide then
		vehicleElement.CbtSetWeakGuideInfo(vehicleElement, 10000)
	else
		vehicleElement.CbtClearWeakGuideInfo(vehicleElement)
	end

	vehicleItem.vehicleElement = vehicleElement

	vehicleElement.BindVehicle(vehicleElement, vehicleId, nil, , true)
	vehicleElement.SetVisible(vehicleElement, true)

	vehicleElement.mData.sIconId = 28001090
end

M.RefreshPlayerItem = function(self, pid)
	local memberInfo = gLinkManager.LinkMemberInfo and gLinkManager.LinkMemberInfo[pid]
	local mode = gLinkManager.LinkMemberState and gLinkManager.LinkMemberState[pid]

	if not memberInfo or not mode or mode == gLinkManager.LinkMode or memberInfo.TempLeave and memberInfo.TempLeave <= 0 then
		self.DisposePlayerItem(self, pid)

		return
	end

	local playerNumber = gTeamManager:GetMemberOrder(pid)
	local playerItem = self.playerItems[pid]

	if not playerItem then
		local element = MapElement.CreateLegacy(EMapElementType.Player, pid, EMapSubSystemType.Player, EMapViewMask.HudGps + EMapViewMask.BigMap + EMapViewMask.MiniMap + EMapViewMask.FocusMode, 0)
		playerItem = {
			playerElement = element
		}
		self.playerItems[pid] = playerItem
		element.mData.sIconId = LTConfig.GpsConfig.OnlinePlayerIcon[memberInfo.Index or 1]
		element.mData.playerNumber = playerNumber

		self:SetupPlayerCommonData(element)
	end

	local sceneInfo = gLinkManager.LinkMemberPosInfo and gLinkManager.LinkMemberPosInfo[pid]
	local element = playerItem.playerElement

	if self.inCarRacing then
		local carRacingVehicleId = self.pidToCarRacingVehicleIds[pid]

		if playerItem.carRacingVehicleId == carRacingVehicleId then
			if carRacingVehicleId then
				element.ClearBinding(element)
				element.BindVehicle(element, carRacingVehicleId, nil, , true)
			else
				element.ClearBinding(element)
			end

			playerItem.carRacingVehicleId = carRacingVehicleId
		end
	elseif playerItem.carRacingVehicleId then
		element.ClearBinding(element)

		playerItem.carRacingVehicleId = nil
	end

	if sceneInfo then
		if not self.inCarRacing then
			element.BindUnit(element, sceneInfo.AgentId)
		end

		element.SetRaidId(element, sceneInfo.RaidId)
		element.SetPositionXYZ(element, sceneInfo.X, sceneInfo.Y, sceneInfo.Z)

		element.mData.eulerZ = 360 - sceneInfo.F
	end

	playerItem.hasCoordInfo = sceneInfo == nil

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Match then
		if gLinkManager:CheckIsInRaid() or gLinkManager:CheckIsExtractionShooter() then
			playerItem.needWeakGuide = true
		else
			playerItem.needWeakGuide = false
		end

		element.mData.sIconId = LTConfig.GpsConfig.OnlinePlayerIcon[memberInfo.Index or 1]
		element.mData.playerNumber = playerNumber
		element.fData.bigMapTIndex = 3
		element.bigMapData.arrowColor = Color.New(0, 0, 0, 1)
		element.miniMapData.miniMapTIndex = 4
		element.fData.hudTIndex = 9
	else
		local idx = gTeamManager:IsInTeamByPid(pid) and gTeamManager:GetMemberOrder(pid) or nil

		if idx then
			playerItem.needWeakGuide = true
			element.mData.sIconId = LTConfig.GpsConfig.OnlinePlayerIcon[idx]
			element.mData.playerNumber = idx
			element.fData.bigMapTIndex = 3
			element.bigMapData.arrowColor = Color.New(0, 0, 0, 1)
			element.miniMapData.miniMapTIndex = 4
			element.fData.hudTIndex = 9
		else
			playerItem.needWeakGuide = false
			element.fData.bigMapTIndex = 5
			element.miniMapData.miniMapTIndex = 5
		end
	end

	element.mData.tintColor = gLinkManager:GetColorInfo(pid)

	if playerItem.needWeakGuide then
		element.CbtSetWeakGuideInfo(element, 10000)

		element.miniMapData.tmp_needWeakGuide = true
	else
		element.CbtClearWeakGuideInfo(element)

		element.miniMapData.tmp_needWeakGuide = false
	end

	self.RefreshPlayerVehicle(self, pid)
	self.RefreshPlayerVisible(self, pid)
end

M.DisposePlayerItem = function(self, pid)
	local playerItem = self.playerItems[pid]

	if playerItem then
		if playerItem.vehicleId then
			self.SetPlayerVehicle(self, pid, nil)
		end

		playerItem.playerElement:Dispose()
		gGpsTools.ReleaseTable(playerItem)

		self.playerItems[pid] = nil
	end
end

M.SetupPlayerCommonData = function(self, element)
	element.miniMapData.dontSetColor = true
	element.miniMapData.hideArrowWhenClamped = true
	element.gpsData.tmp_HudAutoHideDistance = LTConfig.LinkConfig.TeamMemberSwitchShowDistance
	element.gpsData.tmp_DisableHideRangeWhenClamped = true
	local showType = LTConfig.GpsConfig.ShowTypeofLinkPlayer[1]
	local thumbnailIconId = LTConfig.GpsConfig.ShowTypeofLinkPlayer[2]
	element.bigMapData.unselectable = true

	gMapSubSystemUtils:SetupScaleLevel(element, showType, thumbnailIconId)

	if GpsConfig.LinkPlayerIsAboveFog then
		element.fData.ignoreFog = true
	end

	element.mData.dontCull = true
	element.fData.showInBigWorld = true
	element.fData.bigMapTIndex = 3
	element.fData.enableGpsAlphaCtrl = self.enableTeamMemberAlphaController
	element.fData.hudTIndex = 9
	element.mData.ignoreIndoorPenetration = true
	local scaleFactor = LTConfig.GpsConfig.OnlineMiniIconScale

	if scaleFactor and scaleFactor <= 0 then
		element.mData.scaleFactor = scaleFactor
	end

	element.onBoundChanged = function(indoorId, localBoundId)
		element._playerIndoorId = indoorId
		element._playerLocalBoundId = localBoundId

		if indoorId and indoorId == 0 then
			if (gMapSystem.lastIndoorId or 0) ~= 0 then
				element:SetOverrideBoundInfo(0, 0)
			end
		else
			element.overrideIndoorId = nil
			element.overrideLocalBoundId = nil
			element.indoorId = 0
			element.localBoundId = 0

			element:UpdateGBoundId()
		end
	end
end

M.OnLocalPlayerIndoorChanged = function(self)
	local myIndoorId = gMapSystem.lastIndoorId or 0

	if myIndoorId == 0 then
		for _, item in pairs(self.playerItems) do
			local e = item.playerElement

			if (e._playerIndoorId or 0) == 0 and e.overrideIndoorId == nil then
				e.overrideIndoorId = nil
				e.overrideLocalBoundId = nil
				e.indoorId = e._playerIndoorId
				e.localBoundId = e._playerLocalBoundId or 0

				e:UpdateGBoundId()
			end
		end
	else
		for _, item in pairs(self.playerItems) do
			local e = item.playerElement

			if (e._playerIndoorId or 0) == 0 then
				e.SetOverrideBoundInfo(e, 0, 0)
			end
		end
	end
end

M.HideTeamMember = function(self, hide)
	self.hideTeamMember = hide

	self.OnFlushData(self)
end

M.Tick = function(self)
	self.RefreshMyUnit(self)
end

M.RefreshMyUnit = function(self)
	local unitId = gBattleSpiritMgr.currentSpiritPid
	local myUnit = gCS.SceneDataMgr.GetUnit(unitId)

	if gGpsTools:UnitIsNull(myUnit) then
		self.ClearMyUnit(self)

		return
	end

	if not self.me then
		self.me = MapElement.CreateLegacy(EMapElementType.Player, "Me", EMapSubSystemType.Player, EMapViewMask.MiniMap + EMapViewMask.FocusMode, gMapSystem.lastRaidId)
		self.me.bigMapData.unselectable = true
		self.me.miniMapData.miniMapTIndex = 6
	end

	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	if self.myTemplateId == playerUnit.TemplateId then
		self.myTemplateId = playerUnit.TemplateId
		local summonConfig = nil
		local agentConfig = LTConfig.AgentConfig.GetConfig(playerUnit.TemplateId)

		if agentConfig and agentConfig.SummonTag and agentConfig.SummonTag == 0 then
			summonConfig = LTConfig.SummonConfig.GetConfig(agentConfig.SummonTag)
		end

		if summonConfig then
			self.me:SetVisible(true)
		else
			self.me:SetVisible(false)
		end
	end

	self.me:BindUnit(myUnit.Id)
	self.me:SetRaidId(gMapSystem.lastRaidId)

	self.me.mData.eulerZ = -myUnit.EulerY
end

M.ClearMyUnit = function(self)
	if self.me then
		self.me:Dispose()

		self.me = nil
	end
end

M.SetPidToCarRacingVehicleIds = function(self, gameStart, pidToCarRacingVehicleIds)
	self.inCarRacing = gameStart
	self.pidToCarRacingVehicleIds = pidToCarRacingVehicleIds or {}

	self:FlushData()
end

return M
