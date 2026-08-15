local GpsConfig = LTConfig.GpsConfig
MapSubSystem_Player = DefClass("MapSubSystem_Player", MapSubSystem_Player, MapSubSystemBase)
local M = MapSubSystem_Player

function M:OnInit()
	self.playerItems = {}
	self.vehicleItems = {}

	self:InitEventHandlers()
end

function M:OnLogin()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnLogout()
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	for pid, _ in pairs(self.playerItems) do
		self:DisposePlayerItem(pid)
	end

	if next(self.vehicleItems) then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapSubSystem_Player:OnLogout - Vehicle items not cleared")

		for pid, mapElement in pairs(self.vehicleItems) do
			mapElement:Dispose()

			self.vehicleItems[pid] = nil
		end
	end
end

function M:InitEventHandlers()
	self.eventHandlers = {
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:FlushData("LinkModeChange")
		end,
		[gEventConstants.LINK_MEMBER_INFO_CHANGE] = function ()
			self:FlushData("LinkMemberInfoChange")
		end,
		[gEventConstants.TEAM_REFRESH_DATA] = function ()
			self:FlushData("TeamRefreshData")
		end
	}
end

function M:OnFlushData()
	local linkMemberInfo = gLinkManager.LinkMemberInfo or {}

	for pid, _ in pairs(self.playerItems) do
		self:RefreshPlayerItem(pid)
	end

	for pid, memberInfo in pairs(linkMemberInfo) do
		if not self.playerItems[pid] then
			self:RefreshPlayerItem(pid)
		end
	end
end

function M:RefreshPlayerVehicle(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
		return
	end

	local isOnVehicle, vehicleId, index = unit:IsBindOnVehicle(nil, nil)

	self:SetPlayerVehicle(pid, isOnVehicle and vehicleId or nil)
end

function M:SetPlayerVehicle(pid, vehicleId)
	local playerItem = self.playerItems[pid]

	if playerItem.vehicleId == vehicleId then
		return
	end

	local oldVehicleId = playerItem.vehicleId
	playerItem.vehicleId = vehicleId

	if oldVehicleId then
		self:RemovePlayerFromVehicle(pid, oldVehicleId)
	end

	if vehicleId then
		self:AddPlayerToVehicle(pid, vehicleId, playerItem.playerElement.raidId)
	end

	self:RefreshPlayerVisible(pid)
end

function M:RefreshPlayerVisible(pid)
	local playerItem = self.playerItems[pid]

	playerItem.playerElement:SetVisible(not playerItem.vehicleId and playerItem.hasCoordInfo)
end

function M:RemovePlayerFromVehicle(pid, vehicleId)
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

function M:AddPlayerToVehicle(pid, vehicleId, raidId)
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

	if playerItem.needWeakGuide then
		vehicleElement:CbtSetWeakGuideInfo(10000)
	else
		vehicleElement:CbtClearWeakGuideInfo()
	end

	vehicleItem.vehicleElement = vehicleElement

	vehicleElement:BindVehicle(vehicleId, nil, nil, true)
	vehicleElement:SetVisible(true)

	vehicleElement.mData.sIconId = 28001090
end

function M:RefreshPlayerItem(pid)
	local memberInfo = gLinkManager.LinkMemberInfo and gLinkManager.LinkMemberInfo[pid]
	local mode = gLinkManager.LinkMemberState and gLinkManager.LinkMemberState[pid]

	if not memberInfo or not mode or mode ~= gLinkManager.LinkMode or memberInfo.TempLeave and memberInfo.TempLeave > 0 then
		self:DisposePlayerItem(pid)

		return
	end

	local playerItem = self.playerItems[pid]

	if not playerItem then
		local element = MapElement.CreateLegacy(EMapElementType.Player, pid, EMapSubSystemType.Player, EMapViewMask.HudGps + EMapViewMask.BigMap + EMapViewMask.MiniMap + EMapViewMask.FocusMode, 0)
		playerItem = {
			playerElement = element
		}
		self.playerItems[pid] = playerItem

		element:BindUnit(pid)

		element.mData.sIconId = LTConfig.GpsConfig.OnlinePlayerIcon[memberInfo.Index or 1]

		self:SetupPlayerCommonData(element)
	end

	local sceneInfo = gLinkManager.LinkMemberPosInfo and gLinkManager.LinkMemberPosInfo[pid]
	local element = playerItem.playerElement

	if sceneInfo then
		element:SetRaidId(sceneInfo.RaidId)
		element:SetPositionXYZ(sceneInfo.X, sceneInfo.Y, sceneInfo.Z)

		element.mData.eulerZ = 360 - sceneInfo.F
	end

	playerItem.hasCoordInfo = sceneInfo ~= nil

	if gLinkManager.LinkMode == UX.Game.LinkMode.Match then
		if gLinkManager:CheckIsInRaid() then
			playerItem.needWeakGuide = true
		else
			playerItem.needWeakGuide = false
		end

		element.mData.sIconId = LTConfig.GpsConfig.OnlinePlayerIcon[memberInfo.Index or 1]
		element.fData.bigMapTIndex = 3
		element.bigMapData.arrowColor = Color.New(0, 0, 0, 1)
		element.miniMapData.miniMapTIndex = 4
	else
		local teamMembers = gTeamManager.members
		local idx = nil

		if teamMembers then
			for i, member in ipairs(teamMembers) do
				if member.Pid == pid then
					idx = i

					break
				end
			end
		end

		if idx then
			playerItem.needWeakGuide = true
			element.mData.sIconId = LTConfig.GpsConfig.OnlinePlayerIcon[idx]
			element.fData.bigMapTIndex = 3
			element.bigMapData.arrowColor = Color.New(0, 0, 0, 1)
			element.miniMapData.miniMapTIndex = 4
		else
			playerItem.needWeakGuide = false
			element.fData.bigMapTIndex = 5
			element.miniMapData.miniMapTIndex = 5
		end
	end

	if playerItem.needWeakGuide then
		element:CbtSetWeakGuideInfo(10000)

		element.miniMapData.tmp_needWeakGuide = true
	else
		element:CbtClearWeakGuideInfo()

		element.miniMapData.tmp_needWeakGuide = false
	end

	self:RefreshPlayerVehicle(pid)
	self:RefreshPlayerVisible(pid)
end

function M:DisposePlayerItem(pid)
	local playerItem = self.playerItems[pid]

	if playerItem then
		if playerItem.vehicleId then
			self:SetPlayerVehicle(pid, nil)
		end

		playerItem.playerElement:Dispose()
		gGpsTools.ReleaseTable(playerItem)

		self.playerItems[pid] = nil
	end
end

function M:SetupPlayerCommonData(element)
	element.miniMapData.dontSetColor = true
	element.gpsData.tmp_HudAutoHideDistance = LTConfig.LinkConfig.TeamMemberSwitchShowDistance
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
	element.gpsData.ignoreIndoorPenetration = true
	local scaleFactor = LTConfig.GpsConfig.OnlineMiniIconScale

	if scaleFactor and scaleFactor > 0 then
		element.mData.scaleFactor = scaleFactor
	end
end

return M
