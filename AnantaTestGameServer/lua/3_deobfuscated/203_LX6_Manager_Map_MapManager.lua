local CollectionBlockConfig = LTConfig.CollectionBlockConfig
local RaidConfig = LTConfig.RaidConfig
local GameConfig = LTConfig.GameConfig
local IndoorConfig = LTConfig.IndoorConfig
local M = {
	IndoorId = 0,
	RecordTooltipRewardOpen = true,
	ZoneCfgInfo = {},
	UnlockBlocksNearBlock = {},
	IndoorConfigInfoByRaidId = {},
	miniMapScaleList = {},
	TitleColor = {
		"ADADAD",
		"7395C8",
		"E59D31"
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
		gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, function (eventId, switchType)
			if switchType == gSwitchSceneType.NewScene or switchType == gSwitchSceneType.Reconnect then
				self:CheckSceneIndoorId()
			elseif switchType == gSwitchSceneType.SwitchFromWorldMap or switchType == gSwitchSceneType.Image then
				self:CheckSceneIndoorId()
			end

			self:SetUnlockBlockAndZones()
		end)
		gMessageManager:AddMessageListener(gEventConstants.MAP_SCALE_UPDATE, function (eventId, scale)
			if scale == 0 then
				self:RemoveMiniMapScaleType(gMapScaleType.Area)
			else
				self:SetMiniMapScale(scale, gMapScaleType.Area)
			end
		end)
		self:InitIndoorConfig()
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if switchType and gSwitchSceneType.Image < switchType then
			self:ChangeMapId(0, true)

			self.miniMapScaleList = {}
		end

		if switchType ~= gSwitchSceneType.KickToLogin then
			return
		end

		self.UnlockBlocks = {}
		self.UnlockBlocksNearBlock = {}
	end,
	InitIndoorConfig = function (self)
		self.IndoorConfigInfoByRaidId = {}

		for index = 0, IndoorConfig.count - 1 do
			local cfg = IndoorConfig.LoadAt(index)

			if cfg and cfg.SceneId ~= RaidConfig.WorldMap then
				self.IndoorConfigInfoByRaidId[cfg.SceneId] = cfg
			end
		end
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
		local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

		self:GmPrintBlockInfoXZ(playerPos.x, playerPos.z)
	end
}

function M:GmPrintBlockInfoXZ(x, z)
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(RaidConfig.WorldMap, x, z)
	local blockCfg = blockId and CollectionBlockConfig.GetConfig(blockId)

	if blockCfg then
		print_notice("[GmPrintBlockInfoXZ]: blockId = " .. blockId .. ", name =" .. blockCfg.BlockName)
	else
		print_notice("[GmPrintBlockInfoXZ]: 没有对应的block")
	end
end

function M:CheckSceneIndoorId()
	if self.IndoorId == 0 and gRaidDataManager.RaidId ~= RaidConfig.WorldMap and self.IndoorConfigInfoByRaidId[gRaidDataManager.RaidId] then
		self:ChangeMapId(self.IndoorConfigInfoByRaidId[gRaidDataManager.RaidId].Id, true)
	end
end

function M:SetMiniMapScale(scale, type)
	if type == nil or type <= 0 or gMapScaleType.Max < type then
		print_error("当前设置的小地图scale类型错误，scale类型请参考MapScaleType")
	end

	if self.miniMapScaleList[type] == scale then
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

function M:RemoveMiniMapScaleType(type)
	if self.miniMapScaleList[type] then
		self.miniMapScaleList[type] = nil

		if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.PrintScaleInfo) then
			self:CacheScaleType()

			local logStr = "[MiniMapRemoveScale]: (" .. self._scaleType2ScaleTypeName[type] .. "). AllScale:"
			logStr = logStr .. self:GetAllScaleTypeStr()

			print_notice(logStr)
		end
	else
		return
	end

	gMessageManager:SendMessage(gEventConstants.MAP_SCALE_UPDATE_TO_MAP)
end

function M:GetAllScaleTypeStr()
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

function M:CacheScaleType()
	if self._scaleType2ScaleTypeName then
		return
	end

	self._scaleType2ScaleTypeName = {}

	for typeName, typeValue in pairs(gMapScaleType) do
		self._scaleType2ScaleTypeName[typeValue] = typeName
	end
end

function M:GetCurrentMiniMapScale()
	if self.miniMapScaleList[gMapScaleType.Default] == nil then
		self.miniMapScaleList[gMapScaleType.Default] = GameConfig.MiniMapZoomRateDefault
	end

	local curShowType = gMapScaleType.Default

	for type, scale in pairs(self.miniMapScaleList) do
		if scale > 0 then
			curShowType = math.max(curShowType, type)
		end
	end

	return self.miniMapScaleList[curShowType]
end

function M:ChangeMapId(id, isSwitchScene)
	local toIndoorId = id or 0

	if self.IndoorId == toIndoorId then
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
