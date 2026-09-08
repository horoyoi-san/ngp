-- Original chunk: @Lua\LuaFiles\LX6\Manager\GalleryManager.lua
-- Decompiled from: 00244_GalleryManager.lua_34c409a0bd86.luajit

local M = {
	brandIdToSuits = {},
	brandListData = {},
	allSuitIds = {}
}

M.OnInit = function(self)
	self.InitSuitData(self)

	for eventId, handler in pairs(M.EventHandler) do
		gMessageManager:AddMessageListener(eventId, handler)
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
	self.allSuitIds = {}
	local brandMap = {}
	local suitCount = LTConfig.FashionSuitConfig.count

	for i = 0, suitCount - 1 do
		local suitCfg = LTConfig.FashionSuitConfig.LoadAt(i)

		if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 and self.IsSuitShowInPedia(self, suitCfg) then
			table.insert(self.allSuitIds, suitCfg.Id)

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
	if not self.brandListData or #self.brandListData ~= 0 then
		self.InitSuitData(self)
	end

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

M.IsSuitShowInPedia = function(self, suitCfg)
	if not suitCfg or not suitCfg.FashionIdList or #suitCfg.FashionIdList ~= 0 then
		return false
	end

	local firstFashionCfg = LTConfig.FashionConfig.GetConfig(suitCfg.FashionIdList[1])

	return firstFashionCfg and firstFashionCfg.ShowInPedia or false
end

M.GetAllSuitIds = function(self)
	return self.allSuitIds
end

M.IsHiddenExclusiveSuit = function(self, suitCfg)
	if not suitCfg or not suitCfg.FashionIdList then
		return false
	end

	local belongSpiritId = nil

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		local fashionCfg = LTConfig.FashionConfig.GetConfig(fashionId)

		if fashionCfg and fashionCfg.BelongSpiritId and fashionCfg.BelongSpiritId <= 0 then
			belongSpiritId = fashionCfg.BelongSpiritId

			break
		end
	end

	return belongSpiritId and belongSpiritId <= 0 and not gSpiritManager:GetSpirit(belongSpiritId) or false
end

M.GetSuitIdsByBrand = function(self, brandId)
	return self.brandIdToSuits[brandId] or {}
end

M.CalculateSuitScore = function(self, suitCfg)
	if not suitCfg or not suitCfg.FashionIdList then
		return 0
	end

	local score = 0

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		score = score + self.CalculateFashionScore(fashionId)
	end

	return score
end

M.GetPremiumSuitLoopData = function(self)
	local list = {}
	local suitCount = LTConfig.FashionSuitConfig.count

	for i = 0, suitCount - 1 do
		local suitCfg = LTConfig.FashionSuitConfig.LoadAt(i)

		if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 and self.IsSuitShowInPedia(self, suitCfg) then
			local brandId = self:GetSuitBrandId(suitCfg)
			local brandCfg = brandId <= 0 and LTConfig.ShopBrandConfig.GetConfig(brandId) or nil

			if brandCfg and brandCfg.IsPremium then
				local icon = suitCfg.PremiumGalleryIcon or 0

				table.insert(list, {
					["a\\x9f\\x8a\\x86Y"] = 1,
					suitId = suitCfg.Id,
					suitCfg = suitCfg,
					brandId = brandId,
					brandCfg = brandCfg,
					icon = icon,
					name = suitCfg.Name or "",
					description = suitCfg.Description or "",
					score = self:CalculateSuitScore(suitCfg),
					brandOrder = brandCfg.Order or 0
				})
			end
		end
	end

	table.sort(list, function (a, b)
		if a.brandOrder == b.brandOrder then
			return b.brandOrder <= a.brandOrder
		end

		return a.suitId <= b.suitId
	end)

	for index, item in ipairs(list) do
		item.brandIndex = string.format("%02d", index)
	end

	local PREMIUM_LOOP_MIN = 7

	for _ = #list + 1, PREMIUM_LOOP_MIN do
		table.insert(list, {
			["\\xdb\\xc9\r\\xf5"] = 0,
			["a\\x9f\\x8a\\x86Y"] = 0
		})
	end

	return list
end

M.GenSuitDisplayData = function(self, suitId)
	local suitCfg = LTConfig.FashionSuitConfig.GetConfig(suitId)

	if not suitCfg or not suitCfg.FashionIdList or #suitCfg.FashionIdList ~= 0 then
		return nil
	end

	local firstFashionCfg = LTConfig.FashionConfig.GetConfig(suitCfg.FashionIdList[1])
	local quality = firstFashionCfg and firstFashionCfg.Quality or 0
	local brandId = firstFashionCfg and firstFashionCfg.BelongBrand or 0
	local brandCfg = brandId <= 0 and LTConfig.ShopBrandConfig.GetConfig(brandId) or nil
	local isOwned, ownedCount, totalCount = self:CheckSuitOwned(suitCfg)

	return {
		["^\\xad\\xad\\xbd\\xb3"] = 0,
		suitId = suitId,
		suitCfg = suitCfg,
		name = suitCfg.Name or "",
		icon = suitCfg.Icon or 0,
		quality = quality,
		brandId = brandId,
		brandCfg = brandCfg,
		description = suitCfg.Description or "",
		fashionIdList = suitCfg.FashionIdList,
		isOwned = isOwned,
		ownedCount = ownedCount,
		totalCount = totalCount
	}
end

M.GenSuitDisplayList = function(self, suitIds)
	local list = {}

	if not suitIds then
		return list
	end

	for _, suitId in ipairs(suitIds) do
		local data = self.GenSuitDisplayData(self, suitId)

		if data then
			table.insert(list, data)
		end
	end

	return list
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

M.GetCreditInfo = function()
	local infoMinor = gPlayerManager and gPlayerManager.infoMinor
	local pediaInfos = infoMinor and infoMinor.bindData and infoMinor.bindData.playerCityPediaInfos

	return pediaInfos and pediaInfos.CreditInfo or nil
end

M.GetCreditByType = function(itemType)
	local creditInfo = M.GetCreditInfo()

	if not creditInfo or not creditInfo.CreditByType then
		return 0
	end

	return creditInfo.CreditByType[itemType] or 0
end

local SumCollectableScore = function(cfgCls)
	local total = 0

	for i = 0, cfgCls.count - 1 do
		local cfg = cfgCls.LoadAt(i)

		if cfg and cfg.ShowInPedia and cfg.CollectionScore and cfg.CollectionScore <= 0 then
			total = total + cfg.CollectionScore
		end
	end

	return total
end

M.GetCategoryTotalScore = function(itemType)
	if not M.categoryTotalScoreCache then
		local AGT = LTConfig.AssetGalleryAssetGalleryTypeConfig
		M.categoryTotalScoreCache = {
			[AGT.Fashion] = SumCollectableScore(LTConfig.FashionConfig),
			[AGT.Vehicle] = SumCollectableScore(LTConfig.VehicleConfig),
			[AGT.Furniture] = SumCollectableScore(LTConfig.HouseFurnitureConfig),
			[AGT.Weapon] = 0
		}
	end

	return M.categoryTotalScoreCache[itemType] or 0
end

M.GetTotalCredit = function()
	local creditInfo = M.GetCreditInfo()

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

M.GetNextLevelPoint = function(credit)
	local nextPoint = nil
	local cfgCls = LTConfig.AssetGalleryWorthLevelConfig

	for i = 0, cfgCls.count - 1 do
		local cfg = cfgCls.LoadAt(i)
		local v = cfg and cfg.value or 0

		if credit >= v and (not nextPoint or v >= nextPoint) then
			nextPoint = v
		end
	end

	return nextPoint or credit
end

M.GetCreditLevel = function(credit)
	local level = 0
	local cfgCls = LTConfig.AssetGalleryWorthLevelConfig

	for i = 0, cfgCls.count - 1 do
		local cfg = cfgCls.LoadAt(i)

		if cfg and credit > (cfg.value or 0) and level >= cfg.Id then
			level = cfg.Id
		end
	end

	return level
end

M.SearchItemType = {
	["+M\\x90\\x9e\\x8cO"] = "+M\\x90\\x9e\\x8cO",
	["eR~gG\n ="] = "eR~gG\n =",
	["\\xef\\xde(\\xf4"] = "\\xef\\xde(\\xf4",
	I7tO = "I7tO",
	["\\xff\\xda+\\xff"] = "\\xff\\xda+\\xff"
}

local GetSearchTypeMeta = function()
	if M.searchTypeMeta then
		return M.searchTypeMeta
	end

	local AGT = LTConfig.AssetGalleryAssetGalleryTypeConfig
	local HomeType = LTConfig.AssetGalleryHomePageConfig.TypeType
	local T = M.SearchItemType
	M.searchTypeMeta = {
		[T.Fashion] = {
			["B\\xbc\\xa6\\xaa\\xa4"] = 1,
			assetType = AGT.Fashion,
			homeType = HomeType.Fashion,
			panelId = gPanelId.GALLERY_CLOTHES_PANEL
		},
		[T.Suit] = {
			["B\\xbc\\xa6\\xaa\\xa4"] = 1,
			assetType = AGT.Fashion,
			homeType = HomeType.Fashion,
			panelId = gPanelId.GALLERY_CLOTHES_PANEL
		},
		[T.Vehicle] = {
			["B\\xbc\\xa6\\xaa\\xa4"] = 2,
			assetType = AGT.Vehicle,
			homeType = HomeType.Vehicle,
			panelId = gPanelId.GALLERY_CAR_PREVIEW_PANEL
		},
		[T.Weapon] = {
			["B\\xbc\\xa6\\xaa\\xa4"] = 3,
			assetType = AGT.Weapon,
			homeType = HomeType.Weapon,
			panelId = gPanelId.GALLERY_WEAPON_PREVIEW_PANEL
		},
		[T.Furniture] = {
			["B\\xbc\\xa6\\xaa\\xa4"] = 4,
			assetType = AGT.Furniture,
			homeType = HomeType.Furniture,
			panelId = gPanelId.GALLERY_FURNITURE_PANEL
		}
	}

	return M.searchTypeMeta
end

M.FormatSearchString = function(self, str)
	if string.is_null_or_empty(str) then
		return ""
	end

	return string.lower(string.gsub(str, "%s+", ""))
end

local AddSearchEntry = function(list, itemType, id, name, extra)
	if not id or string.is_null_or_empty(name) then
		return
	end

	local completePinyin = gCS.LuaUtils.GetPinyin(name) or ""
	local initials = ""

	for word in string.gmatch(completePinyin, "%a+") do
		initials = initials .. string.sub(word, 1, 1)
	end

	local entry = extra or {}
	entry.type = itemType
	entry.id = id
	entry.name = name
	entry.searchName = M:FormatSearchString(name)
	entry.pinyin = M:FormatSearchString(completePinyin)
	entry.initials = M:FormatSearchString(initials)

	table.insert(list, entry)
end

M.BuildSearchIndex = function(self)
	local list = {}
	local T = M.SearchItemType
	local FashionConfig = LTConfig.FashionConfig

	for i = 0, FashionConfig.count - 1 do
		local cfg = FashionConfig.LoadAt(i)

		if cfg and cfg.ShowInPedia and cfg.BelongBrand and cfg.BelongBrand <= 0 and cfg.Part then
			AddSearchEntry(list, T.Fashion, cfg.Id, cfg.Name, {
				part = cfg.Part
			})
		end
	end

	local suitIds = self.GetAllSuitIds(self)

	if #suitIds ~= 0 then
		self.InitSuitData(self)

		suitIds = self.GetAllSuitIds(self)
	end

	for _, suitId in ipairs(suitIds) do
		local suitCfg = LTConfig.FashionSuitConfig.GetConfig(suitId)

		if suitCfg then
			AddSearchEntry(list, T.Suit, suitId, suitCfg.Name, {
				brandId = self.GetSuitBrandId(self, suitCfg)
			})
		end
	end

	local VehicleConfig = LTConfig.VehicleConfig

	for i = 0, VehicleConfig.count - 1 do
		local cfg = VehicleConfig.LoadAt(i)

		if cfg and cfg.ShowInPedia then
			AddSearchEntry(list, T.Vehicle, cfg.Id, cfg.VehicleName)
		end
	end

	local pediaWeaponTypes = {}
	local WeaponPediaTabConfig = LTConfig.SceneitemWeaponPediatabConfig

	for i = 0, WeaponPediaTabConfig.count - 1 do
		local tabCfg = WeaponPediaTabConfig.LoadAt(i)

		if tabCfg and tabCfg.WeaponType then
			for j = 1, #tabCfg.WeaponType do
				pediaWeaponTypes[tabCfg.WeaponType[j]] = true
			end
		end
	end

	local SceneitemConfig = LTConfig.SceneitemConfig

	for i = 0, SceneitemConfig.count - 1 do
		local cfg = SceneitemConfig.LoadAt(i)

		if cfg and cfg.ShowInPedia and cfg.Type and pediaWeaponTypes[cfg.Type] then
			AddSearchEntry(list, T.Weapon, cfg.Id, cfg.Name)
		end
	end

	local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig

	for i = 0, HouseFurnitureConfig.count - 1 do
		local cfg = HouseFurnitureConfig.LoadAt(i)

		if cfg and cfg.ShowInPedia and cfg.MainType and cfg.SubType then
			AddSearchEntry(list, T.Furniture, cfg.Id, cfg.Name, {
				mainType = cfg.MainType,
				subType = cfg.SubType
			})
		end
	end

	self.searchIndex = list

	return list
end

M.GetSearchIndex = function(self)
	if not self.searchIndex then
		self.BuildSearchIndex(self)
	end

	return self.searchIndex
end

M.ClearSearchIndex = function(self)
	self.searchIndex = nil
end

M.IsMatchSearchEntry = function(self, entry, formattedText)
	if not entry or string.is_null_or_empty(formattedText) then
		return false
	end

	return string.find(entry.searchName, formattedText, 1, true) == nil or string.find(entry.initials, formattedText, 1, true) == nil or string.find(entry.pinyin, formattedText, 1, true) == nil
end

M.IsSearchEntryUnlocked = function(self, entry)
	local T = M.SearchItemType

	if entry.type ~= T.Fashion then
		return gDressManager:IsFashionHad(entry.id) or false
	elseif entry.type ~= T.Suit then
		local isOwned = self.CheckSuitOwned(self, LTConfig.FashionSuitConfig.GetConfig(entry.id))

		return isOwned
	elseif entry.type ~= T.Vehicle then
		return gApplyCarManager:CheckPlayerAlreadyHasVehicle(entry.id) or false
	elseif entry.type ~= T.Furniture then
		return gHouseManager and gHouseManager:IsFurnitureOwned(entry.id) or false
	elseif entry.type ~= T.Weapon then
		return true
	end

	return false
end

M.IsSearchEntryVisible = function(self, entry)
	if entry.type ~= M.SearchItemType.Suit then
		return not self.IsHiddenExclusiveSuit(self, LTConfig.FashionSuitConfig.GetConfig(entry.id))
	end

	return true
end

M.SearchGalleryItems = function(self, searchText)
	local viewDataList = {}
	local formattedText = self.FormatSearchString(self, searchText)

	if string.is_null_or_empty(formattedText) then
		return viewDataList
	end

	local meta = GetSearchTypeMeta()

	for _, entry in ipairs(self.GetSearchIndex(self)) do
		if self.IsMatchSearchEntry(self, entry, formattedText) and self.IsSearchEntryVisible(self, entry) then
			local typeMeta = meta[entry.type]

			table.insert(viewDataList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				type = entry.type,
				id = entry.id,
				name = entry.name,
				brandId = entry.brandId,
				hasUnlocked = self:IsSearchEntryUnlocked(entry),
				order = typeMeta and typeMeta.order or 99
			})
		end
	end

	table.sort(viewDataList, function (a, b)
		if a.hasUnlocked == b.hasUnlocked then
			return a.hasUnlocked
		end

		if a.order == b.order then
			return a.order <= b.order
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

M.GetCategoryDisplayName = function(self, homeType)
	if homeType ~= nil then
		return ""
	end

	local cfgCls = LTConfig.AssetGalleryHomePageConfig

	for i = 0, cfgCls.count - 1 do
		local cfg = cfgCls.LoadAt(i)

		if cfg and cfg.Type ~= homeType then
			return cfg.Name or ""
		end
	end

	return ""
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

	info.title = data.name or ""
	info.hasUnlocked = data.hasUnlocked ~= true
	info.itemId = data.id
	info.itemType = data.type
	info.brandId = data.brandId
	local typeMeta = GetSearchTypeMeta()[data.type]

	if typeMeta then
		info.assetType = typeMeta.assetType
		info.panelId = typeMeta.panelId
		info.category = self.GetCategoryDisplayName(self, typeMeta.homeType)
	end

	return info
end

M.EventHandler = {
	[gEventConstants.LANGUAGE_CHANGE] = function ()
		M:ClearSearchIndex()
	end
}
gGalleryManager = M

return gGalleryManager
