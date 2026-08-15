local GalleryConfig = LTConfig.LegendaryInvestigatorGalleryConfig
local LegendConfig = LTConfig.LegendaryInvestigatorConfig
local CountryConfig = LTConfig.CollectionCountryConfig
local MapBlockMgr = LX6.Gps.MapBlockMgr
MapSubSystem_Legend = DefClass("MapSubSystem_Legend", MapSubSystem_Legend, MapSubSystemBase)
local M = MapSubSystem_Legend

function M:OnLoadData()
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
		local raidId = LTConfig.CollectionCountryConfig.GetConfig(cfg.BelongCountry).RaidId
		local element = MapElement.CreateLegacy(EMapElementType.Legend, id, EMapSubSystemType.Legend, EMapViewMask.Legend, raidId, 0)

		self:SetupElement(element, cfg)

		local info = {
			uploaded = false,
			unlockTime = 0,
			unlock = false,
			element = element,
			cfgId = id,
			belongCountry = cfg.BelongCountry,
			raidId = raidId
		}

		element:SetVisible(info.unlock)

		self._id2ElementInfo[id] = info
	end

	self:OnGalleryInfoListDirty()
	self:RefreshAllGalleryInfo()
end

function M:GetAllDisasterListInfos()
	return self.allGalleryUIListInfos or {}
end

function M:GetLegendElement(cfgId)
	return self._id2ElementInfo[cfgId].element
end

function M:CheckGalleryUploaded(cfgId)
	local info = self._id2ElementInfo[cfgId]

	if info and info.uploaded then
		return true
	end

	return false
end

function M:UploadArchive(cfgId)
	local info = self._id2ElementInfo[cfgId]

	if info then
		gClientToGameDelegate:ArchiveInvestigateGallery(cfgId).Callback = function (err, data)
			self:OnUploadArchiveCb(err, cfgId)
		end
	end
end

function M:GetElementGpsId(cfgId)
	local element = self:GetLegendElement(cfgId)

	if element then
		return element.gpsId
	end

	print_error("@xiajingbo01 LegendInvestigator: GetElementGpsId cfgId:" .. cfgId .. " not exist")

	return 0
end

function M:GetBelongBlockId(cfgId)
	local info = self._id2ElementInfo[cfgId]

	if info then
		local pos = info.element:GetWorldPos()

		return MapBlockMgr.GetBlockIdXZ(info.raidId, pos.x, pos.z)
	end

	print_error("@xiajingbo01 LegendInvestigator: GetBelongBlockId cfgId:" .. cfgId .. " not exist")

	return -1
end

function M:GetUnlockTime(cfgId)
	local info = self._id2ElementInfo[cfgId]

	if info then
		return info.unlockTime
	end

	print_error("@xiajingbo01 LegendInvestigator: GetUnlockTime cfgId:" .. cfgId .. " not exist")

	return -1
end

function M:RefreshAllGalleryInfo()
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	gClientToGameDelegate:AskInvestigatorInfo().Callback = function (err, data)
		self:OnRefreshAllGalleryInfoCb(err, data, 0)
	end
end

function M:SyncGalleryUnlock(cfgId, unlock, galleryInfo)
	local info = self._id2ElementInfo[cfgId]

	if info then
		info.unlock = unlock

		info.element:SetVisible(unlock)

		local cfg = GalleryConfig.GetConfig(cfgId)

		if unlock then
			info.element:SetPosition(Vector3.New(galleryInfo.Pos.X, galleryInfo.Pos.Y, galleryInfo.Pos.Z))

			info.unlockTime = galleryInfo.UnlockTime
		end

		self:OnGalleryInfoListDirty()
	end
end

function M:OnRefreshAllGalleryInfoCb(err, data, attempt)
	if err ~= LTConfig.MessageConfig.Ok then
		if attempt < 3 then
			print_warn("LegendInvestigator AskGalleryInfo err:" .. gCS.Error.GetNameById(err) .. " in " .. attempt .. " attempt, retrying...")

			gClientToGameDelegate:AskInvestigatorInfo().Callback = function (err, data)
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
				if info.UnlockTime and info.UnlockTime > 0 then
					mapInfo.unlock = true
					mapInfo.unlockTime = info.UnlockTime
				end

				mapInfo.uploaded = info.IsArchived
				local cfg = GalleryConfig.GetConfig(info.GalleryId)

				mapInfo.element:SetPosition(Vector3.New(info.Pos.X, info.Pos.Y, info.Pos.Z))
				mapInfo.element:SetVisible(mapInfo.unlock)
			end
		end
	end

	self:OnGalleryInfoListDirty()
end

function M:OnUploadArchiveCb(err, cfgId)
	if err ~= LTConfig.MessageConfig.Ok then
		if err ~= LTConfig.MessageConfig.TimeOut then
			print_error("LegendInvestigator ArchiveGallery err:" .. gCS.Error.GetNameById(err))
		end

		return
	end

	local info = self._id2ElementInfo[cfgId]
	info.uploaded = true

	self:OnGalleryUploadedDirty(cfgId)
end

function M:OnGalleryInfoListDirty()
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
				if a.Unlock ~= b.Unlock then
					return a.Unlock
				end

				return tostring(a.Number) < tostring(b.Number)
			end)
		end
	end

	for i = 1, #LegendConfig.DisasterLevelText do
		if self.levelGalleryUIListInfos[i] then
			table.insert(self.allGalleryUIListInfos, {
				tIndex = 2,
				level = i
			})

			for city, infos in pairs(self.levelGalleryUIListInfos[i]) do
				if infos ~= nil then
					if table.count(infos) ~= 0 then
						table.insert(self.allGalleryUIListInfos, {
							tIndex = 0,
							cityName = CountryConfig.GetConfig(city).Name
						})

						for _, levelInfo in pairs(infos) do
							local info = {
								tIndex = 1,
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

	gMessageManager:SendMessage(gEventConstants.LEGENDMAP_LIST_UPDATE)
end

function M:OnGalleryUploadedDirty(cfgId)
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
			if listInfo.Id == cfgId then
				listInfo.Uploaded = info.uploaded

				break
			end
		end
	end

	if self.allGalleryUIListInfos then
		for _, listInfo in ipairs(self.allGalleryUIListInfos) do
			if listInfo.cfgId == cfgId then
				listInfo.isNew = not info.uploaded

				break
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.LEGENDMAP_LIST_UPDATE)
end

function M:SetupElement(element, cfg)
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

function M:GetSIconId(level)
	return LegendConfig.DisasterLevelIcon[level]
end

function M:GetShowType(level)
	return LegendConfig.DisasterLevelScaleType[level]
end

function M:GetThumbnailIconId()
	return LegendConfig.DisasterLevelThumbnailIcon
end

function M:SGetTooltipInfo(id, element)
	local legendId = element.userdata.legendId
	local cfg = GalleryConfig.GetConfig(legendId)
	local tooltipInfo = {
		type = EMapTooltipType.Legend,
		header = {
			imageId = cfg.ImageId
		},
		legendInfo = {
			legendId = legendId,
			uploaded = self:CheckGalleryUploaded(legendId),
			name = cfg.DisasterName,
			numberText = cfg.Number,
			level = cfg.DisasterLevel,
			blockId = self:GetBelongBlockId(legendId),
			unlockTime = self:GetUnlockTime(legendId),
			dropId = cfg.DropID,
			describe = cfg.Describe
		}
	}

	return tooltipInfo
end

return M
