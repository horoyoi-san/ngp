local WikiType = UX.Game.GalleryWikiType
local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local PetAnimalConfig = LTConfig.PetAnimalConfig
local M = {
	isLoading = false,
	itemSubTypes = {
		{},
		{},
		{},
		{}
	},
	notIncludeItem = {
		ConsumableConfig.RewardExp
	},
	baikeType = {
		Text = 2,
		Vehicle = 4,
		Item = 0,
		Pets = 1,
		Fashion = 3
	},
	brandIdToSuits = {},
	brandListData = {},
	prevItemsSort = {},
	GetPrevItemsSort = function (self, index)
		local indexStr = tostring(index)

		if self.prevItemsSort[indexStr] == nil then
			self.prevItemsSort[indexStr] = {
				order = true,
				type = 1
			}
		end

		return self.prevItemsSort[indexStr]
	end
}

function M:SetPrevItemsSort(index, type, order)
	local itemsSort = self:GetPrevItemsSort(index)
	itemsSort.type = type or 1
	itemsSort.order = order or false
end

function M:OnInit()
	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	self:InitItemTab()
	self:InitSuitData()
end

function M:OnBeforeSwitchScene(switchType)
	self.isLoading = true
end

function M:OnAfterSwitchScene(switchType)
	self.isLoading = false
end

function M:InitItemTab()
	for i = 4, 7 do
		local tabTypes = gPlayerItemManager.subTypes[i]

		for j = 1, #tabTypes do
			local tabTypeVal = ConsumableTypeConfig[tabTypes[j]]

			if tabTypeVal then
				table.insert(self.itemSubTypes[i - 3], tabTypeVal)
			end
		end
	end
end

function M:GetItemTabIndexByCfg(cfg)
	for i = 1, 4 do
		local tabTypes = gBaiKeArchiveManager.itemSubTypes[i]

		if array.contains(tabTypes, cfg.SubType) then
			return i
		end
	end

	return nil
end

function M:GetAllRedCount(callBack)
	local totalCount = self:GetPetRedCount()

	self:GetAllWikiRedCount(function (err, count)
		totalCount = totalCount + count

		callBack(err, totalCount)
	end)
end

function M:GetAllWikiRedCount(callBack)
	local count = 0

	self:AskGalleryInfo(function (err, info)
		if info then
			for type, value in pairs(info) do
				local galleryInfo = value.GalleryInfo

				for key, value in pairs(galleryInfo) do
					if value.State == UX.Game.GalleryState.New then
						if type == WikiType.Item then
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
end

function M:GetAllWikiUnlockCount(callBack)
	local count = 0

	self:AskGalleryInfo(function (err, info)
		if info then
			for type, value in pairs(info) do
				if type == WikiType.Item then
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
end

function M:GetAllWikiUnlockCount(callBack)
	local count = 0

	self:AskGalleryInfo(function (err, info)
		if info then
			for type, value in pairs(info) do
				if self:IsUnlockByWikiType(type) then
					if type == WikiType.Item then
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
end

function M:IsUnlock(galleryId, callBack)
	self:AskGalleryInfo(function (err, info)
		if info then
			local isUnlock = false

			for type, value in pairs(info) do
				for key, value in pairs(value.GalleryInfo) do
					if key == galleryId then
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
end

function M:GetPetRedCount()
	local count = 0
	local petInfos = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos

	for key, petInfo in pairs(petInfos) do
		if petInfo.Unlock and not petInfo.Interacted then
			count = count + 1
		end
	end

	return count
end

function M:IsPet(petAnimalId)
	local cfg = PetAnimalConfig.GetConfig(petAnimalId)

	if cfg and cfg.AnimalType > 0 and cfg.UnlockGallery then
		return true
	end
end

function M:IsUnlockByWikiType(wikiType)
	local baikeEntranceList = LTConfig.GalleryConfig.BaikeEntrance

	for i = 1, #baikeEntranceList do
		local info = baikeEntranceList[i]

		if info.panelId == self:GetPanelIdByWikeType(wikiType) then
			return true
		end
	end

	return false
end

function M:GetPanelIdByWikeType(wikiType)
	return 0
end

function M:AskGalleryInfo(cb)
	if self.isLoading then
		if cb then
			cb()
		end

		return
	end

	gClientToGameDelegate:AskGalleryInfo().Callback = function (err, info)
		if cb then
			cb(err, info)
		end
	end
end

M.BaikeEntranceType = {
	Collection = 3,
	Pet = 2,
	Item = 1
}
M.BaikeEntranceToLTConfig = {
	[M.BaikeEntranceType.Pet] = LTConfig.PetAnimalConfig,
	[M.BaikeEntranceType.Collection] = LTConfig.GalleryCollectionConfig
}
M.ColumnNameMap = {
	[M.BaikeEntranceType.Pet] = {
		"Name",
		"SImage"
	},
	[M.BaikeEntranceType.Collection] = {
		"Name",
		"SImageId"
	}
}

function M.GetCityPediaCreditPoint(type)
	local creditInfo = M.GetCityPediaCreditInfo()

	return creditInfo and creditInfo.Credit or 0
end

function M.GetCityPediaCreditInfo()
	return gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CreditInfo
end

function M.GetCityPediaCredit()
	local creditInfo = M.GetCityPediaCreditInfo()

	return creditInfo and creditInfo.Credit or 0
end

function M.GetCityPediaCreditLevel()
	local creditInfo = M.GetCityPediaCreditInfo()

	return creditInfo and creditInfo.Level or 0
end

function M.GetClaimedRewardLevels()
	local creditInfo = M.GetCityPediaCreditInfo()

	return creditInfo and creditInfo.ClaimedLevelRewards or {}
end

function M.CheckRewardClaimed(level)
	local claimedLevels = M.GetClaimedRewardLevels()

	if claimedLevels[level] then
		return true
	end

	return false
end

function M.ClaimCityPediaLevelReward(level, callback)
	gClientToGameDelegate:ClaimCityPediaLevelReward(level).Callback = function (errId)
		if errId ~= 0 then
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

function M.CheckCityPediaItemHasUnlocked(id)
	local config = LTConfig.CityPediaConfig.GetConfig(id)

	return gEventConditionUtils.CheckHasUnlocked(config, UX.Game.EventConditionImplModule.CityPedia)
end

function M.SyncCityPediaUnlocked(incrementUnlockedIdList)
	local cityPedia2IsReadDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPedia2IsReadDict

	for _, cityPediaId in ipairs(incrementUnlockedIdList) do
		cityPedia2IsReadDict[cityPediaId] = true
		local appCanShow = gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.BaiKeId)

		if appCanShow then
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.CityPediaUnlocked, {
				id = cityPediaId
			})
		end
	end
end

function M.CheckCityPediaFirstClassHasRedDot(cityPediaFirstClassId)
	local cityPediaIdList = M.GetFirstClassCityPediaIdList(cityPediaFirstClassId)

	for _, cityPediaId in ipairs(cityPediaIdList) do
		if M.CheckCityPediaItemHasRedDot(cityPediaId) then
			return true
		end
	end
end

function M.CheckCityPediaSecondClassHasRedDot(cityPediaSecondClassId)
	local cityPediaIdList = M.GetSecondClassCityPediaIdList(cityPediaSecondClassId)

	for _, cityPediaId in ipairs(cityPediaIdList) do
		if M.CheckCityPediaItemHasRedDot(cityPediaId) then
			return true
		end
	end
end

function M.GetFirstClassCityPediaIdList(cityPediaFirstClassId)
	local cityPediaIdList = {}
	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)
		local cityPediaSecondClassId = cityPediaCfg.Class
		local cityPediaSecondCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaSecondClassId)

		if cityPediaSecondCfg.FatherId == cityPediaFirstClassId then
			table.insert(cityPediaIdList, cityPediaCfg.Id)
		end
	end

	return cityPediaIdList
end

function M.GetSecondClassCityPediaIdList(cityPediaSecondClassId)
	local cityPediaIdList = {}
	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)

		if cityPediaCfg.Class == cityPediaSecondClassId then
			table.insert(cityPediaIdList, cityPediaCfg.Id)
		end
	end

	return cityPediaIdList
end

function M.CheckCityPediaItemHasRedDot(id)
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

	local cityPedia2IsReadDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPedia2IsReadDict

	return cityPedia2IsReadDict[id] == true
end

function M.SetCityPediaItemHasRead(id)
	local cityPedia2IsReadDict = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPedia2IsReadDict
	cityPedia2IsReadDict[id] = nil

	gClientToGameDelegate:AskReadCityPedia(id).Callback = function ()
		return
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

function M.GetCityPediaFisrtClassRedDotCount(id)
	local cityPediaIdList = M.GetFirstClassCityPediaIdList(id)
	local count = 0

	for _, cityPediaId in ipairs(cityPediaIdList) do
		if M.CheckCityPediaItemHasRedDot(cityPediaId) then
			count = count + 1
		end
	end

	return count
end

function M.GetCityPediaFirstClassRedDotKey(id)
	return ("BaiKeCityPediaFisrtClassRedDot:%d"):format(id)
end

function M.GetCityPediaSecondClassRedDotKey(id)
	return ("BaiKeCityPediaSecondClassRedDot:%d"):format(id)
end

function M.GetCityPediaRedDotKey(id)
	return ("BaiKeCityPediaRedDot:%d"):format(id)
end

function M.GetPlayFashionPanelRedDotKey()
	return "BaikePlayFashionPanelRedDot"
end

function M.CheckPlayFashionPanelHasRedDot()
	local currentCredit = M.GetCityPediaCredit()
	local count = LTConfig.CityPediaCollectionLevelConfig.count

	for i = 0, count - 1 do
		local levelCfg = LTConfig.CityPediaCollectionLevelConfig.LoadAt(i)

		if levelCfg then
			local isClaimed = M.CheckRewardClaimed(levelCfg.Id)
			local canClaim = levelCfg.value <= currentCredit and not isClaimed

			if canClaim then
				return true
			end
		end
	end

	return false
end

function M.GetPlayFashionPanelRedDotCount()
	local currentCredit = M.GetCityPediaCredit()
	local count = LTConfig.CityPediaCollectionLevelConfig.count
	local rewardCount = 0

	for i = 0, count - 1 do
		local levelCfg = LTConfig.CityPediaCollectionLevelConfig.LoadAt(i)

		if levelCfg then
			local isClaimed = M.CheckRewardClaimed(levelCfg.Id)
			local canClaim = levelCfg.value <= currentCredit and not isClaimed

			if canClaim then
				rewardCount = rewardCount + 1
			end
		end
	end

	return rewardCount
end

function M.RefreshBaikePhoneAppRedDot()
	local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
	local redDotKey = ("PhoneAppItemRedDot:%d"):format(MobileMenuSGuiConfig.BaiKeId)

	gMainPhoneUtils.RefreshAppItemRedDot(MobileMenuSGuiConfig.BaiKeId, redDotKey)
end

function M.CheckCityPediaFisrtClassHasUnlocked(cityPediaFisrtClassId)
	local config = LTConfig.CityPediaFirstClassConfig.GetConfig(cityPediaFisrtClassId)

	return config and gEventConditionUtils.CheckHasUnlocked(config, UX.Game.EventConditionImplModule.CityPediaFirstClass)
end

function M.CheckCityPediaSecondClassHasUnlocked(cityPediaSecondClassId)
	local config = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaSecondClassId)

	return config and gEventConditionUtils.CheckHasUnlocked(config, UX.Game.EventConditionImplModule.CityPediaSecondClass)
end

function M.GetCityPediaFisrtClassPorgress(cityPediaFisrtClassId)
	if M.CheckCityPediaFisrtClassHasUnlocked(cityPediaFisrtClassId) then
		local count = LTConfig.CityPediaConfig.count
		local current = 0
		local total = 0

		for i = 0, count - 1 do
			local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)
			local cityPediaSecondClassId = cityPediaCfg.Class
			local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaSecondClassId)

			if cityPediaSecondClassCfg.FatherId == cityPediaFisrtClassId then
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

function M.CalculateFashionScore(fashionId)
	local fashionCfg = LTConfig.FashionConfig.GetConfig(fashionId)

	if fashionCfg and fashionCfg.CollectionScore then
		return fashionCfg.CollectionScore
	end

	return 0
end

function M.CalculateVehicleScore(vehicleId)
	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)

	if vehicleCfg and vehicleCfg.CollectionScore then
		return vehicleCfg.CollectionScore
	end

	return 0
end

function M.CalculateTotalOwnedFashionScore()
	local ownedScore = 0
	local totalScore = 0
	local ownedCount = 0
	local totalCount = 0
	local fashionCount = LTConfig.FashionConfig.count

	for i = 0, fashionCount - 1 do
		local fashionCfg = LTConfig.FashionConfig.LoadAt(i)

		if fashionCfg and fashionCfg.ShowInPedia and fashionCfg.BelongBrand and fashionCfg.BelongBrand > 0 then
			local score = M.CalculateFashionScore(fashionCfg.Id)
			totalScore = totalScore + score
			totalCount = totalCount + 1

			if gDressManager:IsFashionHaved(fashionCfg.Id) then
				ownedScore = ownedScore + score
				ownedCount = ownedCount + 1
			end
		end
	end

	return ownedScore, totalScore, ownedCount, totalCount
end

function M.CalculateBrandOwnedFashionScore(brandId)
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

					if gDressManager:IsFashionHaved(fashionId) then
						ownedScore = ownedScore + score
						ownedCount = ownedCount + 1
					end
				end
			end
		end
	end

	return ownedScore, totalScore, ownedCount, totalCount
end

function M.CalculateTotalOwnedVehicleScore()
	local ownedScore = 0
	local totalScore = 0
	local ownedCount = 0
	local totalCount = 0
	local vehicleCount = LTConfig.VehicleConfig.count

	for i = 0, vehicleCount - 1 do
		local vehicleCfg = LTConfig.VehicleConfig.LoadAt(i)

		if vehicleCfg and vehicleCfg.ShowInPedia and vehicleCfg.Brand and vehicleCfg.Brand > 0 then
			local score = M.CalculateVehicleScore(vehicleCfg.Id)
			totalScore = totalScore + score
			totalCount = totalCount + 1

			if gApplyCarManager:CheckPlayerAlreadyHasVehicle(vehicleCfg.Id) then
				ownedScore = ownedScore + score
				ownedCount = ownedCount + 1
			end
		end
	end

	return ownedScore, totalScore, ownedCount, totalCount
end

M.EventHandler = {
	[gEventConstants.LOADING_FINISHED] = function (eventId, switchType)
		M:OnAfterSwitchScene(switchType)
	end
}

function M:SearchBaikeItems(searchText, fashionFirstClassId, vehicleFirstClassId)
	local viewDataList = {}

	if string.is_null_or_empty(searchText) then
		return viewDataList
	end

	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)

		if self.CheckCityPediaSecondClassHasUnlocked(cityPediaCfg.Class) and self:IsMatchSearchCondition(cityPediaCfg.Name, searchText) then
			table.insert(viewDataList, {
				type = "CityPedia",
				tIndex = 0,
				id = cityPediaCfg.Id
			})
		end
	end

	if fashionFirstClassId and self.CheckCityPediaFisrtClassHasUnlocked(fashionFirstClassId) then
		for _, brandData in ipairs(self.brandListData) do
			local brandCfg = brandData.brandCfg

			if brandCfg and self:IsMatchSearchCondition(brandCfg.BrandName, searchText) then
				table.insert(viewDataList, {
					type = "Brand",
					tIndex = 0,
					id = brandCfg.Id,
					firstClassId = fashionFirstClassId
				})
			end
		end

		for _, suitIds in pairs(self.brandIdToSuits) do
			for _, suitId in ipairs(suitIds) do
				local suitCfg = LTConfig.FashionSuitConfig.GetConfig(suitId)

				if suitCfg and self:IsMatchSearchCondition(suitCfg.Name, searchText) then
					table.insert(viewDataList, {
						type = "Suit",
						tIndex = 0,
						id = suitCfg.Id,
						firstClassId = fashionFirstClassId,
						brandId = suitCfg.Brand
					})
				end
			end
		end

		local fashionCount = LTConfig.FashionConfig.count

		for i = 0, fashionCount - 1 do
			local fashionCfg = LTConfig.FashionConfig.LoadAt(i)

			if fashionCfg.ShowInPedia and fashionCfg.BelongBrand > 0 and self:IsMatchSearchCondition(fashionCfg.Name, searchText) then
				table.insert(viewDataList, {
					type = "Fashion",
					tIndex = 0,
					id = fashionCfg.Id,
					firstClassId = fashionFirstClassId
				})
			end
		end
	end

	if vehicleFirstClassId and self.CheckCityPediaFisrtClassHasUnlocked(vehicleFirstClassId) then
		local vehicleCount = LTConfig.VehicleConfig.count

		for i = 0, vehicleCount - 1 do
			local vehicleCfg = LTConfig.VehicleConfig.LoadAt(i)

			if vehicleCfg.ShowInPedia and self:IsMatchSearchCondition(vehicleCfg.VehicleName, searchText) then
				table.insert(viewDataList, {
					type = "Vehicle",
					tIndex = 0,
					id = vehicleCfg.Id,
					firstClassId = vehicleFirstClassId
				})
			end
		end
	end

	if #viewDataList == 0 then
		table.insert(viewDataList, {
			tIndex = 1
		})
	end

	return viewDataList
end

function M:IsMatchSearchCondition(name, text)
	local formattedName = self:FormatSearchString(name)
	local formattedText = self:FormatSearchString(text)

	if string.is_null_or_empty(formattedText) then
		return false
	end

	local completePinyin = gCS.LuaUtils.GetPinyin(name)
	local firstLetterPinyin = ""

	for word in string.gmatch(completePinyin, "%a+") do
		firstLetterPinyin = firstLetterPinyin .. word:sub(1, 1)
	end

	completePinyin = self:FormatSearchString(completePinyin)

	return string.find(formattedName, formattedText) or string.find(firstLetterPinyin, formattedText) or string.find(completePinyin, formattedText)
end

function M:FormatSearchString(str)
	return string.lower(string.gsub(str, " ", ""))
end

function M:GetSearchItemDisplayInfo(data)
	local info = {
		hasUnlocked = false,
		title = "",
		category = ""
	}

	if not data or data.tIndex ~= 0 then
		return info
	end

	local dataType = data.type or "CityPedia"
	info.type = dataType

	if dataType == "Brand" then
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
	elseif dataType == "Suit" then
		local suitCfg = LTConfig.FashionSuitConfig.GetConfig(data.id)

		if suitCfg then
			info.title = suitCfg.Name
			local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(data.firstClassId)
			info.category = cityPediaFirstClassCfg and cityPediaFirstClassCfg.Name or ""
			local isOwned = true

			if suitCfg.FashionIdList then
				for _, fashionId in ipairs(suitCfg.FashionIdList) do
					if not gDressManager:IsFashionHaved(fashionId) then
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
	elseif dataType == "Fashion" then
		local fashionCfg = LTConfig.FashionConfig.GetConfig(data.id)

		if fashionCfg then
			info.title = fashionCfg.Name
			local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(data.firstClassId)
			info.category = cityPediaFirstClassCfg and cityPediaFirstClassCfg.Name or ""
			info.hasUnlocked = gDressManager:IsFashionHaved(data.id)
			info.firstClassId = data.firstClassId
			info.itemId = data.id
		end
	elseif dataType == "Vehicle" then
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
			info.title = cityPediaCfg.Name
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

function M:CheckSuitOwned(suitCfg)
	if not suitCfg or not suitCfg.FashionIdList or #suitCfg.FashionIdList == 0 then
		return false, 0, 0
	end

	local owned = true
	local haveCount = 0
	local totalCount = #suitCfg.FashionIdList

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		if not gDressManager:IsFashionHaved(fashionId) then
			owned = false
		else
			haveCount = haveCount + 1
		end
	end

	return owned, haveCount, totalCount
end

function M:InitSuitData()
	self.brandIdToSuits = {}
	local brandMap = {}
	local suitCount = LTConfig.FashionSuitConfig.count

	for i = 0, suitCount - 1 do
		local suitCfg = LTConfig.FashionSuitConfig.LoadAt(i)

		if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList > 0 and suitCfg.ShowInPedia and suitCfg.Brand and suitCfg.Brand > 0 then
			local brandId = suitCfg.Brand
			local shopBrandCfg = LTConfig.ShopBrandConfig.GetConfig(brandId)

			if shopBrandCfg then
				if not self.brandIdToSuits[brandId] then
					self.brandIdToSuits[brandId] = {}
					brandMap[brandId] = {
						tIndex = 0,
						ownedCount = 0,
						totalCount = 0,
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

	self.brandListData = {}

	for _, brandData in pairs(brandMap) do
		table.insert(self.brandListData, brandData)
	end

	table.sort(self.brandListData, function (a, b)
		if a.brandCfg.Order ~= b.brandCfg.Order then
			return b.brandCfg.Order < a.brandCfg.Order
		end

		return a.brandId < b.brandId
	end)

	for index, brandData in ipairs(self.brandListData) do
		brandData.brandIndex = string.format("%02d", index)
	end
end

function M:UpdateBrandOwnedCount()
	for _, brandData in ipairs(self.brandListData) do
		local brandId = brandData.brandId
		local suitIds = self.brandIdToSuits[brandId] or {}
		local ownedCount = 0

		for _, suitId in ipairs(suitIds) do
			local suitCfg = LTConfig.FashionSuitConfig.GetConfig(suitId)

			if suitCfg then
				local isOwned, _, _ = self:CheckSuitOwned(suitCfg)

				if isOwned then
					ownedCount = ownedCount + 1
				end
			end
		end

		brandData.ownedCount = ownedCount
	end
end

function M:GetBrandListData()
	return self.brandListData
end

function M:GetBrandIdToSuits()
	return self.brandIdToSuits
end

function M:GetFashionShowCaseSpiritList()
	local lingList = {}
	local spiritIdList = LTConfig.CityPediaConfig.FashionShowcaseSpiritList

	if spiritIdList then
		for _, spiritId in ipairs(spiritIdList) do
			local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)

			if spiritCfg then
				local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)

				if agentCfg then
					local cardData = {
						Select = false,
						Have = false,
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
