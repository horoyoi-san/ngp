-- Original chunk: @Lua\LuaFiles\LX6\Manager\Dress\DressData.lua
-- Decompiled from: 00537_DressData.lua_24979c7a06da.luajit

local MessageConfig = LTConfig.MessageConfig
local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionSlot = LX6.Share.FashionSlot
local infoModule = LX6.Units.Module.UnitFashionInfoModule
local UXVector3 = UX.Game.UXVector3

local CreateSpiritWearFashionsInfo = function(WearFashionInfoList, WearFashionEditInfoList, spiritId)
	local fashionInfoCount = table.count(WearFashionInfoList)
	local fashionEditCount = table.count(WearFashionEditInfoList)
	local tempWearFashionInfoList = {
		Count = fashionInfoCount,
		Length = fashionInfoCount
	}
	local tempWearFashionEditInfoList = {
		Count = fashionEditCount,
		Length = fashionEditCount
	}
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]
	local HiddenParts = FashionConfig.SelectableHiddenPartType.None
	local WearSourceInfo = {
		["\\x98\\xbe\\xb9i;\\xd77"] = 0,
		Source = UX.Game.FashionWearSource.Spirit
	}
	local FunctionSuitId = 0

	if spiritFashionsInfo and spiritFashionsInfo.SpiritWearFashionsInfo then
		HiddenParts = spiritFashionsInfo.SpiritWearFashionsInfo.HiddenParts
		WearSourceInfo = spiritFashionsInfo.SpiritWearFashionsInfo.WearSourceInfo
		FunctionSuitId = spiritFashionsInfo.SpiritWearFashionsInfo.FunctionSuitId
	end

	for i = 1, fashionInfoCount do
		table.insert(tempWearFashionInfoList, WearFashionInfoList[i])
	end

	for i = 1, fashionEditCount do
		table.insert(tempWearFashionEditInfoList, WearFashionEditInfoList[i])
	end

	return {
		WearFashionInfoList = tempWearFashionInfoList,
		WearFashionEditInfoList = tempWearFashionEditInfoList,
		HiddenParts = HiddenParts,
		FunctionSuitId = FunctionSuitId,
		WearSourceInfo = WearSourceInfo
	}
end

local CreateFashionCustomSuitSchemeInfo = function()
	return {
		["`YƸ\\x89\r\\x96\\xc4\\xed"] = "",
		WearFashionInfoList = {},
		HiddenParts = FashionConfig.SelectableHiddenPartType.None
	}
end

local ConvertWearFashionInfoToLuaTable = function(info)
	return {
		FashionId = info.FashionId
	}
end

local ConvertWearFashionEditInfoToLuaTable = function(info)
	return {
		FashionId = info.FashionId,
		Scale = info.Scale,
		Rotation = UXVector3.New(info.Rotation),
		Offset = UXVector3.New(info.Offset)
	}
end

local CreateFashionFunctionSuitSchemeInfo = function(WearFashionInfoList, WearFashionEditInfoList)
	local fashionInfoCount = #WearFashionInfoList
	local fashionEditCount = #WearFashionEditInfoList
	local tempWearFashionInfoList = {
		Count = fashionInfoCount,
		Length = fashionInfoCount
	}
	local tempWearFashionEditInfoList = {
		Count = fashionEditCount,
		Length = fashionEditCount
	}

	for i = 1, fashionInfoCount do
		table.insert(tempWearFashionInfoList, ConvertWearFashionInfoToLuaTable(WearFashionInfoList[i]))
	end

	for i = 1, fashionEditCount do
		table.insert(tempWearFashionEditInfoList, ConvertWearFashionEditInfoToLuaTable(WearFashionEditInfoList[i]))
	end

	return {
		WearFashionInfoList = tempWearFashionInfoList,
		WearFashionEditInfoList = tempWearFashionEditInfoList,
		HiddenParts = FashionConfig.SelectableHiddenPartType.None
	}
end

local CreateSpiritFashionsInfo = function(spiritId, customSuitSchemeCount)
	local fashionCustomSuitSchemeInfos = {
		Count = customSuitSchemeCount,
		Length = customSuitSchemeCount
	}

	for i = 1, customSuitSchemeCount do
		table.insert(fashionCustomSuitSchemeInfos, CreateFashionCustomSuitSchemeInfo())
	end

	return {
		SpiritId = spiritId,
		FashionCustomSuitSchemeInfos = fashionCustomSuitSchemeInfos,
		FashionFunctionSuitSchemeInfoDict = {
			["n\\xa1\\xb7\\xa1\\xa2"] = 0,
			["0M\\x9f\\x89\\x97I"] = 0
		},
		SpiritWearFashionsInfo = CreateSpiritWearFashionsInfo({}, {}, spiritId),
		ActiveClientTryWearSource = UX.Game.FashionWearSource.Spirit
	}
end

local OnSetSpiritFunctionSuitSchemeInfo = function(spiritId, functionSuitId, suitSchemeInfo)
	local schemeInfo = CreateFashionFunctionSuitSchemeInfo(suitSchemeInfo.WearFashionInfoList, suitSchemeInfo.WearFashionEditInfoList)
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]

	if spiritFashionsInfo then
		spiritFashionsInfo.FashionFunctionSuitSchemeInfoDict[functionSuitId] = schemeInfo
	else
		spiritFashionsInfo = CreateSpiritFashionsInfo(spiritId, FashionConfig.CustomSuitSchemeCount)
		spiritFashionsInfo.FashionFunctionSuitSchemeInfoDict[functionSuitId] = schemeInfo
		spiritFashionsInfoDict[spiritId] = spiritFashionsInfo
	end
end

local M = {
	pendingAddFashionIds = {},
	pendingRemoveFashionIds = {},
	pendingAddSuitIds = {},
	pendingRemoveSuitIds = {},
	AskBuyCommodities = function (self, shopId, commodityList, cb)
		slot4 = gClientToGameDelegate

		slot4:AskBuyCommodities(shopId, commodityList).Callback = function (err)
			if err ~= MessageConfig.Ok then
				if cb then
					cb()
				end
			else
				local msg = "["

				for commodityId in ipairs(commodityList) do
					msg = msg .. commodityId .. ","
				end

				msg = msg .. "]"

				print_error("NPC商店购买商品list失败, commodityList=" .. msg, gCS.Error.GetNameById(err))
			end
		end
	end,
	AskBuyHaircutCommodities = function (self, shopId, commodityList, cb)
		slot4 = gClientToGameDelegate

		slot4:AskBuyHaircutCommodities(shopId, commodityList).Callback = function (err)
			if err ~= MessageConfig.Ok then
				if cb then
					cb()
				end
			else
				local msg = "["

				for commodityId in ipairs(commodityList) do
					msg = msg .. commodityId .. ","
				end

				msg = msg .. "]"

				print_error("NPC商店购买商品list失败, commodityList=" .. msg, gCS.Error.GetNameById(err))
			end
		end
	end,
	AskReadCommodities = function (self, shopId, commodityidlist, cb)
		if table.isNilOrEmpty(commodityidlist) then
			return
		end

		slot4 = gClientToGameDelegate

		slot4:AskReadCommodities(shopId, commodityidlist).Callback = function (err)
			if err ~= MessageConfig.Ok and cb then
				cb()
			end
		end
	end,
	AskSetFashionColoringSchemeInfos = function (self, fashionId, colorType, colorSchemeInfoList, cb)
		local fashionColoringSchemeInfoList = {}
		local fashionColoringSchemeInfo = {
			FashionId = fashionId,
			FashionColoringSchemeInfoDict = colorSchemeInfoList
		}

		table.insert(fashionColoringSchemeInfoList, fashionColoringSchemeInfo)

		slot7 = gClientToGameDelegate

		slot7:AskSetFashionColoringSchemeInfos(fashionColoringSchemeInfoList).Callback = function (err, data)
			if err ~= MessageConfig.Ok then
				local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
				local fashionInfo = fashionInfoDict[fashionId]

				if fashionInfo then
					fashionInfo.ColoringSchemeInfoDict[colorType] = colorSchemeInfoList[colorType]
					fashionInfo.ApplyColoringSchemeId = colorType
				end

				infoModule.SyncSetFashionColoringSchemeInfos(fashionId, colorType, colorSchemeInfoList[colorType].ColoringType2ColorIdDict)

				local tempColorSchemeInfoList = table.clone(colorSchemeInfoList)

				for i, tempColorSchemeInfo in pairs(tempColorSchemeInfoList) do
					local colorMatIdDict = {}

					for coloringType, colorCfgId in pairs(tempColorSchemeInfo.ColoringType2ColorIdDict) do
						local index = gDressDyeManager:GetColorMatList(coloringType)

						if index then
							colorMatIdDict[index] = colorCfgId
						end
					end

					tempColorSchemeInfo.ColoringType2ColorIdDict = colorMatIdDict
				end

				FashionSlot.RefreshPlayerColoringInfoDict(fashionId, tempColorSchemeInfoList and {
					tempColorSchemeInfoList[colorType]
				} or {})

				if cb then
					cb()
				end
			else
				print_error("AskSetFashionColoringSchemeInfos failed  err = " .. gCS.Error.GetNameById(err))
			end
		end
	end,
	AskApplyFashionColoringSchemeInfos = function (self, fashionId, planId, colorSchemeInfoList, cb)
		local applyFashionColoringSchemeIdDict = {
			[fashionId] = planId
		}
		slot6 = gClientToGameDelegate

		slot6:AskApplyFashionColoringSchemeInfos(applyFashionColoringSchemeIdDict).Callback = function (err, data)
			if err ~= MessageConfig.Ok then
				local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
				local fashionInfo = fashionInfoDict[fashionId]

				if fashionInfo then
					fashionInfo.ApplyColoringSchemeId = planId
				end

				infoModule.SyncApplyFashionColoringSchemeInfos(fashionId, planId)

				local tempColorSchemeInfoList = table.clone(colorSchemeInfoList)

				for i, tempColorSchemeInfo in pairs(tempColorSchemeInfoList) do
					local colorMatIdDict = {}

					for coloringType, colorCfgId in pairs(tempColorSchemeInfo.ColoringType2ColorIdDict) do
						local index = gDressDyeManager:GetColorMatList(coloringType)

						if index then
							colorMatIdDict[index] = colorCfgId
						end
					end

					tempColorSchemeInfo.ColoringType2ColorIdDict = colorMatIdDict
				end

				FashionSlot.RefreshPlayerColoringInfoDict(fashionId, tempColorSchemeInfoList and {
					tempColorSchemeInfoList[planId]
				} or {})
			else
				print_error("AskSetFashionColoringSchemeInfos failed  err = " .. gCS.Error.GetNameById(err))
			end

			if cb then
				cb()
			end
		end
	end,
	AskBuyFashion = function (self, shopId, CommodityID, cb)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				if cb then
					cb()
				end
			else
				print_error("NPC商店购买商品失败，commodityId=" .. CommodityID, gCS.Error.GetNameById(err))
			end
		end

		infoModule.AskBuyFashion(shopId, CommodityID, luaCb)
	end,
	AskSetSpiritFashions = function (self, cb, spiritId, unit)
		infoModule.AskSetSpiritFashions(spiritId, cb, unit)
	end,
	AskFavoriteFashions = function (self, addFashionId, removeFashionId, cb)
		addFashionId = addFashionId and gDressManager:GetBelongMainFashionId(addFashionId)
		removeFashionId = removeFashionId and gDressManager:GetBelongMainFashionId(removeFashionId)

		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				local FavoriteFashionIdList = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionIdList

				if addFashionId then
					FavoriteFashionIdList.Count = FavoriteFashionIdList.Count + 1
					FavoriteFashionIdList.Length = FavoriteFashionIdList.Length + 1

					table.insert(FavoriteFashionIdList, addFashionId)
				end

				if removeFashionId then
					for i = 1, FavoriteFashionIdList.Count do
						if FavoriteFashionIdList[i] ~= removeFashionId then
							FavoriteFashionIdList.Count = FavoriteFashionIdList.Count - 1
							FavoriteFashionIdList.Length = FavoriteFashionIdList.Length - 1

							table.remove(FavoriteFashionIdList, i)

							break
						end
					end
				end

				if cb then
					cb()
				end
			else
				print_error("AskFavoriteFashions failed, error =", gCS.Error.GetNameById(err))
			end
		end

		infoModule.AskFavoriteFashions(addFashionId, removeFashionId, luaCb)
	end,
	AskFavoriteFashionSuits = function (self, addSuitId, removeSuitId, cb)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				local FavoriteFashionSuitIdList = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionSuitIdList

				if addSuitId then
					FavoriteFashionSuitIdList.Count = FavoriteFashionSuitIdList.Count + 1

					table.insert(FavoriteFashionSuitIdList, addSuitId)
				end

				if removeSuitId then
					for i = 1, FavoriteFashionSuitIdList.Count do
						if FavoriteFashionSuitIdList[i] ~= removeSuitId then
							FavoriteFashionSuitIdList.Count = FavoriteFashionSuitIdList.Count - 1

							table.remove(FavoriteFashionSuitIdList, i)

							break
						end
					end
				end

				if cb then
					cb()
				end
			else
				print_error("AskFavoriteFashionSuits failed, error =", gCS.Error.GetNameById(err))
			end
		end

		infoModule.AskFavoriteFashionSuits(addSuitId, removeSuitId, luaCb)
	end,
	_containsInTable = function (self, t, val)
		for i = 1, #t do
			if t[i] ~= val then
				return true
			end
		end

		return false
	end,
	_removeFromTable = function (self, t, val)
		for i = 1, #t do
			if t[i] ~= val then
				table.remove(t, i)

				return true
			end
		end

		return false
	end,
	_containsInFavList = function (self, list, val)
		for i = 1, list.Count do
			if list[i] ~= val then
				return true
			end
		end

		return false
	end,
	RecordFavoriteFashionChange = function (self, fashionId, isAdd)
		fashionId = gDressManager:GetBelongMainFashionId(fashionId)
		local FavoriteFashionIdList = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionIdList

		if isAdd then
			if self._removeFromTable(self, self.pendingRemoveFashionIds, fashionId) then
				-- Nothing
			elseif not self._containsInTable(self, self.pendingAddFashionIds, fashionId) then
				table.insert(self.pendingAddFashionIds, fashionId)
			end

			if not self._containsInFavList(self, FavoriteFashionIdList, fashionId) then
				FavoriteFashionIdList.Count = FavoriteFashionIdList.Count + 1
				FavoriteFashionIdList.Length = FavoriteFashionIdList.Length + 1

				table.insert(FavoriteFashionIdList, fashionId)
			end
		else
			if self._removeFromTable(self, self.pendingAddFashionIds, fashionId) then
				-- Nothing
			elseif not self._containsInTable(self, self.pendingRemoveFashionIds, fashionId) then
				table.insert(self.pendingRemoveFashionIds, fashionId)
			end

			for i = 1, FavoriteFashionIdList.Count do
				if FavoriteFashionIdList[i] ~= fashionId then
					FavoriteFashionIdList.Count = FavoriteFashionIdList.Count - 1
					FavoriteFashionIdList.Length = FavoriteFashionIdList.Length - 1

					table.remove(FavoriteFashionIdList, i)

					break
				end
			end
		end
	end,
	RecordFavoriteSuitChange = function (self, suitId, isAdd)
		local FavoriteFashionSuitIdList = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionSuitIdList

		if isAdd then
			if self._removeFromTable(self, self.pendingRemoveSuitIds, suitId) then
				-- Nothing
			elseif not self._containsInTable(self, self.pendingAddSuitIds, suitId) then
				table.insert(self.pendingAddSuitIds, suitId)
			end

			if not self._containsInFavList(self, FavoriteFashionSuitIdList, suitId) then
				FavoriteFashionSuitIdList.Count = FavoriteFashionSuitIdList.Count + 1

				table.insert(FavoriteFashionSuitIdList, suitId)
			end
		else
			if self._removeFromTable(self, self.pendingAddSuitIds, suitId) then
				-- Nothing
			elseif not self._containsInTable(self, self.pendingRemoveSuitIds, suitId) then
				table.insert(self.pendingRemoveSuitIds, suitId)
			end

			for i = 1, FavoriteFashionSuitIdList.Count do
				if FavoriteFashionSuitIdList[i] ~= suitId then
					FavoriteFashionSuitIdList.Count = FavoriteFashionSuitIdList.Count - 1

					table.remove(FavoriteFashionSuitIdList, i)

					break
				end
			end
		end
	end,
	FlushFavoriteFashionChanges = function (self, cb)
		if #self.pendingAddFashionIds ~= 0 and #self.pendingRemoveFashionIds ~= 0 then
			if cb then
				cb()
			end

			return
		end

		local addList = self.pendingAddFashionIds
		local removeList = self.pendingRemoveFashionIds
		self.pendingAddFashionIds = {}
		self.pendingRemoveFashionIds = {}

		infoModule.AskFavoriteFashionsBatch(addList, removeList, function (err)
			if err == MessageConfig.Ok then
				print_error("FlushFavoriteFashionChanges failed, error =", gCS.Error.GetNameById(err))

				local FavoriteFashionIdList = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionIdList

				for _, id in ipairs(addList) do
					for i = 1, FavoriteFashionIdList.Count do
						if FavoriteFashionIdList[i] ~= id then
							FavoriteFashionIdList.Count = FavoriteFashionIdList.Count - 1
							FavoriteFashionIdList.Length = FavoriteFashionIdList.Length - 1

							table.remove(FavoriteFashionIdList, i)

							break
						end
					end
				end

				for _, id in ipairs(removeList) do
					FavoriteFashionIdList.Count = FavoriteFashionIdList.Count + 1
					FavoriteFashionIdList.Length = FavoriteFashionIdList.Length + 1

					table.insert(FavoriteFashionIdList, id)
				end
			end

			if cb then
				cb()
			end
		end)
	end,
	FlushFavoriteSuitChanges = function (self, cb)
		if #self.pendingAddSuitIds ~= 0 and #self.pendingRemoveSuitIds ~= 0 then
			if cb then
				cb()
			end

			return
		end

		local addList = self.pendingAddSuitIds
		local removeList = self.pendingRemoveSuitIds
		self.pendingAddSuitIds = {}
		self.pendingRemoveSuitIds = {}

		infoModule.AskFavoriteFashionSuitsBatch(addList, removeList, function (err)
			if err == MessageConfig.Ok then
				print_error("FlushFavoriteSuitChanges failed, error =", gCS.Error.GetNameById(err))

				local FavoriteFashionSuitIdList = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionSuitIdList

				for _, id in ipairs(addList) do
					for i = 1, FavoriteFashionSuitIdList.Count do
						if FavoriteFashionSuitIdList[i] ~= id then
							FavoriteFashionSuitIdList.Count = FavoriteFashionSuitIdList.Count - 1

							table.remove(FavoriteFashionSuitIdList, i)

							break
						end
					end
				end

				for _, id in ipairs(removeList) do
					FavoriteFashionSuitIdList.Count = FavoriteFashionSuitIdList.Count + 1

					table.insert(FavoriteFashionSuitIdList, id)
				end
			end

			if cb then
				cb()
			end
		end)
	end,
	AskSetSpiritWearFashionHiddenParts = function (self, spiritId, hiddenParts, editHiddenParts, cb)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
				spiritFashionsInfoDict[spiritId].SpiritWearFashionsInfo.HiddenParts = hiddenParts
				spiritFashionsInfoDict[spiritId].SpiritWearFashionsInfo.EditedHiddenParts = editHiddenParts

				if cb then
					cb()
				end
			else
				print_error("AskSetSpiritWearFashionHiddenParts failed  err = " .. gCS.Error.GetNameById(err))

				if cb then
					cb()
				end
			end
		end

		infoModule.AskSetSpiritWearFashionHiddenParts(spiritId, hiddenParts, editHiddenParts, luaCb)
	end,
	AskSetSpiritFunctionSuitSchemeInfo = function (self, spiritId, functionSuitId, isBatch, suitSchemeInfo, callBack)
		local tempSuitInfo = {
			WearFashionInfoList = {},
			WearFashionEditInfoList = {}
		}

		for i = 0, suitSchemeInfo.WearFashionInfoList.Count - 1 do
			if gDressManager.ConflictBaseFashions[spiritId].gloves == suitSchemeInfo.WearFashionInfoList[i].FashionId then
				table.insert(tempSuitInfo.WearFashionInfoList, suitSchemeInfo.WearFashionInfoList[i])

				break
			end
		end

		if suitSchemeInfo.WearFashionEditInfoList then
			for i = 0, suitSchemeInfo.WearFashionEditInfoList.Count - 1 do
				if gDressManager.ConflictBaseFashions[spiritId].gloves == suitSchemeInfo.WearFashionEditInfoList[i].FashionId then
					table.insert(tempSuitInfo.WearFashionEditInfoList, suitSchemeInfo.WearFashionEditInfoList[i])

					break
				end
			end
		end

		local luaCb = function(err, modifySpiritIdList)
			if err ~= MessageConfig.Ok then
				if isBatch then
					for i = 0, modifySpiritIdList.Count - 1 do
						OnSetSpiritFunctionSuitSchemeInfo(modifySpiritIdList[i], functionSuitId, tempSuitInfo)
					end
				else
					OnSetSpiritFunctionSuitSchemeInfo(spiritId, functionSuitId, tempSuitInfo)
				end
			else
				print_error("AskSetSpiritFunctionSuitSchemeInfo failed  err = " .. gCS.Error.GetNameById(err))
			end

			if callBack then
				callBack()
			end
		end

		infoModule.AskSetSpiritFunctionSuitSchemeInfo(spiritId, functionSuitId, isBatch, suitSchemeInfo.WearFashionInfoList, suitSchemeInfo.WearFashionEditInfoList, luaCb)
	end,
	AskSetSpiritCustomSuitSchemeInfo = function (self, spiritId, schemeIndex, cb, joinRandomPool)
		local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
		local spiritWearFashionsInfo = table.clone(spiritFashionsInfoDict[spiritId].SpiritWearFashionsInfo)

		for i = 1, spiritWearFashionsInfo.WearFashionInfoList.Count do
			if gDressManager.ConflictBaseFashions[spiritId].gloves ~= spiritWearFashionsInfo.WearFashionInfoList[i].FashionId then
				table.remove(spiritWearFashionsInfo.WearFashionInfoList, i)

				spiritWearFashionsInfo.WearFashionInfoList.Length = spiritWearFashionsInfo.WearFashionInfoList.Length - 1
				spiritWearFashionsInfo.WearFashionInfoList.Count = spiritWearFashionsInfo.WearFashionInfoList.Count - 1

				break
			end
		end

		spiritWearFashionsInfo.JoinRandomPool = joinRandomPool
		local info = spiritFashionsInfoDict[spiritId].FashionCustomSuitSchemeInfos[schemeIndex]

		if info then
			spiritWearFashionsInfo.SchemeName = info.SchemeName
		end

		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				spiritFashionsInfoDict[spiritId].FashionCustomSuitSchemeInfos[schemeIndex] = spiritWearFashionsInfo
			else
				print_error("AskSetSpiritCustomSuitSchemeInfo failed  err = " .. gCS.Error.GetNameById(err))
			end

			if cb then
				cb()
			end
		end

		infoModule.AskSetSpiritCustomSuitSchemeInfo(spiritId, schemeIndex, joinRandomPool, luaCb)
	end,
	AskModifySpiritCustomSuitSchemeName = function (self, spiritId, schemeIndex, schemeName, callBack)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				gDressManager:SetCustomSuitSchemeName({
					spiritId = spiritId
				}, schemeIndex, schemeName)

				if callBack then
					callBack()
				end
			else
				print_error("AskModifySpiritCustomSuitSchemeName failed  err = " .. gCS.Error.GetNameById(err))
			end
		end

		infoModule.AskModifySpiritCustomSuitSchemeName(spiritId, schemeIndex, schemeName, luaCb)
	end,
	AskUnlockFashionSuitSlot = function (self, spiritId, unlockSlotCount, cb)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
				local spiritFashionsInfo = spiritFashionsInfoDict[spiritId]
				spiritFashionsInfo.UnlockSuitSlotCount = spiritFashionsInfo.UnlockSuitSlotCount + unlockSlotCount

				if cb then
					cb()
				end
			else
				print_error("AskUnlockFashionSuitSlot failed  err = " .. tostring(MessageConfig.GetConfig(err).Content))
			end
		end

		infoModule.AskUnlockFashionSuitSlot(spiritId, unlockSlotCount, luaCb)
	end,
	AskUnlockFashionDyeSlot = function (self, fashionId, unlockSlotCount, cb)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
				local fashionInfo = fashionInfoDict[fashionId]
				fashionInfo.UnlockColoringSlotCount = fashionInfo.UnlockColoringSlotCount + unlockSlotCount

				if cb then
					cb()
				end
			else
				print_error("AskUnlockFashionDyeSlot failed  err = " .. tostring(MessageConfig.GetConfig(err).Content))
			end
		end

		infoModule.AskUnlockFashionDyeSlot(fashionId, unlockSlotCount, luaCb)
	end,
	AskSetSpiritFashionVariantPreference = function (self, spiritId, fashionId, variantFashionId, cb)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
				spiritFashionsInfoDict[spiritId].MainFashionId2VariantFashionIdDict[fashionId] = variantFashionId

				if cb then
					cb()
				end
			end
		end

		infoModule.AskSetSpiritFashionVariantPreference(spiritId, fashionId, variantFashionId, luaCb)
	end,
	AskReadFashions = function (self, fashionIdList, cb)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
				local fashionInfo = nil

				for _, fashionId in ipairs(fashionIdList) do
					fashionInfo = fashionInfoDict[fashionId]

					if fashionInfo then
						fashionInfo.Status = 0
					end
				end

				if cb then
					cb()
				end
			else
				print_error("AskReadFashion failed  err = " .. gCS.Error.GetNameById(err))
			end
		end

		infoModule.AskReadFashions(fashionIdList, luaCb)
	end,
	AskReadFashionSuits = function (self, fashionSuitIdList, cb)
		local luaCb = function(err)
			if err ~= MessageConfig.Ok then
				local fashionIdList = {}

				for i = 1, #fashionSuitIdList do
					local cfg = FashionSuitConfig.GetConfig(fashionSuitIdList[i])

					if cfg then
						for t = 1, #cfg.FashionIdList do
							table.insert(fashionIdList, cfg.FashionIdList[t])
						end
					end
				end

				local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
				local fashionInfo = nil

				for _, fashionId in ipairs(fashionIdList) do
					fashionInfo = fashionInfoDict[fashionId]

					if fashionInfo then
						fashionInfo.Status = 0
					end
				end

				if cb then
					cb()
				end
			else
				print_error("AskReadFashionSuits failed  err = " .. gCS.Error.GetNameById(err))
			end
		end

		infoModule.AskReadFashionSuits(fashionSuitIdList, luaCb)
	end,
	SyncFashionInfoDict = function (self, fashionInfoDict)
		gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict = fashionInfoDict
	end,
	SyncAddOrUpdateFashion = function (self, fashionInfo)
		if gPlayerManager.infoMinor.bindData.PlayerFashionsInfo ~= nil then
			print_error("PlayerFashionsInfo is nil")

			return
		end

		local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
		local isNew = fashionInfoDict[fashionInfo.FashionId] ~= nil
		fashionInfoDict[fashionInfo.FashionId] = fashionInfo

		if isNew then
			-- Nothing
		end
	end,
	SyncAddOrUpdateFashionList = function (self, fashionInfoList)
		for i = 1, fashionInfoList.Count do
			self.SyncAddOrUpdateFashion(self, fashionInfoList[i])
		end
	end,
	SyncRemoveFashion = function (self, fashionId)
		if gPlayerManager.infoMinor.bindData.PlayerFashionsInfo ~= nil then
			print_error("PlayerFashionsInfo is nil")

			return
		end

		gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict[fashionId] = nil
	end,
	SyncRemoveFashionList = function (self, fashionIdList)
		for i = 1, fashionIdList.Count do
			self.SyncRemoveFashion(self, fashionIdList[i])
		end
	end,
	SyncFashionSuitInstance = function (self, fashionSuitId, info)
		if gPlayerManager.infoMinor.bindData.PlayerFashionsInfo ~= nil then
			return
		end

		local fashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

		if info.SuitInstanceIdList.Count <= 0 then
			fashionsInfo.FashionSuitInstanceDict = fashionsInfo.FashionSuitInstanceDict or {}
			fashionsInfo.FashionSuitInstanceDict[fashionSuitId] = info
		elseif fashionsInfo.FashionSuitInstanceDict then
			fashionsInfo.FashionSuitInstanceDict[fashionSuitId] = nil
		end
	end,
	SyncSetSpiritFashions = function (self, spiritId, spiritWearFashionsInfo)
		if table.isNilOrEmpty(gPlayerManager.infoMinor.bindData.PlayerFashionsInfo) then
			return
		end

		local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
		local curSpiritWearFashionsInfo = spiritFashionsInfoDict[spiritId]

		if curSpiritWearFashionsInfo then
			curSpiritWearFashionsInfo.SpiritWearFashionsInfo = spiritWearFashionsInfo
		else
			local customSuitSchemeCount = FashionConfig.CustomSuitSchemeCount
			spiritFashionsInfoDict[spiritId] = {
				SpiritId = spiritId,
				SpiritWearFashionsInfo = spiritWearFashionsInfo,
				FashionCustomSuitSchemeInfos = {
					Count = customSuitSchemeCount,
					Length = customSuitSchemeCount
				},
				FashionFunctionSuitSchemeInfoDict = {
					["n\\xa1\\xb7\\xa1\\xa2"] = 0,
					["0M\\x9f\\x89\\x97I"] = 0
				},
				ActiveClientTryWearSource = UX.Game.FashionWearSource.Spirit,
				UnlockSuitSlotCount = customSuitSchemeCount
			}
		end
	end,
	SyncSetSpiritActiveTryWearSource = function (self, spiritId, activeTryWearSource)
		local playerFashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

		if table.isNilOrEmpty(playerFashionsInfo) then
			return
		end

		local spiritFashionsInfoDict = playerFashionsInfo.SpiritFashionsInfoDict
		local curSpiritWearFashionsInfo = spiritFashionsInfoDict[spiritId]

		if curSpiritWearFashionsInfo then
			curSpiritWearFashionsInfo.ActiveClientTryWearSource = activeTryWearSource
		else
			local spiritFashionsInfo = CreateSpiritFashionsInfo(spiritId, FashionConfig.CustomSuitSchemeCount)
			spiritFashionsInfo.ActiveClientTryWearSource = activeTryWearSource
			spiritFashionsInfoDict[spiritId] = spiritFashionsInfo
		end
	end,
	SyncHostFashionList = function (self, spiritId, hostFashionIds)
		local playerFashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

		if table.isNilOrEmpty(playerFashionsInfo) then
			return
		end

		playerFashionsInfo.HostClosetFashionIds = hostFashionIds
	end,
	AskGameplayRentFashions = function (self, rentMap, cb)
		local luaCb = function(err)
			if err ~= LTConfig.MessageConfig.Ok then
				if cb then
					cb()
				end
			else
				print_error("AskGameplayRentFashions failed, err=" .. gCS.Error.GetNameById(err))

				if cb then
					cb(err)
				end
			end
		end

		infoModule.AskGameplayRentFashions(rentMap, luaCb)
	end,
	AskSetSpiritFashionsForParty = function (self, spiritId, cb, unit)
		infoModule.AskSetSpiritFashionsForGameplay(spiritId, unit, cb)
	end
}
gDressData = M
