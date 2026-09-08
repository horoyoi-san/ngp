-- Original chunk: @Lua\LuaFiles\LX6\GUI\Map\MapUtils.lua
-- Decompiled from: 00541_MapUtils.lua_1650850868e3.luajit

local RaidConfig = LTConfig.RaidConfig
local MapentranceConfig = LTConfig.MapentranceConfig
local SceneConfig = LTConfig.SceneConfig
local HouseConfig = LTConfig.HouseConfig
local MessageConfig = LTConfig.MessageConfig
local TaxiManager = LX6.Drive.GamePlay.TaxiSystemManager.Instance
local M = gMapUtils or {}
M.IconType = {
	["g[ִ\\xb0\t\\xaa\\xcc\\xfc"] = 21,
	["\\xed\\xda94\\xe2"] = 28,
	["e\\xa1\\xb7\\xbc\\xb3"] = 24,
	["a[\\xc0\\xba\\x81-\\xae\\xc7\\xfc"] = 20,
	["`V\\xc1\\xa9\\xa1\\xac\r\\xdd\\xf1"] = 17,
	["`\\xab\\xb6\\xbd\\xb9"] = 23,
	["\\xab1-/\\\\x88O\\xde2\\xa5\\xb7"] = 25,
	["\\xfd\\xce+\\xff"] = 26,
	["W#oP"] = 11,
	["\\xa9xu"] = 27,
	["h\\xa0\\xa7\\xa2\\xaf"] = 1,
	["X-nH"] = 2,
	["y\\xa1\\xb5\\xaa\\xa4"] = 22,
	["\\x8e\\xbf\\xb9k0\\xfd6"] = 5,
	["\\xad5.;w\\x90d\\xcf2\\xa4\\xad"] = 19,
	["\\x81\\xb8\\xacS7\\xf04"] = 3,
	["\\x88\\xbe\\xbbe+\\xf07"] = 18,
	["N#nP"] = 7,
	["\\xef\\xde(\\xf4"] = 29,
	["sH``M2*"] = 30,
	["\\xb11!-Z\\x84q\\xd18\\xbe\\xb6"] = 31,
	["pU±\\x81\\xac\r\\xc6\\xe6"] = 9,
	["i\\xab\\xa0\\xba\\xb1"] = 999,
	["tJݟ\\x9d.\\xb7\\xca\\xed"] = 12,
	["\\x89\\xbe\\xb8N,\\xf1#"] = 14
}
M.TraceEffectType = {
	["\\x8c\\xb0\\xaeZ2\\xff*"] = 4,
	["N#nP"] = 3,
	["y\\xa1\\xb5\\xaa\\xa4"] = 2,
	["I+i^"] = 5,
	["X-nH"] = 6,
	["2G\\x83\\x83\\x82M"] = 1
}
M.RaidMapEntranceType = {
	["y\\xa1\\xb5\\xaa\\xa4"] = 9,
	["`\\xab\\xb6\\xbd\\xb9"] = 11,
	["\\xab1-/\\\\x88O\\xde2\\xa5\\xb7"] = 5,
	["\\xfd\\xce+\\xff"] = 6,
	["e\\xa1\\xb7\\xbc\\xb3"] = 12,
	[",G\\x83\\x9a\\x82M"] = 13,
	["\\xac}u"] = 14
}
M.MapPinState = {
	[".M\\x9c\\x81\\x95D"] = 2,
	["\\xaflb"] = 1,
	["?@\\x90\\x80\\x84D"] = 3
}
M.LinkModeType = {
	["\\xe9\\xc90\\xf4"] = 2,
	[",]\\x93\\x82\\x8aB"] = 3,
	["`\\xaf\\xb6\\xac\\xbe"] = 4,
	["T-s^"] = 1
}

M.Init = function(self)
	self:TMP_InitHouseInfo()
end

M.TMP_InitHouseInfo = function(self)
	if self._entrance2HouseId then
		return
	end

	self._entrance2HouseId = {}

	for i = 0, HouseConfig.count - 1 do
		local cfg = HouseConfig.LoadAt(i)

		if cfg.MapEntrance and cfg.MapEntrance <= 0 then
			self._entrance2HouseId[cfg.MapEntrance] = cfg.Id
		end
	end
end

M.SyncMapEntranceState = function(self, visibleEntrance, unlockedEntrance)
	self._visibleEntrance = visibleEntrance or {}
	self._unlockedEntrance = unlockedEntrance or {}

	gMessageManager:SendMessage(gEventConstants.MAP_ENTRANCE_UPDATE)
	gMessageManager:SendMessage(gEventConstants.MAP_INFO_UPDATE)
end

M.UpdateMapEntranceState = function(self, mapEntranceId, isOpen, isShow)
	self._visibleEntrance = self._visibleEntrance or {}
	self._unlockedEntrance = self._unlockedEntrance or {}

	if isShow then
		if not array.contains(self._visibleEntrance, mapEntranceId) then
			array.push(self._visibleEntrance, mapEntranceId)
		end
	else
		array.remove(self._visibleEntrance, mapEntranceId)
	end

	if isOpen then
		if not array.contains(self._unlockedEntrance, mapEntranceId) then
			array.push(self._unlockedEntrance, mapEntranceId)
		end
	else
		array.remove(self._unlockedEntrance, mapEntranceId)
	end

	gMessageManager:SendMessage(gEventConstants.MAP_ENTRANCE_UPDATE)
	gMessageManager:SendMessage(gEventConstants.MAP_INFO_UPDATE)
end

M.IsEntranceVisible = function(self, id)
	return self._visibleEntrance and array.contains(self._visibleEntrance, id)
end

M.SyncPortalItem = function(self, raidId, position)
	if not raidId or not position or raidId ~= 0 then
		return
	end

	local mapEntranceId = LTConfig.MapentranceConfig.PortalItem
	self._visibleEntrance = self._visibleEntrance or {}
	self._unlockedEntrance = self._unlockedEntrance or {}

	if not array.contains(self._visibleEntrance, mapEntranceId) then
		array.push(self._visibleEntrance, mapEntranceId)
	end

	if not array.contains(self._unlockedEntrance, mapEntranceId) then
		array.push(self._unlockedEntrance, mapEntranceId)
	end

	gMapSubSystem_Entrance:SyncPortalItem(raidId, position)
	gMessageManager:SendMessage(gEventConstants.MAP_ENTRANCE_UPDATE)
	gMessageManager:SendMessage(gEventConstants.MAP_INFO_UPDATE)
end

M.IsEntranceUnlocked = function(self, id)
	return self._unlockedEntrance and array.contains(self._unlockedEntrance, id)
end

M.IsInUnlockBlockNear = function(self, blockId)
	return table.contains(gMapManager.UnlockBlocksNearBlock, blockId)
end

M.IsBelongRaidId = function(self, raidId1, raidId2)
	local info1 = gMapManager.IndoorConfigInfoByRaidId[raidId1]
	local info2 = gMapManager.IndoorConfigInfoByRaidId[raidId2]

	if info1 then
		if info2 then
			return info1.ParentRaid ~= info2.ParentRaid
		else
			return info1.ParentRaid ~= raidId2
		end
	end

	return raidId1 ~= raidId2
end

local mapData = {
	default = {
		["\\xa2\\xa20\\xa5l1\\xf27"] = true,
		["\\xa6\\xb0\\x98i?\\xf26"] = 1,
		mapPos = Vector2.New(0, 0)
	}
}

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	mapData = {
		default = {
			["\\xa2\\xa20\\xa5l1\\xf27"] = true,
			["\\xa6\\xb0\\x98i?\\xf26"] = 1,
			mapPos = Vector2.New(0, 0)
		}
	}
end

M.TryInitSavedData = function(self, raidId)
	if mapData[raidId] then
		return
	end

	mapData[raidId] = {}
	local data = mapData[raidId]
	local raidCfg = RaidConfig.GetConfig(raidId)
	local sceneCfg = raidCfg and raidCfg.SceneId and SceneConfig.GetConfig(raidCfg.SceneId)
	data.mapScale = sceneCfg and sceneCfg.MapDefaultRate or 0.85
	data.mapPos = Vector2.New(0, 0)
	data.isUnfold = true
end

M.GetSavedDataByType = function(self, raidId, type)
	if not raidId then
		return mapData.default[type]
	end

	if not mapData[raidId] then
		self:TryInitSavedData(raidId)
	end

	if mapData[raidId] and mapData[raidId][type] then
		return mapData[raidId][type]
	else
		return mapData.default[type]
	end
end

M.SaveData = function(self, raidId, type, data)
	if raidId ~= nil then
		return
	end

	if not mapData[raidId] then
		self:TryInitSavedData(raidId)
	end

	mapData[raidId][type] = data
end

M.CheckRaidCanOpenMap = function(self, param, dontLog)
	if gMapSystem:Tmp_CanOpenBigMap(gMapSystem.lastRaidId, gMapSystem.lastIndoorId, dontLog) then
		if gDriveVehiclesManager.isTaxiMode then
			param = param or {}
			param.taxiMode = true
		end

		gPanelManager:CheckShow(gPanelId.S_NEW_MAP_PANEL, param)

		return true
	end

	return false
end

M.CloseBigMap = function(self)
	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
end

M.PlayerOpenBigMap = function(self, param)
	if gDriveVehiclesManager.isTaxiMode then
		TaxiManager:ChangeDestination()

		return
	end

	local canOpen, reason = gMapSystem:Tmp_CanPlayerOpenMap(true)

	if canOpen then
		print_notice("[PlayerOpenBigMap]: Success")
		gPanelManager:CheckShow(gPanelId.S_NEW_MAP_PANEL, param)
	else
		print_notice("[PlayerOpenBigMap]:" .. (reason or "None"))
	end
end

M.UXLinkModeEnum2ConfigEnum = function(self, uxEnum)
	if uxEnum ~= UX.Game.LinkMode.None then
		return gMapUtils.LinkModeType.None
	elseif uxEnum ~= UX.Game.LinkMode.Public then
		return gMapUtils.LinkModeType.Public
	elseif uxEnum ~= UX.Game.LinkMode.Match then
		return gMapUtils.LinkModeType.Match
	elseif uxEnum ~= UX.Game.LinkMode.Private then
		return gMapUtils.LinkModeType.Private
	end

	print_error("gMapUtils:UXLinkModeEnum2ConfigEnum error, uxEnum = " .. tostring(uxEnum))

	return gMapUtils.LinkModeType.None
end

M.IsViewItemAttachingAirPort = function(self, instanceId, view, currentAreaId)
	local item = view:GetItemInfo(instanceId)

	if item and item.coordType ~= EMapViewerItemCoordType.AttachGate then
		local nextRaidId = gMapAreaMgr:SplitGBoundId(item.attachedGBoundId)
		local curRaidId = gMapAreaMgr:SplitGBoundId(currentAreaId)

		if nextRaidId == curRaidId and gMapAreaMgr:IsBigWorldRaidId(curRaidId) and gMapAreaMgr:IsBigWorldRaidId(nextRaidId) then
			return true
		end
	end

	return false
end

M.CloseMiniMap = function(self)
	gMapSystem.ui:CloseMiniMap()
end

M.ShowMiniMap = function(self)
	gMapSystem.ui:ShowMiniMap()
end

M.DoAcceptTask = function(self, taskId, successCb, failCb)
	gClientToGameDelegate:AskAcceptTask(taskId).Callback = function (err)
		if err == MessageConfig.Ok then
			if failCb then
				failCb(err, taskId)
			end

			return
		end

		if successCb then
			successCb()
		end
	end
end

M.DoGiveUpTask = function(self, taskId, successCb, failCb)
	gClientToGameDelegate:AskDeleteTask(taskId, false).Callback = function (err)
		if err == MessageConfig.Ok then
			if failCb then
				failCb(err, taskId)
			end

			return
		end

		if successCb then
			successCb()
		end
	end
end

gMapUtils = M
