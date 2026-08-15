local MessageConfig = LTConfig.MessageConfig
local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionSlot = LX6.Share.FashionSlot

function CreateWearFashionInfo(FashionId)
	return {
		FashionId = FashionId or 0
	}
end

function CreateSpiritWearFashionsInfo(WearFashionInfoList, WearFashionEditInfoList, spiritId)
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
	local IsTryWear = false
	local FunctionSuitId = 0

	if spiritFashionsInfo and spiritFashionsInfo.SpiritWearFashionsInfo then
		HiddenParts = spiritFashionsInfo.SpiritWearFashionsInfo.HiddenParts
		IsTryWear = spiritFashionsInfo.SpiritWearFashionsInfo.IsTryWear
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
		IsTryWear = IsTryWear
	}
end

function CreateFashionCustomSuitSchemeInfo()
	return {
		SchemeName = "",
		WearFashionInfoList = {},
		HiddenParts = FashionConfig.SelectableHiddenPartType.None
	}
end

function CreateFashionFunctionSuitSchemeInfo(WearFashionInfoList, WearFashionEditInfoList)
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

	for i = 1, fashionInfoCount do
		table.insert(tempWearFashionInfoList, WearFashionInfoList[i])
	end

	for i = 1, fashionEditCount do
		table.insert(tempWearFashionEditInfoList, WearFashionEditInfoList[i])
	end

	return {
		WearFashionInfoList = tempWearFashionInfoList,
		WearFashionEditInfoList = tempWearFashionEditInfoList,
		HiddenParts = FashionConfig.SelectableHiddenPartType.None
	}
end

function CreateSpiritFashionsInfo(spiritId, customSuitSchemeCount)
	local fashionCustomSuitSchemeInfos = {
		Count = customSuitSchemeCount,
		Length = customSuitSchemeCount
	}

	for i = 1, customSuitSchemeCount do
		table.insert(fashionCustomSuitSchemeInfos, CreateFashionCustomSuitSchemeInfo())
	end

	return {
		EnableClientTryWearCount = 0,
		SpiritId = spiritId,
		FashionCustomSuitSchemeInfos = fashionCustomSuitSchemeInfos,
		FashionFunctionSuitSchemeInfoDict = {
			Count = 0,
			Length = 0
		},
		SpiritWearFashionsInfo = CreateSpiritWearFashionsInfo({}, {}, spiritId)
	}
end

local M = {
	AskBuyFashion = function (self, CommodityID, cb)
		gClientToGameDelegate:AskBuyCommodity(CommodityID, 1).Callback = function (err)
			if err == MessageConfig.Ok then
				if cb then
					cb()
				end
			else
				print_error("NPC商店购买商品失败，commodityId=" .. CommodityID, err)
			end
		end
	end,
	AskBuyCommodities = function (self, commodityList, cb)
		gClientToGameDelegate:AskBuyCommodities(commodityList).Callback = function (err)
			if err == MessageConfig.Ok then
				if cb then
					cb()
				end
			else
				local msg = "["

				for commodityId in ipairs(commodityList) do
					msg = msg .. commodityId .. ","
				end

				msg = msg .. "]"

				print_error("NPC商店购买商品list失败, commodityList=" .. msg, err)
			end
		end
	end,
	AskReadCommodities = function (self, commodityidlist, cb)
		if table.isNilOrEmpty(commodityidlist) then
			return
		end

		gClientToGameDelegate:AskReadCommodities(commodityidlist).Callback = function (err)
			if err == MessageConfig.Ok and cb then
				cb()
			end
		end
	end,
	AskSetSpiritFashions = function (self, cb)
		local spriteFashionInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

		if table.isNilOrEmpty(spriteFashionInfo) then
			if cb then
				cb()
			end

			return
		end

		local wearFashionList = {}
		local WearFashionInfoList = {}

		for i = 1, #spriteFashionInfo.WearFashionInfoList do
			local info = spriteFashionInfo.WearFashionInfoList[i]
			local cfg = FashionConfig.GetConfig(info.FashionId)

			if cfg then
				table.insert(WearFashionInfoList, info)
				table.insert(wearFashionList, info.FashionId)
			end
		end

		local wearEditFashionList = {}
		local WearFashionEditInfoList = {}

		for i = 1, #spriteFashionInfo.WearFashionEditInfoList do
			local info = spriteFashionInfo.WearFashionEditInfoList[i]
			local cfg = FashionConfig.GetConfig(info.FashionId)

			if cfg and table.contains(wearFashionList, info.FashionId) then
				table.insert(WearFashionEditInfoList, info)
				table.insert(wearEditFashionList, info.FashionId)
			end
		end

		local addList = gDressManager:CheckAddFashionDefault(wearFashionList)

		for i = 1, #addList do
			local wearInfo = CreateWearFashionInfo(addList[i])

			table.insert(WearFashionInfoList, wearInfo)
		end

		local spiritwearfashionsinfo = CreateSpiritWearFashionsInfo(WearFashionInfoList, WearFashionEditInfoList, gDressManager.CurrentSpiritId)

		if gDressManager:IsPlayerWearFashionList(wearFashionList) and gDressManager:IsDressEditNoChange(wearEditFashionList) then
			if cb then
				cb()
			end

			return
		end

		gClientToGameDelegate:AskSetSpiritFashions(gDressManager.CurrentSpiritId, spiritwearfashionsinfo).Callback = function (err, data, data2)
			if cb then
				cb()
			end

			if err ~= 0 then
				print_error("AskModifySpiritWearFashions failed, error =", gCS.Error.GetNameById(err))
			end
		end
	end
}

function M:AskModifySpiritWearFashionsOnlyWear(fashionIdList, unwearfashionidlist)
	local wearfashioninfolist = {}

	if not table.isNilOrEmpty(fashionIdList) then
		for i = 1, #fashionIdList do
			local wearInfo = CreateWearFashionInfo({
				FashionId = fashionIdList[i]
			})

			table.insert(wearfashioninfolist, wearInfo)
		end
	end

	local hiddenParts = FashionConfig.SelectableHiddenPartType.None

	gClientToGameDelegate:AskModifySpiritWearFashionsOnlyWear(self.CurrentSpiritId, hiddenParts, unwearfashionidlist, wearfashioninfolist).Callback = function (err, data, data2)
		if err == 0 then
			local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
			local spiritFashionsInfo = spiritFashionsInfoDict and spiritFashionsInfoDict[self.CurrentSpiritId]

			if spiritFashionsInfo == nil then
				return nil
			end

			local wearFashionInfoList = spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionInfoList

			for i = 1, data2.Count do
				local hasInfo = false

				for t = 1, wearFashionInfoList.Count do
					if wearFashionInfoList[t].FashionId == data2[i].FashionId then
						hasInfo = true

						break
					end
				end

				if not hasInfo then
					wearFashionInfoList.Count = wearFashionInfoList.Count + 1
					wearFashionInfoList.Length = wearFashionInfoList.Length + 1

					table.insert(wearFashionInfoList, data2[i])
				end
			end
		else
			print_error("AskModifySpiritWearFashionsOnlyWear failed, error =", gCS.Error.GetNameById(err))
		end
	end
end

function M:AskModifySpiritWearFashionEditInfos(spiritid, uneditwearfashionidlist)
	local WearFashionEditInfo = {}
	local editwearfashioneditinfolist = {}

	table.insert(editwearfashioneditinfolist, WearFashionEditInfo)

	gClientToGameDelegate:AskModifySpiritWearFashionEditInfos(spiritid, uneditwearfashionidlist, editwearfashioneditinfolist).Callback = function (err, data, data2)
		if err == 0 then
			local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
			local spiritFashionsInfo = spiritFashionsInfoDict and spiritFashionsInfoDict[self.CurrentSpiritId]

			if spiritFashionsInfo == nil then
				return nil
			end

			local wearFashionEditInfoList = spiritFashionsInfo.WearFashionEditInfoList

			if wearFashionEditInfoList == nil then
				wearFashionEditInfoList = {
					Count = 0,
					Length = 0
				}
				spiritFashionsInfo.WearFashionEditInfoList = wearFashionEditInfoList
			end

			for i = 1, data2.Count do
				local hasInfo = false

				for t = 1, wearFashionEditInfoList.Count do
					if wearFashionEditInfoList[t].FashionId == data2[i].FashionId then
						hasInfo = true

						break
					end
				end

				if not hasInfo then
					wearFashionEditInfoList.Count = wearFashionEditInfoList.Count + 1
					wearFashionEditInfoList.Length = wearFashionEditInfoList.Length + 1

					table.insert(wearFashionEditInfoList, data2[i])
				end
			end
		else
			print_error("AskModifySpiritWearFashionEditInfos failed, error =", gCS.Error.GetNameById(err))
		end
	end
end

function M:AskFavoriteFashions(addFashionId, removeFashionId, cb)
	local favoritefashionidlist = {
		addFashionId
	}
	local unfavoritefashionidlist = {
		removeFashionId
	}

	gClientToGameDelegate:AskFavoriteFashions(unfavoritefashionidlist, favoritefashionidlist).Callback = function (err, data)
		if err == MessageConfig.Ok then
			local FavoriteFashionIdList = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionIdList

			if addFashionId then
				FavoriteFashionIdList.Count = FavoriteFashionIdList.Count + 1
				FavoriteFashionIdList.Length = FavoriteFashionIdList.Length + 1

				table.insert(FavoriteFashionIdList, addFashionId)
			end

			if removeFashionId then
				for i = 1, FavoriteFashionIdList.Count do
					if FavoriteFashionIdList[i] == removeFashionId then
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
end

function M:AskFavoriteFashionSuits(addSuitId, removeSuitId, cb)
	local favoritefashionsuitidlist = {
		addSuitId
	}
	local unfavoritefashionsuitidlist = {
		removeSuitId
	}

	gClientToGameDelegate:AskFavoriteFashionSuits(unfavoritefashionsuitidlist, favoritefashionsuitidlist).Callback = function (err, data)
		if err == MessageConfig.Ok then
			local FavoriteFashionSuitIdList = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FavoriteFashionSuitIdList

			if addSuitId then
				FavoriteFashionSuitIdList.Count = FavoriteFashionSuitIdList.Count + 1

				table.insert(FavoriteFashionSuitIdList, addSuitId)
			end

			if removeSuitId then
				for i = 1, FavoriteFashionSuitIdList.Count do
					if FavoriteFashionSuitIdList[i] == removeSuitId then
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
end

function M:SyncFashionInfoDict(fashionInfoDict)
	gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict = fashionInfoDict
end

function M:SyncAddFashion(fashionInfo)
	if gPlayerManager.infoMinor.bindData.PlayerFashionsInfo == nil then
		print_error("PlayerFashionsInfo is nil")

		return
	end

	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	fashionInfoDict[fashionInfo.FashionId] = fashionInfo
end

function M:SyncAddFashionList(fashionInfoList)
	for i = 1, fashionInfoList.Count do
		self:SyncAddFashion(fashionInfoList[i])
	end
end

function M:SyncSetSpiritFashions(spiritId, spiritWearFashionsInfo)
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
			EnableClientTryWearCount = 0,
			SpiritId = spiritId,
			SpiritWearFashionsInfo = spiritWearFashionsInfo,
			FashionCustomSuitSchemeInfos = {
				Count = customSuitSchemeCount,
				Length = customSuitSchemeCount
			},
			FashionFunctionSuitSchemeInfoDict = {
				Count = 0,
				Length = 0
			}
		}
	end
end

function M:SyncSetSpiritEnableTryWear(spiritId, enableClientTryWearCount)
	local playerFashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if table.isNilOrEmpty(playerFashionsInfo) then
		return
	end

	local spiritFashionsInfoDict = playerFashionsInfo.SpiritFashionsInfoDict
	local curSpiritWearFashionsInfo = spiritFashionsInfoDict[spiritId]

	if curSpiritWearFashionsInfo then
		curSpiritWearFashionsInfo.EnableClientTryWearCount = enableClientTryWearCount
	else
		local spiritFashionsInfo = CreateSpiritFashionsInfo(spiritId, FashionConfig.CustomSuitSchemeCount)
		spiritFashionsInfo.EnableClientTryWearCount = enableClientTryWearCount
		spiritFashionsInfoDict[spiritId] = spiritFashionsInfo
	end
end

function M:SyncSetTaskTryWearFashionInfo(spiritId, taskTryWearInfo)
	local playerFashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if table.isNilOrEmpty(playerFashionsInfo) then
		return
	end

	playerFashionsInfo.SpiritId2TaskTryWearInfoDict[spiritId] = taskTryWearInfo
end

function M:SyncUnSetTaskTryWearFashionInfo(spiritId)
	local playerFashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if table.isNilOrEmpty(playerFashionsInfo) then
		return
	end

	playerFashionsInfo.SpiritId2TaskTryWearInfoDict[spiritId] = nil
end

function M:AskReadFashions(fashionidlist, cb)
	gClientToGameDelegate:AskReadFashions(fashionidlist).Callback = function (err, data)
		if err == MessageConfig.Ok then
			local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
			local fashionInfo = nil

			for _, fashionId in ipairs(fashionidlist) do
				fashionInfo = fashionInfoDict[fashionId]

				if fashionInfo then
					fashionInfo.Status = 0
				end
			end

			if cb then
				cb()
			end
		else
			LX6.Utils.LogUtilsLua.SendToPopo("时装AskReadFashions failed", "leilei03")
			print_error("AskReadFashions failed")
		end
	end
end

function M:AskReadFashionSuits(fashionsuitidlist, cb)
	gClientToGameDelegate:AskReadFashionSuits(fashionsuitidlist).Callback = function (err, data)
		if err == MessageConfig.Ok then
			local fashionidlist = {}

			for i = 1, #fashionsuitidlist do
				local cfg = FashionSuitConfig.GetConfig(fashionsuitidlist[i])

				if cfg then
					for t = 1, #cfg.FashionIdList do
						table.insert(fashionidlist, cfg.FashionIdList[t])
					end
				end
			end

			local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
			local fashionInfo = nil

			for _, fashionId in ipairs(fashionidlist) do
				fashionInfo = fashionInfoDict[fashionId]

				if fashionInfo then
					fashionInfo.Status = 0
				end
			end

			if cb then
				cb()
			end
		else
			print_error("AskReadFashionSuits failed  err = " .. err)
		end
	end
end

function M:AskSetFashionColoringSchemeInfos(fashionId, colorType, colorSchemeInfoList, cb)
	local fashioncoloringschemeinfolist = {}
	local FashionColoringSchemeInfo = {
		FashionId = fashionId,
		FashionColoringSchemeInfoDict = colorSchemeInfoList
	}

	table.insert(fashioncoloringschemeinfolist, FashionColoringSchemeInfo)

	gClientToGameDelegate:AskSetFashionColoringSchemeInfos(fashioncoloringschemeinfolist).Callback = function (err, data)
		if err == MessageConfig.Ok then
			local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
			local fashionInfo = fashionInfoDict[fashionId]

			if fashionInfo then
				fashionInfo.ColoringSchemeInfoDict[colorType] = colorSchemeInfoList[colorType]
				fashionInfo.ApplyColoringSchemeId = colorType
			end

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
			print_error("AskSetFashionColoringSchemeInfos failed  err = " .. err)
		end
	end
end

function M:AskApplyFashionColoringSchemeInfos(fashionId, planId, colorSchemeInfoList, cb)
	local applyfashioncoloringschemeiddict = {
		[fashionId] = planId
	}

	gClientToGameDelegate:AskApplyFashionColoringSchemeInfos(applyfashioncoloringschemeiddict).Callback = function (err, data)
		if err == MessageConfig.Ok then
			local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
			local fashionInfo = fashionInfoDict[fashionId]

			if fashionInfo then
				fashionInfo.ApplyColoringSchemeId = planId
			end

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
			print_error("AskSetFashionColoringSchemeInfos failed  err = " .. err)
		end

		if cb then
			cb()
		end
	end
end

function M:AskResetFashionColoringSchemeInfos(fashionId, coloringIndex, cb)
	local view = {
		FashionId = fashionId
	}
	local resetFashionColoringSchemeInfo = {}

	table.insert(resetFashionColoringSchemeInfo, view)

	gClientToGameDelegate:AskResetFashionColoringSchemeInfos(resetFashionColoringSchemeInfo).Callback = function (err, data)
		if err == MessageConfig.Ok then
			local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
			local fashionInfo = fashionInfoDict[fashionId]

			if fashionInfo and fashionInfo.ColoringSchemeInfoDict and fashionInfo.ColoringSchemeInfoDict[coloringIndex] then
				fashionInfo.ColoringSchemeInfoDict[coloringIndex] = {}
			end

			if cb then
				cb()
			end
		else
			print_error("AskResetFashionColoringSchemeInfos failed  err = " .. err)
		end
	end
end

function M:AskSetSpiritWearFashionHiddenParts(spiritId, hiddenParts, editHiddenParts, cb)
	gClientToGameDelegate:AskSetSpiritWearFashionHiddenParts(spiritId, hiddenParts).Callback = function (err, data)
		if err == MessageConfig.Ok then
			local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
			spiritFashionsInfoDict[spiritId].SpiritWearFashionsInfo.HiddenParts = hiddenParts
			spiritFashionsInfoDict[spiritId].SpiritWearFashionsInfo.EditedHiddenParts = editHiddenParts

			if cb then
				cb()
			end
		else
			print_error("AskSetSpiritWearFashionHiddenParts failed  err = " .. err)

			if cb then
				cb()
			end
		end
	end
end

local function OnSetSpiritFunctionSuitSchemeInfo(spiritId, functionSuitId, suitSchemeInfo)
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

function M:AskSetSpiritFunctionSuitSchemeInfo(spiritId, functionSuitId, isBatch, suitSchemeInfo, callBack)
	local tempSuitInfo = table.clone(suitSchemeInfo)

	for i = 1, #tempSuitInfo.WearFashionInfoList do
		if gDressManager.ConflictBaseFashions[spiritId].gloves == tempSuitInfo.WearFashionInfoList[i].FashionId then
			table.remove(tempSuitInfo.WearFashionInfoList, i)

			break
		end
	end

	for i = 1, #tempSuitInfo.WearFashionEditInfoList do
		if gDressManager.ConflictBaseFashions[spiritId].gloves == tempSuitInfo.WearFashionEditInfoList[i].FashionId then
			table.remove(tempSuitInfo.WearFashionEditInfoList, i)

			break
		end
	end

	gClientToGameDelegate:AskSetSpiritFunctionSuitSchemeInfo(spiritId, functionSuitId, isBatch, tempSuitInfo).Callback = function (err, modifySpiritIdList)
		if err == MessageConfig.Ok then
			if isBatch then
				for i = 1, modifySpiritIdList.Count do
					OnSetSpiritFunctionSuitSchemeInfo(modifySpiritIdList[i], functionSuitId, tempSuitInfo)
				end
			else
				OnSetSpiritFunctionSuitSchemeInfo(spiritId, functionSuitId, tempSuitInfo)
			end

			if callBack then
				callBack()
			end
		else
			print_error("AskSetSpiritFunctionSuitSchemeInfo failed  err = " .. err)
		end
	end
end

function M:AskSetSpiritCustomSuitSchemeInfo(spiritId, schemeIndex, cb, joinRandomPool)
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = gDressManager.SpriteFashionInfoDict[spiritId]

	if spiritFashionsInfo then
		local spiritWearFashionsInfo = table.clone(spiritFashionsInfoDict[spiritId].SpiritWearFashionsInfo)

		for i = 1, spiritWearFashionsInfo.WearFashionInfoList.Count do
			if gDressManager.ConflictBaseFashions[spiritId].gloves == spiritWearFashionsInfo.WearFashionInfoList[i].FashionId then
				table.remove(spiritWearFashionsInfo.WearFashionInfoList, i)

				spiritWearFashionsInfo.WearFashionInfoList.Length = spiritWearFashionsInfo.WearFashionInfoList.Length - 1
				spiritWearFashionsInfo.WearFashionInfoList.Count = spiritWearFashionsInfo.WearFashionInfoList.Count - 1

				break
			end
		end

		spiritWearFashionsInfo.JoinRandomPool = joinRandomPool

		gClientToGameDelegate:AskSetSpiritCustomSuitSchemeInfo(spiritId, schemeIndex, spiritWearFashionsInfo).Callback = function (err, data)
			if err == MessageConfig.Ok then
				spiritFashionsInfoDict[spiritId].FashionCustomSuitSchemeInfos[schemeIndex] = spiritWearFashionsInfo
			else
				print_error("AskSetSpiritCustomSuitSchemeInfo failed  err = " .. err)
			end

			if cb then
				cb()
			end
		end
	end
end

function M:AskModifySpiritCustomSuitSchemeName(spiritId, schemeIndex, schemeName, callBack)
	gClientToGameDelegate:AskModifySpiritCustomSuitSchemeName(spiritId, schemeIndex, schemeName).Callback = function (err, data)
		if err == MessageConfig.Ok then
			gDressManager:SetCustomSuitSchemeName(spiritId, schemeIndex, schemeName)

			if callBack then
				callBack()
			end
		else
			print_error("AskModifySpiritCustomSuitSchemeName failed  err = " .. err)
		end
	end
end

gDressData = M
