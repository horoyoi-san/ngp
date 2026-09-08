-- Original chunk: @Lua\LuaFiles\LX6\Manager\BaiKeArchiveManager.lua
-- Decompiled from: 00243_BaiKeArchiveManager.lua_21907bbe4eab.luajit

local WikiType = UX.Game.GalleryWikiType
local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local RedDotMgr = SGUI.RedDotMgr
local M = {
	["JT@fO?"] = false,
	notIncludeItem = {
		ConsumableConfig.RewardExp
	},
	brandIdToSuits = {},
	brandListData = {},
	CityPediaStatus = {
		["H'|_"] = 2,
		["\\x9e\\xbf\t\\xa4i5\\xfb7"] = 1,
		["T-s^"] = 0
	},
	prevItemsSort = {},
	GetPrevItemsSort = function (self, index)
		local indexStr = tostring(index)

		if self.prevItemsSort[indexStr] ~= nil then
			self.prevItemsSort[indexStr] = {
				["B\\xbc\\xa6\\xaa\\xa4"] = true,
				["n;m^"] = 1
			}
		end

		return self.prevItemsSort[indexStr]
	end,
	OnInit = function (self)
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self.InitSuitData(self)
	end,
	OnBeforeSwitchScene = function (self, switchType)
		self.isLoading = true
	end,
	OnAfterSwitchScene = function (self, switchType)
		self.isLoading = false
	end,
	GetItemTabIndexByCfg = function (self, cfg)
		local typeCfg = ConsumableTypeConfig.GetConfig(cfg.SubType)

		return typeCfg.ItemTab
	end,
	GetAllRedCount = function (self, callBack)
		local totalCount = self.GetPetRedCount(self)

		self.GetAllWikiRedCount(self, function (err, count)
			totalCount = totalCount + count

			callBack(err, totalCount)
		end)
	end,
	GetAllWikiRedCount = function (self, callBack)
		local count = 0

		self.AskGalleryInfo(self, function (err, info)
			if info then
				for type, value in pairs(info) do
					local galleryInfo = value.GalleryInfo

					for key, value in pairs(galleryInfo) do
						if value.State ~= UX.Game.GalleryState.New then
							if type ~= WikiType.Item then
								local cfg = ConsumableConfig.GetConfig(key)

								if cfg and self:GetItemTabIndexByCfg(cfg) then
									count = count + 1
								end
							else
								count = count + 1
							end
						end
					end
				end
			end

			callBack(err, count)
		end)
	end,
	GetAllWikiUnlockCount = function (self, callBack)
		local count = 0

		self.AskGalleryInfo(self, function (err, info)
			if info then
				for type, value in pairs(info) do
					if type ~= WikiType.Item then
						for key, value in pairs(value.GalleryInfo) do
							local cfg = ConsumableConfig.GetConfig(key)

							if cfg and self:GetItemTabIndexByCfg(cfg) then
								count = count + 1
							end
						end
					else
						local galleryInfo = value.GalleryInfo
						count = count + table.count(galleryInfo)
					end
				end
			end

			callBack(err, count)
		end)
	end,
	GetAllWikiUnlockCount = function (self, callBack)
		local count = 0

		self.AskGalleryInfo(self, function (err, info)
			if info then
				for type, value in pairs(info) do
					if self:IsUnlockByWikiType(type) then
						if type ~= WikiType.Item then
							for key, value in pairs(value.GalleryInfo) do
								local cfg = ConsumableConfig.GetConfig(key)

								if cfg and self:GetItemTabIndexByCfg(cfg) then
									count = count + 1
								end
							end
						else
							local galleryInfo = value.GalleryInfo
							count = count + table.count(galleryInfo)
						end
					end
				end
			end

			callBack(err, count)
		end)
	end,
	IsUnlock = function (self, galleryId, callBack)
		self.AskGalleryInfo(self, function (err, info)
			if info then
				local isUnlock = false

				for type, value in pairs(info) do
					for key, value in pairs(value.GalleryInfo) do
						if key ~= galleryId then
							isUnlock = true

							break
						end
					end

					if isUnlock then
						break
					end
				end

				callBack(isUnlock)

				return
			end

			callBack(false)
		end)
	end,
	GetPetRedCount = function (self)
		local count = 0
		local petInfos = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos

		for key, petInfo in pairs(petInfos) do
			if petInfo.Unlock and not petInfo.Interacted then
				count = count + 1
			end
		end

		return count
	end,
	IsUnlockByWikiType = function (self, wikiType)
		local baikeEntranceList = LTConfig.GalleryConfig.BaikeEntrance

		for i = 1, #baikeEntranceList do
			local info = baikeEntranceList[i]

			if info.panelId ~= self.GetPanelIdByWikeType(self, wikiType) then
				return true
			end
		end

		return false
	end,
	GetPanelIdByWikeType = function (self, wikiType)
		return 0
	end,
	AskGalleryInfo = function (self, cb)
		if self.isLoading then
			if cb then
				cb()
			end

			return
		end

		slot2 = gClientToGameDelegate

		slot2:AskGalleryInfo().Callback = function (err, info)
			if cb then
				cb(err, info)
			end
		end
	end,
	BaikeEntranceType = {
		["pU±\\x81\\xac\r\\xc6\\xe6"] = 3,
		["\\xbemr"] = 2,
		S6xV = 1
	},
	CityPediaSourceType = {
		["\\xff\\xda+\\xff"] = "\\xff\\xda+\\xff",
		["J.|B"] = "J.|B",
		["\\xef\\xde(\\xf4"] = "\\xef\\xde(\\xf4",
		["`\\xa1\\xb4\\xa6\\xb3"] = "`\\xa1\\xb4\\xa6\\xb3",
		["pU\\xc0\\xae\\x91\\xb9\\xc5\\xed"] = "pU\\xc0\\xae\\x91\\xb9\\xc5\\xed",
		["\\xbemr"] = "\\xbemr",
		["\\+nS"] = "\\+nS",
		["\\xff\\xda\t+\\xff"] = "\\xff\\xda\t+\\xff"
	}
}

local pickValue = function(a, b)
	if a ~= nil or a ~= "" or a ~= 0 then
		return b
	end

	return a
end

M.GetCityPediaSourceType = function(self, cityPediaCfg)
	if (cityPediaCfg.PetId or 0) <= 0 then
		return self.CityPediaSourceType.Pet
	elseif (cityPediaCfg.FactionId or 0) <= 0 then
		return self.CityPediaSourceType.Faction
	elseif (cityPediaCfg.MovieId or 0) <= 0 then
		return self.CityPediaSourceType.Movie
	elseif (cityPediaCfg.ConsumableId or 0) <= 0 then
		return self.CityPediaSourceType.Consumable
	elseif (cityPediaCfg.FashionId or 0) <= 0 then
		return self.CityPediaSourceType.Fashion
	elseif (cityPediaCfg.VehicleId or 0) <= 0 then
		return self.CityPediaSourceType.Vehicle
	elseif (cityPediaCfg.FishId or 0) <= 0 then
		return self.CityPediaSourceType.Fish
	end

	return self.CityPediaSourceType.Play
end

M.GenCityPediaItem = function(self, cityPediaCfg)
	if not cityPediaCfg then
		return nil
	end

	local sourceType = self:GetCityPediaSourceType(cityPediaCfg)
	local itemData = {
		["\\xea\\x95\\xe58\\xeb\\xed\\x8dٛ0-"] = 0,
		["\\xd8\\xdc\n\r\\xf5"] = 0,
		["\\xc8\\xce0\\xe8"] = 0,
		id = cityPediaCfg.Id,
		type = sourceType,
		name = cityPediaCfg.Name or "",
		story = cityPediaCfg.Story or "",
		effectDesc = cityPediaCfg.Des or "",
		image = cityPediaCfg.Image or 0,
		iconId = cityPediaCfg.ImageMini or 0,
		isDisposition = cityPediaCfg.IsDisposition or false,
		isInfluence = cityPediaCfg.IsInfluence or false,
		petId = cityPediaCfg.PetId or 0,
		factionId = cityPediaCfg.FactionId or 0,
		movieId = cityPediaCfg.MovieId or 0,
		consumableId = cityPediaCfg.ConsumableId or 0,
		fashionId = cityPediaCfg.FashionId or 0,
		vehicleId = cityPediaCfg.VehicleId or 0,
		cityPediaCfg = cityPediaCfg,
		popupIconId = cityPediaCfg.ImagePopup or 0,
		popupName = cityPediaCfg.Name or ""
	}

	if sourceType ~= self.CityPediaSourceType.Pet then
		local agentCfg = LTConfig.AgentConfig.GetConfig(cityPediaCfg.PetId)

		if agentCfg then
			itemData.sourceCfg = agentCfg
			itemData.agentId = cityPediaCfg.PetId or 0
			itemData.name = pickValue(agentCfg.Name, cityPediaCfg.Name) or ""
			itemData.popupName = pickValue(agentCfg.Name, cityPediaCfg.Name) or ""
			itemData.image = cityPediaCfg.Image or 0
			local gameplayCfg = agentCfg.AnimalGamePlay and LTConfig.AnimalGameplayConfig.GetConfig(agentCfg.AnimalGamePlay)

			if gameplayCfg then
				itemData.story = pickValue(gameplayCfg.GalleryTxt, cityPediaCfg.Story) or ""
				itemData.iconId = pickValue(gameplayCfg.SImage, cityPediaCfg.Image) or 0
				itemData.popupIconId = pickValue(gameplayCfg.SImage, cityPediaCfg.Image) or 0
			else
				itemData.story = cityPediaCfg.Story or ""
				itemData.iconId = cityPediaCfg.Image or 0
				itemData.popupIconId = cityPediaCfg.Image or 0
			end
		else
			print_error("[BaiKe] 取不到生物数据, PetId(=AgentId) =", cityPediaCfg.PetId)
		end
	elseif sourceType ~= self.CityPediaSourceType.Faction then
		local factionCfg = LTConfig.FactionConfig.GetConfig(cityPediaCfg.FactionId)

		if factionCfg then
			itemData.sourceCfg = factionCfg
			itemData.name = pickValue(cityPediaCfg.Name, factionCfg.name) or ""
			itemData.story = cityPediaCfg.Story or ""
			itemData.isDisposition = cityPediaCfg.IsDisposition or false
			itemData.isInfluence = cityPediaCfg.IsInfluence or false
			itemData.showAsInfluence = itemData.isInfluence and not itemData.isDisposition
			local image = cityPediaCfg.Image

			if (not image or image ~= 0) and itemData.isInfluence then
				image = factionCfg.GangMapInformationPic
			end

			itemData.image = image or 0
			itemData.iconId = cityPediaCfg.ImageMini or 0

			self:RefreshFactionDispositionFields(itemData)

			itemData.popupIconId = cityPediaCfg.ImagePopup or 0
			itemData.popupName = cityPediaCfg.Name or ""
		else
			print_error("[BaiKe] 取不到势力数据, FactionId =", cityPediaCfg.FactionId)
		end
	elseif sourceType ~= self.CityPediaSourceType.Movie then
		local movieCfg = LTConfig.CinemaMovieConfig.GetConfig(cityPediaCfg.MovieId)

		if movieCfg then
			itemData.sourceCfg = movieCfg
			itemData.name = pickValue(movieCfg.Name, cityPediaCfg.Name) or ""
			itemData.story = pickValue(movieCfg.Description, cityPediaCfg.Story) or ""
			itemData.image = cityPediaCfg.Image or 0
			itemData.iconId = pickValue(movieCfg.PosterL, cityPediaCfg.ImageMini) or 0
			itemData.movieImageType = cityPediaCfg.MovieImageType or 0
			itemData.popupIconId = cityPediaCfg.ImagePopup or 0
			itemData.popupName = pickValue(movieCfg.Name, cityPediaCfg.Name) or ""
		else
			print_error("[BaiKe] 取不到电影数据, MovieId =", cityPediaCfg.MovieId)
		end
	elseif sourceType ~= self.CityPediaSourceType.Consumable then
		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(cityPediaCfg.ConsumableId)

		if consumableCfg then
			itemData.sourceCfg = consumableCfg
			itemData.name = pickValue(consumableCfg.Name, cityPediaCfg.Name) or ""
			itemData.story = pickValue(consumableCfg.Description, cityPediaCfg.Story) or ""
			itemData.effectDesc = pickValue(consumableCfg.ShortDescription, cityPediaCfg.Des) or ""
			itemData.quality = consumableCfg.Quality or 0
			itemData.image = pickValue(consumableCfg.SItemIconId, cityPediaCfg.Image) or 0
			itemData.iconId = pickValue(consumableCfg.SItemIconId, cityPediaCfg.ImageMini) or 0
			itemData.popupIconId = pickValue(consumableCfg.SItemIconId, cityPediaCfg.ImagePopup) or 0
			itemData.popupName = pickValue(consumableCfg.Name, cityPediaCfg.Name) or ""
		else
			print_error("[BaiKe] 取不到道具数据, ConsumableId =", cityPediaCfg.ConsumableId)
		end
	elseif sourceType ~= self.CityPediaSourceType.Fashion then
		local fashionCfg = LTConfig.FashionConfig.GetConfig(cityPediaCfg.FashionId)

		if fashionCfg then
			itemData.sourceCfg = fashionCfg
			itemData.name = pickValue(fashionCfg.Name, cityPediaCfg.Name) or ""
			itemData.iconId = cityPediaCfg.ImageMini or 0
			itemData.image = cityPediaCfg.Image or 0
		else
			print_error("[BaiKe] 取不到时装数据, FashionId =", cityPediaCfg.FashionId)
		end
	elseif sourceType ~= self.CityPediaSourceType.Vehicle then
		local vehicleCfg = LTConfig.VehicleConfig.GetConfig(cityPediaCfg.VehicleId)

		if vehicleCfg then
			itemData.sourceCfg = vehicleCfg
			itemData.name = pickValue(vehicleCfg.VehicleName, cityPediaCfg.Name) or ""
			itemData.iconId = pickValue(vehicleCfg.SVehicleIconId, cityPediaCfg.ImageMini) or 0
			itemData.image = pickValue(vehicleCfg.SVehicleIconId, cityPediaCfg.Image) or 0
		else
			print_error("[BaiKe] 取不到载具数据, VehicleId =", cityPediaCfg.VehicleId)
		end
	elseif sourceType ~= self.CityPediaSourceType.Fish then
		local fishCfg = LTConfig.FishingFishConfig.GetConfig(cityPediaCfg.FishId)

		if fishCfg then
			itemData.sourceCfg = fishCfg
			itemData.name = pickValue(fishCfg.Name, cityPediaCfg.Name) or ""
			itemData.story = pickValue(fishCfg.Description, cityPediaCfg.Story) or ""
			itemData.iconId = pickValue(fishCfg.IconRes, cityPediaCfg.ImageMini) or 0
			itemData.image = pickValue(fishCfg.IconRes, cityPediaCfg.Image) or 0
			itemData.popupIconId = pickValue(fishCfg.IconRes, cityPediaCfg.ImagePopup) or 0
			itemData.popupName = pickValue(fishCfg.Name, cityPediaCfg.Name) or ""
		else
			print_error("[BaiKe] 取不到鱼数据, FishId =", cityPediaCfg.FishId)
		end
	end

	return itemData
end

M.InitCityPediaItemData = function(self)
	if self.cityPediaItemCache then
		return self.cityPediaItemCache
	end

	local cache = {}
	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)

		if cityPediaCfg then
			local itemData = self.GenCityPediaItem(self, cityPediaCfg)

			if itemData then
				cache[cityPediaCfg.Id] = itemData
			end
		end
	end

	self.cityPediaItemCache = cache

	return cache
end

M.RefreshFactionDispositionFields = function(self, itemData)
	if not itemData or itemData.type == self.CityPediaSourceType.Faction then
		return
	end

	local factionInfo = gClientUtils.GetFactionInfo(itemData.factionId)

	if itemData.isDisposition then
		local curLevel = factionInfo and factionInfo.DispositionLevel or 1
		local levelCfg = LTConfig.FactionDispositionConfig.GetConfig(curLevel)
		itemData.attitudeName = levelCfg and levelCfg.name or ""
		itemData.attitudeIconId = levelCfg and levelCfg.DispositionIcon or 0
		local curValue = factionInfo and levelCfg and factionInfo.Disposition - levelCfg.DispositionValue or 0
		local nextLevelCfg = LTConfig.FactionDispositionConfig.GetConfig(curLevel + 1)

		if nextLevelCfg and levelCfg then
			local maxValue = nextLevelCfg.DispositionValue - levelCfg.DispositionValue
			itemData.dispositionProgress = string.format("%d/%d", curValue, maxValue)
		else
			itemData.dispositionProgress = string.format("%d/-", curValue)
		end
	end

	if itemData.isInfluence then
		itemData.influencePercent = factionInfo and factionInfo.Influence or 0
	end
end

M.GetCityPediaItem = function(self, id)
	local cache = self.InitCityPediaItemData(self)
	local itemData = cache[id]

	if not itemData then
		local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
		itemData = self.GenCityPediaItem(self, cityPediaCfg)

		if itemData then
			cache[id] = itemData
		end
	end

	self.RefreshFactionDispositionFields(self, itemData)

	return itemData
end

M.ClearCityPediaItemCache = function(self)
	self.cityPediaItemCache = nil
end

M.GetCityPediaCreditInfo = function()
	return gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CreditInfo
end

M.GetCityPediaCredit = function()
	local creditInfo = M.GetCityPediaCreditInfo()

	if not creditInfo then
		return 0
	end

	if creditInfo.Credit == nil then
		return creditInfo.Credit
	end

	local total = 0

	if creditInfo.CreditByType then
		for _, v in pairs(creditInfo.CreditByType) do
			total = total + (v or 0)
		end
	end

	return total
end

M.GetCityPediaCreditLevel = function()
	local creditInfo = M.GetCityPediaCreditInfo()

	return creditInfo and creditInfo.Level or 0
end

M.GetClaimedRewardLevels = function()
	local creditInfo = M.GetCityPediaCreditInfo()

	return creditInfo and creditInfo.ClaimedLevelRewards or {}
end

M.CheckRewardClaimed = function(level)
	local claimedLevels = M.GetClaimedRewardLevels()

	if claimedLevels[level] then
		return true
	end

	return false
end

M.ClaimCityPediaLevelReward = function(level, callback)
	slot2 = gClientToGameDelegate

	slot2:ClaimCityPediaLevelReward(level).Callback = function (errId)
		if errId == 0 then
			if callback then
				callback(false, errId)
			end

			return
		end

		local claimedLevels = M.GetClaimedRewardLevels()
		claimedLevels[level] = true

		M.RefreshBaikePhoneAppRedDot()
		gMessageManager:SendMessage(gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE)

		if callback then
			callback(true, 0)
		end
	end
end

M.CheckCityPediaItemHasUnlocked = function(id)
	local cityPediaStatusDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPediaStatusDict
	local status = cityPediaStatusDict[id] or M.CityPediaStatus.None

	return bit.band(status, M.CityPediaStatus.Unlocked) == 0
end

M.GetFishRecordInfo = function(fishConfigId)
	if not fishConfigId or fishConfigId ~= 0 then
		return nil
	end

	local fishRecordDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.FishRecordDict

	return fishRecordDict and fishRecordDict[fishConfigId] or nil
end

M.OnSyncFishRecordUpdate = function(fishConfigId, record)
	if not fishConfigId or fishConfigId ~= 0 or not record then
		return
	end

	local cityPediaInfos = gPlayerManager.infoMinor.bindData.playerCityPediaInfos

	if not cityPediaInfos.FishRecordDict then
		cityPediaInfos.FishRecordDict = {}
	end

	cityPediaInfos.FishRecordDict[fishConfigId] = record
end

M.OnSyncNewCityPediaInfo = function(cityPediaId)
	local cityPediaStatusDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPediaStatusDict
	local oldStatus = cityPediaStatusDict[cityPediaId] or M.CityPediaStatus.None

	if bit.band(oldStatus, M.CityPediaStatus.Unlocked) == 0 then
		return
	end

	cityPediaStatusDict[cityPediaId] = bit.bor(oldStatus, M.CityPediaStatus.Unlocked)
	local appCanShow = gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.BaiKeId)

	if appCanShow then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.CityPediaUnlocked, {
			id = cityPediaId
		})
	end
end

M.CheckCityPediaFirstClassHasRedDot = function(cityPediaFirstClassId)
	local cityPediaIdList = M.GetFirstClassCityPediaIdList(cityPediaFirstClassId)

	for _, cityPediaId in ipairs(cityPediaIdList) do
		if M.CheckCityPediaItemHasRedDot(cityPediaId) then
			return true
		end
	end
end

M.CheckCityPediaSecondClassHasRedDot = function(cityPediaSecondClassId)
	local cityPediaIdList = M.GetSecondClassCityPediaIdList(cityPediaSecondClassId)

	for _, cityPediaId in ipairs(cityPediaIdList) do
		if M.CheckCityPediaItemHasRedDot(cityPediaId) then
			return true
		end
	end
end

M.GetFirstClassCityPediaIdList = function(cityPediaFirstClassId)
	local cityPediaIdList = {}
	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)
		local cityPediaSecondClassId = cityPediaCfg.Class
		local cityPediaSecondCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaSecondClassId)

		if cityPediaSecondCfg and cityPediaSecondCfg.FatherId ~= cityPediaFirstClassId then
			table.insert(cityPediaIdList, cityPediaCfg.Id)
		end
	end

	return cityPediaIdList
end

M.GetSecondClassCityPediaIdList = function(cityPediaSecondClassId)
	local cityPediaIdList = {}
	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)

		if cityPediaCfg.Class ~= cityPediaSecondClassId then
			table.insert(cityPediaIdList, cityPediaCfg.Id)
		end
	end

	return cityPediaIdList
end

M.GetCityPediaUnlockTipText = function(id)
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local tip = cityPediaCfg and cityPediaCfg.UnlockTipText

	if not string.is_null_or_empty(tip) then
		return tip
	end

	local secondClassId = cityPediaCfg and cityPediaCfg.Class
	local secondCfg = secondClassId and LTConfig.CityPediaSecondClassConfig.GetConfig(secondClassId)
	tip = secondCfg and secondCfg.UnlockTipText

	if not string.is_null_or_empty(tip) then
		return tip
	end

	local firstCfg = secondCfg and LTConfig.CityPediaFirstClassConfig.GetConfig(secondCfg.FatherId)
	tip = firstCfg and firstCfg.UnlockTipText

	if not string.is_null_or_empty(tip) then
		return tip
	end

	return LTConfig.CityPediaConfig.DefaultUnlockTipText or ""
end

M.CheckCityPediaItemHasRedDot = function(id)
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local cityPediaSecondClassId = cityPediaCfg.Class
	local cityPediaSecondCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaSecondClassId)
	local cityPediaFirstClassId = cityPediaSecondCfg.FatherId

	if not M.CheckCityPediaFisrtClassHasUnlocked(cityPediaFirstClassId) then
		return false
	end

	if not M.CheckCityPediaSecondClassHasUnlocked(cityPediaSecondClassId) then
		return false
	end

	if not M.CheckCityPediaItemHasUnlocked(cityPediaCfg.Id) then
		return false
	end

	local cityPediaStatusDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPediaStatusDict
	local status = cityPediaStatusDict[id] or M.CityPediaStatus.None

	return bit.band(status, M.CityPediaStatus.Unlocked) == 0 and bit.band(status, M.CityPediaStatus.Read) ~= 0
end

M.SetCityPediaItemHasRead = function(id)
	local cityPediaStatusDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPediaStatusDict
	local status = cityPediaStatusDict[id] or M.CityPediaStatus.None
	cityPediaStatusDict[id] = bit.bor(status, M.CityPediaStatus.Read)

	gClientToGameDelegate:AskReadCityPedia(id).Callback = function ()
	end

	local redDotKey = M.GetCityPediaRedDotKey(id)

	SGUI.RedDotMgr.LuaSetRedDot(false, redDotKey)

	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local cityPediaSecondClassId = cityPediaCfg.Class
	local cityPediaSecondCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaSecondClassId)
	local cityPediaFirstClassId = cityPediaSecondCfg.FatherId
	local secondClassHasRedDot = M.CheckCityPediaSecondClassHasRedDot(cityPediaSecondClassId)
	local secondClassRedDotKey = M.GetCityPediaSecondClassRedDotKey(cityPediaSecondClassId)

	SGUI.RedDotMgr.LuaSetRedDot(secondClassHasRedDot, secondClassRedDotKey)

	local fisrtClassHasRedDot = M.CheckCityPediaFirstClassHasRedDot(cityPediaFirstClassId)
	local firstClassRedDotKey = M.GetCityPediaFirstClassRedDotKey(cityPediaFirstClassId)

	SGUI.RedDotMgr.LuaSetRedDot(fisrtClassHasRedDot, firstClassRedDotKey)
	gMessageManager:SendMessage(gEventConstants.ON_BAIKE_ITEM_HAS_READ)
end

M.MAX_BATCH_READ_SIZE = 30

M.BatchSetCityPediaItemsHasRead = function(ids)
	if not ids or #ids ~= 0 then
		return
	end

	local cityPediaStatusDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPediaStatusDict
	local realIds = {}
	local affectedSecondClass = {}
	local affectedFirstClass = {}

	for _, id in ipairs(ids) do
		local status = cityPediaStatusDict[id] or M.CityPediaStatus.None

		if bit.band(status, M.CityPediaStatus.Unlocked) == 0 and bit.band(status, M.CityPediaStatus.Read) ~= 0 then
			cityPediaStatusDict[id] = bit.bor(status, M.CityPediaStatus.Read)

			SGUI.RedDotMgr.LuaSetRedDot(false, M.GetCityPediaRedDotKey(id))
			table.insert(realIds, id)

			local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)

			if cityPediaCfg then
				local secondClassId = cityPediaCfg.Class
				local secondCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(secondClassId)

				if secondClassId then
					affectedSecondClass[secondClassId] = true
				end

				if secondCfg and secondCfg.FatherId then
					affectedFirstClass[secondCfg.FatherId] = true
				end
			end
		end
	end

	if #realIds ~= 0 then
		return
	end

	local chunkSize = M.MAX_BATCH_READ_SIZE
	local total = #realIds

	for from = 1, total, chunkSize do
		local chunk = {}
		local to = math.min(from + chunkSize - 1, total)

		for i = from, to do
			table.insert(chunk, realIds[i])
		end

		slot13 = gClientToGameDelegate

		slot13:AskReadCityPediaBatch(chunk).Callback = function (err)
			if err and err == 0 then
				print_error("[BaiKe] BatchSetCityPediaItemsHasRead chunk failed:", err, "from=", from, "to=", to)
			end
		end
	end

	for secondClassId in pairs(affectedSecondClass) do
		local hasRedDot = M.CheckCityPediaSecondClassHasRedDot(secondClassId)

		SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, M.GetCityPediaSecondClassRedDotKey(secondClassId))
	end

	for firstClassId in pairs(affectedFirstClass) do
		local hasRedDot = M.CheckCityPediaFirstClassHasRedDot(firstClassId)

		SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, M.GetCityPediaFirstClassRedDotKey(firstClassId))
	end

	gMessageManager:SendMessage(gEventConstants.ON_BAIKE_ITEM_HAS_READ)
end

M.GetCityPediaFisrtClassRedDotCount = function(id)
	local cityPediaIdList = M.GetFirstClassCityPediaIdList(id)
	local count = 0

	for _, cityPediaId in ipairs(cityPediaIdList) do
		if M.CheckCityPediaItemHasRedDot(cityPediaId) then
			count = count + 1
		end
	end

	return count
end

M.GetCityPediaFirstClassRedDotKey = function(id)
	return ("BaiKeCityPediaFisrtClassRedDot:%d"):format(id)
end

M.GetCityPediaSecondClassRedDotKey = function(id)
	return ("BaiKeCityPediaSecondClassRedDot:%d"):format(id)
end

M.GetCityPediaRedDotKey = function(id)
	return ("BaiKeCityPediaRedDot:%d"):format(id)
end

M.GetPlayFashionPanelRedDotKey = function()
	return "BaikePlayFashionPanelRedDot"
end

M.CheckPlayFashionPanelHasRedDot = function()
	return false

	local currentCredit = M.GetCityPediaCredit()
	local count = LTConfig.CityPediaCollectionLevelConfig.count

	for i = 0, count - 1 do
		local levelCfg = LTConfig.CityPediaCollectionLevelConfig.LoadAt(i)

		if levelCfg then
			local isClaimed = M.CheckRewardClaimed(levelCfg.Id)
			local canClaim = levelCfg.value < currentCredit and not isClaimed

			if canClaim then
				return true
			end
		end
	end

	return false
end

M.GetPlayFashionPanelRedDotCount = function()
	local currentCredit = M.GetCityPediaCredit()
	local count = LTConfig.CityPediaCollectionLevelConfig.count
	local rewardCount = 0

	for i = 0, count - 1 do
		local levelCfg = LTConfig.CityPediaCollectionLevelConfig.LoadAt(i)

		if levelCfg then
			local isClaimed = M.CheckRewardClaimed(levelCfg.Id)
			local canClaim = levelCfg.value < currentCredit and not isClaimed

			if canClaim then
				rewardCount = rewardCount + 1
			end
		end
	end

	return rewardCount
end

M.RefreshBaikePhoneAppRedDot = function()
	local hasRedDot = M.CheckPlayFashionPanelHasRedDot()

	RedDotMgr.LuaSetRedDot(hasRedDot, "BaikePhoneApp")
end

M.CheckCityPediaFisrtClassHasUnlocked = function(cityPediaFisrtClassId)
	local config = LTConfig.CityPediaFirstClassConfig.GetConfig(cityPediaFisrtClassId)

	return config and gEventConditionUtils.CheckHasUnlocked(config, UX.Game.EventConditionImplModule.CityPediaFirstClass)
end

M.CheckCityPediaSecondClassHasUnlocked = function(cityPediaSecondClassId)
	local config = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaSecondClassId)

	return config and gEventConditionUtils.CheckHasUnlocked(config, UX.Game.EventConditionImplModule.CityPediaSecondClass)
end

M.GetCityPediaFisrtClassPorgress = function(cityPediaFisrtClassId)
	if M.CheckCityPediaFisrtClassHasUnlocked(cityPediaFisrtClassId) then
		local count = LTConfig.CityPediaConfig.count
		local current = 0
		local total = 0

		for i = 0, count - 1 do
			local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)
			local cityPediaSecondClassId = cityPediaCfg.Class
			local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaSecondClassId)

			if cityPediaSecondClassCfg and cityPediaSecondClassCfg.FatherId ~= cityPediaFisrtClassId then
				if M.CheckCityPediaItemHasUnlocked(cityPediaCfg.Id) then
					current = current + 1
				end

				total = total + 1
			end
		end

		return current, total
	else
		return 0, 0
	end
end

M.CalculateFashionScore = function(fashionId)
	local fashionCfg = LTConfig.FashionConfig.GetConfig(fashionId)

	if fashionCfg and fashionCfg.CollectionScore then
		return fashionCfg.CollectionScore
	end

	return 0
end

M.CalculateVehicleScore = function(vehicleId)
	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)

	if vehicleCfg and vehicleCfg.CollectionScore then
		return vehicleCfg.CollectionScore
	end

	return 0
end

M.CalculateBrandOwnedFashionScore = function(brandId)
	local ownedScore = 0
	local totalScore = 0
	local ownedCount = 0
	local totalCount = 0
	local suitIds = M.brandIdToSuits[brandId] or {}
	local processedFashionIds = {}

	for _, suitId in ipairs(suitIds) do
		local suitCfg = LTConfig.FashionSuitConfig.GetConfig(suitId)

		if suitCfg and suitCfg.FashionIdList then
			for _, fashionId in ipairs(suitCfg.FashionIdList) do
				if not processedFashionIds[fashionId] then
					processedFashionIds[fashionId] = true
					local score = M.CalculateFashionScore(fashionId)
					totalScore = totalScore + score
					totalCount = totalCount + 1

					if gDressManager:IsFashionHad(fashionId) then
						ownedScore = ownedScore + score
						ownedCount = ownedCount + 1
					end
				end
			end
		end
	end

	return ownedScore, totalScore, ownedCount, totalCount
end

M.EventHandler = {
	[gEventConstants.LOADING_FINISHED] = function (eventId, switchType)
		M:OnAfterSwitchScene(switchType)
	end,
	[gEventConstants.LANGUAGE_CHANGE] = function ()
		M:ClearCityPediaItemCache()
	end
}

M.SearchBaikeItems = function(self, searchText)
	local viewDataList = {}

	if string.is_null_or_empty(searchText) then
		return viewDataList
	end

	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)

		if self.CheckCityPediaSecondClassHasUnlocked(cityPediaCfg.Class) then
			local itemData = self:GetCityPediaItem(cityPediaCfg.Id)
			local searchName = itemData and itemData.name or cityPediaCfg.Name or ""

			if self:IsMatchSearchCondition(searchName, searchText) then
				table.insert(viewDataList, {
					["n;m^"] = "`Nxp~9",
					["a\\x9f\\x8a\\x86Y"] = 0,
					id = cityPediaCfg.Id,
					hasUnlocked = self.CheckCityPediaItemHasUnlocked(cityPediaCfg.Id)
				})
			end
		end
	end

	table.sort(viewDataList, function (a, b)
		if a.hasUnlocked == b.hasUnlocked then
			return a.hasUnlocked
		end

		return a.id <= b.id
	end)

	if #viewDataList ~= 0 then
		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 1
		})
	end

	return viewDataList
end

M.IsMatchSearchCondition = function(self, name, text)
	local formattedName = self.FormatSearchString(self, name)
	local formattedText = self.FormatSearchString(self, text)

	if string.is_null_or_empty(formattedText) then
		return false
	end

	local completePinyin = gCS.LuaUtils.GetPinyin(name)
	local firstLetterPinyin = ""

	for word in string.gmatch(completePinyin, "%a+") do
		firstLetterPinyin = firstLetterPinyin .. word.sub(word, 1, 1)
	end

	completePinyin = self:FormatSearchString(completePinyin)

	return string.find(formattedName, formattedText) or string.find(firstLetterPinyin, formattedText) or string.find(completePinyin, formattedText)
end

M.FormatSearchString = function(self, str)
	return string.lower(string.gsub(str, " ", ""))
end

M.GetSearchItemDisplayInfo = function(self, data)
	local info = {
		["\\x9753\nv\\x91N\\xda<\\xaf\\xbd"] = false,
		["Y\\xa7\\xb6\\xa3\\xb3"] = "",
		["\\xa8\\xb0\\xaem1\\xec*"] = ""
	}

	if not data or data.tIndex == 0 then
		return info
	end

	local dataType = data.type or "CityPedia"
	info.type = dataType

	if dataType ~= "Brand" then
		local brandCfg = LTConfig.ShopBrandConfig.GetConfig(data.id)

		if brandCfg then
			info.title = brandCfg.BrandName
			local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(data.firstClassId)
			info.category = cityPediaFirstClassCfg and cityPediaFirstClassCfg.Name or ""
			info.hasUnlocked = true
			info.firstClassId = data.firstClassId
			info.itemId = data.id
			info.brandId = data.id
		end
	elseif dataType ~= "Suit" then
		local suitCfg = LTConfig.FashionSuitConfig.GetConfig(data.id)

		if suitCfg then
			info.title = suitCfg.Name
			local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(data.firstClassId)
			info.category = cityPediaFirstClassCfg and cityPediaFirstClassCfg.Name or ""
			local isOwned = true

			if suitCfg.FashionIdList then
				for _, fashionId in ipairs(suitCfg.FashionIdList) do
					if not gDressManager:IsFashionHad(fashionId) then
						isOwned = false

						break
					end
				end
			end

			info.hasUnlocked = isOwned
			info.firstClassId = data.firstClassId
			info.itemId = data.id
			info.brandId = data.brandId
		end
	elseif dataType ~= "Fashion" then
		local fashionCfg = LTConfig.FashionConfig.GetConfig(data.id)

		if fashionCfg then
			info.title = fashionCfg.Name
			local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(data.firstClassId)
			info.category = cityPediaFirstClassCfg and cityPediaFirstClassCfg.Name or ""
			info.hasUnlocked = gDressManager:IsFashionHad(data.id)
			info.firstClassId = data.firstClassId
			info.itemId = data.id
		end
	elseif dataType ~= "Vehicle" then
		local vehicleCfg = LTConfig.VehicleConfig.GetConfig(data.id)

		if vehicleCfg then
			info.title = vehicleCfg.VehicleName or ""
			local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(data.firstClassId)
			info.category = cityPediaFirstClassCfg and cityPediaFirstClassCfg.Name or ""
			info.hasUnlocked = gApplyCarManager:CheckPlayerAlreadyHasVehicle(data.id)
			info.firstClassId = data.firstClassId
			info.itemId = data.id
		end
	else
		local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(data.id)

		if cityPediaCfg then
			local itemData = self:GetCityPediaItem(data.id)
			info.title = itemData and itemData.name or cityPediaCfg.Name or ""
			local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaCfg.Class)
			local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(cityPediaSecondClassCfg.FatherId)
			info.category = cityPediaFirstClassCfg.Name
			info.hasUnlocked = self.CheckCityPediaItemHasUnlocked(data.id)
			info.firstClassId = cityPediaFirstClassCfg.Id
			info.itemId = cityPediaCfg.Id
		end
	end

	return info
end

M.CheckSuitOwned = function(self, suitCfg)
	if not suitCfg or not suitCfg.FashionIdList or #suitCfg.FashionIdList ~= 0 then
		return false, 0, 0
	end

	local owned = true
	local haveCount = 0
	local totalCount = #suitCfg.FashionIdList

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		if not gDressManager:IsFashionHad(fashionId) then
			owned = false
		else
			haveCount = haveCount + 1
		end
	end

	return owned, haveCount, totalCount
end

M.InitSuitData = function(self)
	self.brandIdToSuits = {}
	local brandMap = {}
	local suitCount = LTConfig.FashionSuitConfig.count

	for i = 0, suitCount - 1 do
		local suitCfg = LTConfig.FashionSuitConfig.LoadAt(i)

		if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 and suitCfg.ShowInPedia then
			local brandId = self.GetSuitBrandId(self, suitCfg)

			if brandId <= 0 then
				local shopBrandCfg = LTConfig.ShopBrandConfig.GetConfig(brandId)

				if shopBrandCfg then
					if not self.brandIdToSuits[brandId] then
						self.brandIdToSuits[brandId] = {}
						brandMap[brandId] = {
							["a\\x9f\\x8a\\x86Y"] = 0,
							["\\M\\xc0\\xb8\\x80+\\xb7\\xc7\\xfc"] = 0,
							["GUڼ\\x88+\\xb7\\xc7\\xfc"] = 0,
							brandId = brandId,
							brandIcon = shopBrandCfg.BrandLogo,
							originalLogo = shopBrandCfg.BrandLogo,
							bigLogo = shopBrandCfg.BigLogo or shopBrandCfg.BrandLogo,
							brandCfg = shopBrandCfg
						}
					end

					table.insert(self.brandIdToSuits[brandId], suitCfg.Id)

					brandMap[brandId].totalCount = brandMap[brandId].totalCount + 1
				end
			end
		end
	end

	self.brandListData = {}

	for _, brandData in pairs(brandMap) do
		table.insert(self.brandListData, brandData)
	end

	table.sort(self.brandListData, function (a, b)
		if a.brandCfg.Order == b.brandCfg.Order then
			return b.brandCfg.Order <= a.brandCfg.Order
		end

		return a.brandId <= b.brandId
	end)

	for index, brandData in ipairs(self.brandListData) do
		brandData.brandIndex = string.format("%02d", index)
	end
end

M.UpdateBrandOwnedCount = function(self)
	for _, brandData in ipairs(self.brandListData) do
		local brandId = brandData.brandId
		local suitIds = self.brandIdToSuits[brandId] or {}
		local ownedCount = 0

		for _, suitId in ipairs(suitIds) do
			local suitCfg = LTConfig.FashionSuitConfig.GetConfig(suitId)

			if suitCfg then
				local isOwned, _, _ = self.CheckSuitOwned(self, suitCfg)

				if isOwned then
					ownedCount = ownedCount + 1
				end
			end
		end

		brandData.ownedCount = ownedCount
	end
end

M.GetBrandListData = function(self)
	return self.brandListData
end

M.GetBrandIdToSuits = function(self)
	return self.brandIdToSuits
end

M.GetSuitBrandId = function(self, suitCfg)
	if not suitCfg or not suitCfg.FashionIdList or #suitCfg.FashionIdList ~= 0 then
		return 0
	end

	local firstFashionId = suitCfg.FashionIdList[1]
	local firstFashionCfg = LTConfig.FashionConfig.GetConfig(firstFashionId)

	return firstFashionCfg and firstFashionCfg.BelongBrand or 0
end

M.GetFashionShowCaseSpiritList = function(self)
	local lingList = {}
	local spiritIdList = LTConfig.CityPediaConfig.FashionShowcaseSpiritList

	if spiritIdList then
		for _, spiritId in ipairs(spiritIdList) do
			local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)

			if spiritCfg then
				local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)

				if agentCfg then
					local cardData = {
						["/M\\x9d\\x8b\\x80U"] = false,
						["R#k^"] = false,
						Id = spiritCfg.Id,
						Name = spiritCfg.Name,
						sIcon = spiritCfg.SHeadIconID,
						Quality = spiritCfg.Quality,
						Sex = agentCfg.SexType
					}

					table.insert(lingList, cardData)
				end
			end
		end
	end

	return lingList
end

gBaiKeArchiveManager = M

return gBaiKeArchiveManager
