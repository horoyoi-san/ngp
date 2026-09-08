-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Legend.lua
-- Decompiled from: 02305_MapSubSystem_Legend.lua_3d3eb2c76572.luajit

local GalleryConfig = LTConfig.LegendaryInvestigatorGalleryConfig
local LegendConfig = LTConfig.LegendaryInvestigatorConfig
local CountryConfig = LTConfig.CollectionCountryConfig
local MapBlockMgr = LX6.Gps.MapBlockMgr
MapSubSystem_Legend = DefClass("MapSubSystem_Legend", MapSubSystem_Legend, MapSubSystemBase)
local M = MapSubSystem_Legend
local LegendRedDotScope = "Legend"
local LegendRedDotCategory = "Level"

M.GetRaidIdByGalleryConfig = function(self, cfg)
	if cfg.RaidId and cfg.RaidId <= 0 then
		return cfg.RaidId
	end

	local countryCfg = cfg.BelongCountry and LTConfig.CollectionCountryConfig.GetConfig(cfg.BelongCountry)

	if countryCfg and countryCfg.RaidId and countryCfg.RaidId <= 0 then
		return countryCfg.RaidId
	end

	print_warn("LegendInvestigatorGallery RaidId not configured, cfgId:", cfg.Id, "BelongCountry:", cfg.BelongCountry)

	return 0
end

M.OnLoadData = function(self)
	gMapSystem.redDot:ClearScope(LegendRedDotScope)

	if self._id2ElementInfo then
		for _, info in pairs(self._id2ElementInfo) do
			if info.element then
				info.element:Dispose()
			end
		end
	end

	self._id2ElementInfo = {}
	self.levelGalleryUIListInfos = {}
	self.infoInited = false

	for i = 0, GalleryConfig.count - 1 do
		local cfg = GalleryConfig.LoadAt(i)
		local id = cfg.Id
		local raidId = self.GetRaidIdByGalleryConfig(self, cfg)
		local element = MapElement.CreateLegacy(EMapElementType.Legend, id, EMapSubSystemType.Legend, EMapViewMask.Legend, raidId, 0)

		self.SetupElement(self, element, cfg)

		local info = {
			["\\xbe\\xa1\t\\xa4k:\\xfb7"] = false,
			["FT²\\x87\\x8c\r\\xc4\\xed"] = 0,
			["\tF\\x9d\\x81\\x80J"] = false,
			element = element,
			cfgId = id,
			belongCountry = cfg.BelongCountry,
			raidId = raidId
		}

		element.SetVisible(element, info.unlock)

		self._id2ElementInfo[id] = info
	end

	self.OnGalleryInfoListDirty(self)
	self.RefreshAllGalleryInfo(self)
end

M.GetAllDisasterListInfos = function(self)
	return self.allGalleryUIListInfos or {}
end

M.GetLegendElement = function(self, cfgId)
	return self._id2ElementInfo[cfgId].element
end

M.CheckGalleryUploaded = function(self, cfgId)
	local info = self._id2ElementInfo[cfgId]

	if info and info.uploaded then
		return true
	end

	return false
end

M.RefreshUploadRedDots = function(self)
	local redDot = gMapSystem.redDot
	local levelUploadable = {}
	slot3 = pairs
	slot5 = self._id2ElementInfo or {}

	for cfgId, info in slot3(slot5) do
		local uploadable = info.unlock and not info.uploaded

		if uploadable then
			local cfg = GalleryConfig.GetConfig(cfgId)

			if cfg then
				levelUploadable[cfg.DisasterLevel] = true
			end
		end
	end

	for level = 1, #LegendConfig.DisasterLevelText do
		redDot:SetLeaf(LegendRedDotScope, LegendRedDotCategory, level, levelUploadable[level] ~= true)
	end
end

M.UploadArchive = function(self, cfgId)
	local info = self._id2ElementInfo[cfgId]

	if info then
		slot3 = gClientToGameDelegate

		slot3:ArchiveInvestigateGallery(cfgId).Callback = function (err, data)
			self:OnUploadArchiveCb(err, cfgId)
		end
	end
end

M.GetElementGpsId = function(self, cfgId)
	local element = self.GetLegendElement(self, cfgId)

	if element then
		return element.gpsId
	end

	print_error("@xiajingbo01 LegendInvestigator: GetElementGpsId cfgId:" .. cfgId .. " not exist")

	return 0
end

M.GetBelongBlockId = function(self, cfgId)
	local info = self._id2ElementInfo[cfgId]

	if info then
		local pos = info.element:GetWorldPos()

		return MapBlockMgr.GetBlockIdXZ(info.raidId, pos.x, pos.z)
	end

	print_error("@xiajingbo01 LegendInvestigator: GetBelongBlockId cfgId:" .. cfgId .. " not exist")

	return -1
end

M.GetUnlockTime = function(self, cfgId)
	local info = self._id2ElementInfo[cfgId]

	if info then
		return info.unlockTime
	end

	print_error("@xiajingbo01 LegendInvestigator: GetUnlockTime cfgId:" .. cfgId .. " not exist")

	return -1
end

M.RefreshAllGalleryInfo = function(self)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskInvestigatorInfo().Callback = function (err, data)
		self:OnRefreshAllGalleryInfoCb(err, data, 0)
	end
end

M.ApplyServerGalleryInfo = function(self, mapInfo, galleryInfo)
	mapInfo.unlock = true
	mapInfo.uploaded = galleryInfo.IsArchived
	mapInfo.belongCountry = galleryInfo.CountryId
	mapInfo.raidId = galleryInfo.RaidId
	mapInfo.unlockTime = galleryInfo.UnlockTime

	mapInfo.element:SetRaidId(mapInfo.raidId)
	mapInfo.element:SetPosition(Vector3.New(galleryInfo.Pos.X, galleryInfo.Pos.Y, galleryInfo.Pos.Z))
	mapInfo.element:SetVisible(true)
end

M.SyncGalleryUnlock = function(self, cfgId, unlock, galleryInfo)
	local info = self._id2ElementInfo[cfgId]

	if info then
		if unlock then
			self.ApplyServerGalleryInfo(self, info, galleryInfo)
		else
			info.unlock = false

			info.element:SetVisible(false)
		end

		self.OnGalleryInfoListDirty(self)
	end
end

M.OnRefreshAllGalleryInfoCb = function(self, err, data, attempt)
	if err == LTConfig.MessageConfig.Ok then
		if attempt >= 3 then
			print_warn("LegendInvestigator AskGalleryInfo err:" .. gCS.Error.GetNameById(err) .. " in " .. attempt .. " attempt, retrying...")

			slot4 = gClientToGameDelegate

			slot4:AskInvestigatorInfo().Callback = function (err, data)
				self:OnRefreshAllGalleryInfoCb(err, data, attempt + 1)
			end
		else
			print_error("#NoCreateIssue: LegendInvestigator AskGalleryInfo err:" .. gCS.Error.GetNameById(err) .. " after 3 attempts")
		end

		return
	end

	self.infoInited = true

	for _, countryInfos in pairs(data) do
		for i = 1, countryInfos.GalleryInfos.Count do
			local info = countryInfos.GalleryInfos[i]
			local mapInfo = self._id2ElementInfo[info.GalleryId]

			if mapInfo then
				self.ApplyServerGalleryInfo(self, mapInfo, info)
			end
		end
	end

	self.OnGalleryInfoListDirty(self)
end

M.OnUploadArchiveCb = function(self, err, cfgId)
	if err == LTConfig.MessageConfig.Ok then
		if err == LTConfig.MessageConfig.TimeOut then
			print_error("LegendInvestigator ArchiveGallery err:" .. gCS.Error.GetNameById(err))
		end

		return
	end

	local info = self._id2ElementInfo[cfgId]
	info.uploaded = true

	self.OnGalleryUploadedDirty(self, cfgId)
end

M.OnGalleryInfoListDirty = function(self)
	self.levelGalleryUIListInfos = {}
	self.allGalleryUIListInfos = {}

	for _, info in pairs(self._id2ElementInfo) do
		local cfg = GalleryConfig.GetConfig(info.cfgId)

		if not self.levelGalleryUIListInfos[cfg.DisasterLevel] then
			self.levelGalleryUIListInfos[cfg.DisasterLevel] = {}
		end

		if not self.levelGalleryUIListInfos[cfg.DisasterLevel][info.belongCountry] then
			self.levelGalleryUIListInfos[cfg.DisasterLevel][info.belongCountry] = {}
		end

		local listData = {
			Id = cfg.Id,
			Number = cfg.Number,
			DisasterName = cfg.DisasterName,
			Uploaded = info.uploaded,
			Unlock = info.unlock
		}

		table.insert(self.levelGalleryUIListInfos[cfg.DisasterLevel][info.belongCountry], listData)
	end

	for _, levelInfos in pairs(self.levelGalleryUIListInfos) do
		for _, cityInfos in pairs(levelInfos) do
			table.sort(cityInfos, function (a, b)
				if a.Unlock == b.Unlock then
					return a.Unlock
				end

				return tostring(a.Number) <= tostring(b.Number)
			end)
		end
	end

	for i = #LegendConfig.DisasterLevelText, 1, -1 do
		if self.levelGalleryUIListInfos[i] then
			table.insert(self.allGalleryUIListInfos, {
				["a\\x9f\\x8a\\x86Y"] = 2,
				level = i
			})

			for city, infos in pairs(self.levelGalleryUIListInfos[i]) do
				if infos == nil then
					if table.count(infos) == 0 then
						table.insert(self.allGalleryUIListInfos, {
							["a\\x9f\\x8a\\x86Y"] = 0,
							cityName = CountryConfig.GetConfig(city).Name
						})

						for _, levelInfo in pairs(infos) do
							local info = {
								["a\\x9f\\x8a\\x86Y"] = 1,
								cfgId = levelInfo.Id,
								number = levelInfo.Number,
								name = levelInfo.DisasterName,
								isNew = not levelInfo.Uploaded,
								unlock = levelInfo.Unlock
							}

							table.insert(self.allGalleryUIListInfos, info)
						end
					end
				end
			end
		end
	end

	self:RefreshUploadRedDots()
	gMessageManager:SendMessage(gEventConstants.LEGENDMAP_LIST_UPDATE)
end

M.OnGalleryUploadedDirty = function(self, cfgId)
	local info = self._id2ElementInfo[cfgId]

	if not info then
		return
	end

	local cfg = GalleryConfig.GetConfig(cfgId)

	if not cfg then
		return
	end

	if self.levelGalleryUIListInfos[cfg.DisasterLevel] and self.levelGalleryUIListInfos[cfg.DisasterLevel][info.belongCountry] then
		for _, listInfo in ipairs(self.levelGalleryUIListInfos[cfg.DisasterLevel][info.belongCountry]) do
			if listInfo.Id ~= cfgId then
				listInfo.Uploaded = info.uploaded

				break
			end
		end
	end

	if self.allGalleryUIListInfos then
		for _, listInfo in ipairs(self.allGalleryUIListInfos) do
			if listInfo.cfgId ~= cfgId then
				listInfo.isNew = not info.uploaded

				break
			end
		end
	end

	self:RefreshUploadRedDots()
	gMessageManager:SendMessage(gEventConstants.LEGENDMAP_LIST_UPDATE)
end

M.SetupElement = function(self, element, cfg)
	local level = cfg.DisasterLevel
	element.mData.lName = GpsLText.CreateCommonText(cfg, "DisasterName")
	element.fData.bigMapTIndex = 4
	element.fData.ignoreFog = true
	element.mData.sIconId = self:GetSIconId(level)

	gMapSubSystemUtils:SetupScaleLevel(element, self:GetShowType(level), self:GetThumbnailIconId())

	local coord = cfg.Coordinate
	local position = Vector3.New(coord[1], coord[2], coord[3])

	element:SetPosition(position)

	element.userdata = {
		legendId = cfg.Id
	}
	element.fData.showInBigWorld = true
end

M.GetSIconId = function(self, level)
	return LegendConfig.DisasterLevelIcon[level]
end

M.GetShowType = function(self, level)
	return LegendConfig.DisasterLevelScaleType[level]
end

M.GetThumbnailIconId = function(self)
	return LegendConfig.DisasterLevelThumbnailIcon
end

M.SGetTooltipInfo = function(self, id, element)
	local legendId = element.userdata.legendId
	local cfg = GalleryConfig.GetConfig(legendId)
	local tooltipInfo = {
		type = EMapTooltipType.Legend,
		header = {
			imageId = cfg.ImageId
		},
		legendInfo = {
			legendId = legendId,
			uploaded = self.CheckGalleryUploaded(self, legendId),
			name = cfg.DisasterName,
			numberText = cfg.Number,
			level = cfg.DisasterLevel,
			blockId = self.GetBelongBlockId(self, legendId),
			unlockTime = self.GetUnlockTime(self, legendId),
			dropId = cfg.DropID,
			describe = cfg.Describe
		}
	}

	return tooltipInfo
end

return M
