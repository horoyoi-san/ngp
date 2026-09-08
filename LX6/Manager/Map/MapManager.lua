-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapManager.lua
-- Decompiled from: 00569_MapManager.lua_3258664c97af.luajit

local CollectionBlockConfig = LTConfig.CollectionBlockConfig
local RaidConfig = LTConfig.RaidConfig
local GameConfig = LTConfig.GameConfig
local IndoorConfig = LTConfig.IndoorConfig
local M = {
	["\\x82\\xbf\\xa4e,\\xd77"] = 0,
	["\\xcf\\\\x83\\xf7'\\x9d*\\\\xdc*%\\xf3aܠ\\xb8K\\xaaLB\\xb2\\xc8"] = true,
	ZoneCfgInfo = {},
	UnlockBlocksNearBlock = {},
	IndoorConfigInfoByRaidId = {},
	miniMapScaleList = {},
	TitleColor = {
		"=l\\xb0\\xaa\\xa2e",
		"K\\xc8۠",
		"9Ȫ\\xd0"
	},
	ShowGpsTypeInMap = {
		gTaskGpsType.Forward,
		gTaskGpsType.Trace,
		gTaskGpsType.Follow,
		gTaskGpsType.Car
	},
	recordCurrentTask = {},
	UnlockBlocks = {},
	CountryList = {},
	_vehicleNavInfos = {},
	_curRangeEventInfos = {},
	rangeEventList = {},
	OnInit = function (self)
		gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, function (eventId, switchSceneEventParams)
			local switchType = switchSceneEventParams.switchSceneType

			if switchType ~= gSwitchSceneType.NewScene or switchType ~= gSwitchSceneType.Reconnect then
				self:CheckSceneIndoorId()
			elseif switchType ~= gSwitchSceneType.Image or switchType ~= gSwitchSceneType.SameImage then
				self:CheckSceneIndoorId()
			end

			self:SetUnlockBlockAndZones()
		end)
		gMessageManager:AddMessageListener(gEventConstants.MAP_SCALE_UPDATE, function (eventId, scale)
			if scale ~= 0 then
				self:RemoveMiniMapScaleType(gMapScaleType.Area)
			else
				self:SetMiniMapScale(scale, gMapScaleType.Area)
			end
		end)
		self:InitIndoorConfig()
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if switchType and gSwitchSceneType.Image >= switchType then
			self.ChangeMapId(self, 0, true)

			self.miniMapScaleList = {}
		end

		if switchType == gSwitchSceneType.KickToLogin then
			return
		end

		self.UnlockBlocks = {}
		self.UnlockBlocksNearBlock = {}
	end,
	InitIndoorConfig = function (self)
		self.IndoorConfigInfoByRaidId = setmetatable({}, {
			__index = function (t, k)
				local parentRaidId = gMapManager:GetParentRaidId(k)

				if not parentRaidId then
					return nil
				end

				return rawget(t, parentRaidId)
			end,
			__newindex = function (t, k, v)
				local parentRaidId = gMapManager:GetParentRaidId(k)

				if parentRaidId then
					rawset(t, parentRaidId, v)
				end
			end
		})

		for index = 0, IndoorConfig.count - 1 do
			local cfg = IndoorConfig.LoadAt(index)

			if cfg and cfg.SceneId == RaidConfig.WorldMap then
				self.IndoorConfigInfoByRaidId[cfg.SceneId] = cfg
			end
		end
	end,
	GetParentRaidId = function (self, raidId)
		local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

		if raidCfg and raidCfg.ParentRaidId == 0 then
			return raidCfg.ParentRaidId
		end

		return raidId
	end,
	GetParentAreaId = function (self, areaId)
		local raidId, indoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
		raidId = self:GetParentRaidId(raidId)

		return gMapAreaMgr:GetAreaId(raidId, indoorId)
	end,
	GetIndoorId = function (self)
		return self.IndoorId or 0
	end,
	SetUnlockBlockAndZones = function (self)
		gBlockMgr:NegativeSyncBlockInfo()

		self.UnlockBlocks = {}
		self.UnlockBlocksNearBlock = {}

		for j = 0, LTConfig.CollectionBlockConfig.count - 1 do
			local blockCfg = LTConfig.CollectionBlockConfig.LoadAt(j)

			table.insert(self.UnlockBlocks, blockCfg.Id)

			for p = 1, #blockCfg.AdjacentBlocks do
				if not table.contains(self.UnlockBlocksNearBlock, blockCfg.AdjacentBlocks[p]) then
					table.insert(self.UnlockBlocksNearBlock, blockCfg.AdjacentBlocks[p])
				end
			end
		end

		gMessageManager:SendMessage(gEventConstants.MAP_BLOCK_UPDATE)
		gMessageManager:SendMessage(gEventConstants.MAP_INFO_UPDATE)
	end,
	GmPrintBlockInfoPlayer = function (self)
		local playerPos = gMapSystem:GetCurPlayerLocalPosition()

		self:GmPrintBlockInfoXZ(playerPos.x, playerPos.z)
	end
}

M.GmPrintBlockInfoXZ = function(self, x, z)
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(RaidConfig.WorldMap, x, z)
	local blockCfg = blockId and CollectionBlockConfig.GetConfig(blockId)

	if blockCfg then
		print_notice("[GmPrintBlockInfoXZ]: blockId = " .. blockId .. ", name =" .. blockCfg.BlockName)
	else
		print_notice("[GmPrintBlockInfoXZ]: 没有对应的block")
	end
end

M.CheckSceneIndoorId = function(self)
	local parentRaidId = self.GetParentRaidId(self, gRaidDataManager.RaidId)

	if self.IndoorId ~= 0 and parentRaidId == RaidConfig.WorldMap and parentRaidId == RaidConfig.Chongxiao and self.IndoorConfigInfoByRaidId[gRaidDataManager.RaidId] then
		self.ChangeMapId(self, self.IndoorConfigInfoByRaidId[gRaidDataManager.RaidId].Id, true)
	end
end

M.SetMiniMapScale = function(self, scale, type)
	if type ~= nil or type > 0 or gMapScaleType.Max >= type then
		print_error("当前设置的小地图scale类型错误，scale类型请参考MapScaleType")
	end

	if self.miniMapScaleList[type] ~= scale then
		return
	end

	self.miniMapScaleList[type] = scale

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.PrintScaleInfo) then
		self:CacheScaleType()

		local logStr = "[MiniMapSetScale]: (" .. self._scaleType2ScaleTypeName[type] .. ", " .. (scale or "nil") .. "). AllScale:"
		logStr = logStr .. self:GetAllScaleTypeStr()

		print_notice(logStr)
	end

	gMessageManager:SendMessage(gEventConstants.MAP_SCALE_UPDATE_TO_MAP)
end

M.RemoveMiniMapScaleType = function(self, type)
	if self.miniMapScaleList[type] then
		self.miniMapScaleList[type] = nil

		if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.PrintScaleInfo) then
			self.CacheScaleType(self)

			local logStr = "[MiniMapRemoveScale]: (" .. self._scaleType2ScaleTypeName[type] .. "). AllScale:"
			logStr = logStr .. self.GetAllScaleTypeStr(self)

			print_notice(logStr)
		end
	else
		return
	end

	gMessageManager:SendMessage(gEventConstants.MAP_SCALE_UPDATE_TO_MAP)
end

M.GetAllScaleTypeStr = function(self)
	local logStr = "["
	local first = true

	for scaleType = 1, gMapScaleType.Max do
		local scale = self.miniMapScaleList[scaleType]

		if scale then
			if not first then
				logStr = logStr .. ", "
			end

			first = first and false
			logStr = logStr .. "(" .. self._scaleType2ScaleTypeName[scaleType] .. ":" .. scale .. ")"
		end
	end

	return logStr .. "]"
end

M.CacheScaleType = function(self)
	if self._scaleType2ScaleTypeName then
		return
	end

	self._scaleType2ScaleTypeName = {}

	for typeName, typeValue in pairs(gMapScaleType) do
		self._scaleType2ScaleTypeName[typeValue] = typeName
	end
end

M.GetCurrentMiniMapScale = function(self)
	if self.miniMapScaleList[gMapScaleType.Default] ~= nil then
		self.miniMapScaleList[gMapScaleType.Default] = GameConfig.MiniMapZoomRateDefault
	end

	local curShowType = gMapScaleType.Default

	for type, scale in pairs(self.miniMapScaleList) do
		if scale <= 0 then
			curShowType = math.max(curShowType, type)
		end
	end

	return self.miniMapScaleList[curShowType]
end

M.ChangeMapId = function(self, id, isSwitchScene)
	local toIndoorId = id or 0

	if self.IndoorId ~= toIndoorId then
		return
	end

	self.IndoorId = toIndoorId

	print_notice("当前触发的室内id为：" .. toIndoorId .. "   isSwitchScene：" .. tostring(isSwitchScene))

	local param = {
		toIndoorId = toIndoorId,
		isSwitchScene = isSwitchScene or false
	}

	gMessageManager:SendMessage(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP, param)
end

gMapManager = M
