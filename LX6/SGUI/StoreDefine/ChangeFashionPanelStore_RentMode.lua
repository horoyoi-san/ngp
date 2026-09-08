-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChangeFashionPanelStore_RentMode.lua
-- Decompiled from: 01457_ChangeFashionPanelStore_RentMode.lua_82fee91671f9.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionRentConfig = LTConfig.FashionRentConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local PartyConfig = LTConfig.PartyConfig
local PartyPartyTypeConfig = LTConfig.PartyPartyTypeConfig
local FashionFunctionSuitConfig = LTConfig.FashionFunctionSuitConfig
local M = C_ChangeFashionPanelStore

M.DefineRentVariables = function(self)
	self.partyId = nil
	self.spiritList = nil
	self.currentCharacterIndex = 1
	self.characterDressData = {}
	self.rentCb = nil
end

M.InitRentMode = function(self, data)
	if data then
		self.rentInitData = data
	end

	local initData = self.rentInitData

	if not initData or not initData.spiritList or #initData.spiritList ~= 0 then
		print_error("[ChangeFashionPanelStore] InitRentMode: spiritList 为空，无法进入租借模式")

		return
	end

	if not initData.partyId then
		print_error("[ChangeFashionPanelStore] InitRentMode: partyId 为空，无法进入租借模式")
	end

	self.partyId = initData.partyId
	self.bindData.showFashionToggleCtrl = self.showFashionToggleCtrlEnum.show

	self.bindData.fashionToggleList:SetSimpleList(2)

	self.currentToggleIndex = self.WEAR_SOURCE.OWN

	self.bindData.fashionToggleList:SelectItem(self.currentToggleIndex - 1, false)
	self.SubGroup.CommonDressTooltip:Init({
		collectClickCb = function ()
			self:OnCollectClick()
		end,
		dyeClickCb = function ()
			self:OnDyeClick()
		end,
		adjustClickCb = function ()
			self:OnAdjustClick()
		end,
		suitFashionClickCb = function (fashionId, part, propPart)
			self:OnSuitFashionClick(fashionId, part, propPart)
		end,
		spiritContext = self.spiritContext
	})
	self:InitFashionRentComp()

	if not table.isNilOrEmpty(initData.tagIdList) then
		self.bindData.showTaskCtrl = self.showTaskCtrlEnum.show

		self.SubGroup.CommonDressTaskPart:SetTagIdList(initData.tagIdList)

		self.bindData.showTaskCtrl = self.showTaskCtrlEnum.show

		self.SubGroup.CommonDressTaskPart:SetTaskData(LTConfig.PartyConfig.PartyTagText, nil)
		self.SubGroup.CommonDressTaskPart:SetShowRecommend(true)
	end

	local validList = self.ValidateSpiritList(self, initData.spiritList)

	if #validList ~= 0 then
		print_error("[ChangeFashionPanelStore] spiritList 中无合法角色")
		gPanelManager:Close(self.m_Id)

		return
	end

	local isRefresh = self.spiritList == nil
	self.spiritList = validList
	self.rentCb = initData.rentCb

	if not isRefresh then
		self.characterDressData = {}
	end

	local currentSpiritId = self.spiritContext and self.spiritContext.spiritId or 0
	self.currentCharacterIndex = 1

	for i, spiritId in ipairs(self.spiritList) do
		if not isRefresh or spiritId ~= currentSpiritId then
			self.characterDressData[spiritId] = {
				["[\\xb5\\x81\\x8dD"] = false,
				wearSource = self.WEAR_SOURCE.OWN
			}
		end

		if spiritId ~= currentSpiritId then
			self.currentCharacterIndex = i
		end
	end

	self.bindData.showCharacterOrderCtrl = self.showCharacterOrderCtrlEnum.show

	self.bindData.characterList:SetSimpleList(#self.spiritList * 2 - 1)
	self.bindData.characterList:SelectItem((self.currentCharacterIndex - 1) * 2, false)

	local bodyType = self.spiritContext and self.spiritContext.spiritInfo and self.spiritContext.spiritInfo.CameraBodyType

	if bodyType and self.partyId then
		local functionSuitId = self.ResolvePartyFunctionSuitId(self, self.partyId, bodyType)

		if functionSuitId then
			local suitInfo = self.GetOrCreateFunctionSuitInfo(self, functionSuitId, self.spiritContext)

			if suitInfo and suitInfo.FashionIdList then
				gDressManager:DressNewFashionListAndEdit(suitInfo.FashionIdList, suitInfo.FashionEditList, self.spiritContext)
			end
		end
	end

	self.RefreshByToggle(self)
end

M.OnRefreshRentMode = function(self)
	gDressManager:CheckClearFashionPart(self.spiritContext)

	self.currentWearSource = self.WEAR_SOURCE.OWN
	self.suitId = 0
end

M.DestroyRentMode = function(self)
	if not self.settled then
		gDressManager:CleanupDressState(self.spiritContext, true, self.recordSpriteId)
		gDressManager:ClearSteps()
		gUnitStateMgr:ResetMyStateAndClearMove(true)
	end

	self.HideFashionRentComp(self)

	self.spiritList = nil
	self.characterDressData = {}
	self.rentCb = nil
	self.partyId = nil
end

M.InitFashionRentComp = function(self)
	self.SubGroup.FashionRentComp:Init({
		rentClickCb = function (rentSuitId)
			self:OnRentBtnClick(rentSuitId)
		end,
		nextClickCb = function ()
			self:OnNextBtnClick()
		end
	})

	self.bindData.isShowRentCtrl = self.isShowRentCtrlEnum.show
	self.SubGroup.FashionRentComp.bindData.showMoneyCtrl = self.SubGroup.FashionRentComp.showMoneyCtrlEnum.show
	self.SubGroup.FashionRentComp.bindData.priceText = "0"
	self.SubGroup.FashionRentComp.bindData.showFinishCtrl = self.SubGroup.FashionRentComp.showFinishCtrlEnum.hide
	self.SubGroup.FashionRentComp.bindData.showNextCtrl = self.SubGroup.FashionRentComp.showNextCtrlEnum.hide
end

M.HideFashionRentComp = function(self)
	self.SubGroup.FashionRentComp:ExitRentMode()

	self.bindData.isShowRentCtrl = self.isShowRentCtrlEnum.hide
end

M.RefreshRentTooltipState = function(self)
	if self.fashionChangeType == gClientConst.FashionChangeType.Rent then
		return
	end

	local rentComp = self.SubGroup.FashionRentComp
	local totalPrice = 0
	local consumableId = nil
	local isLack = false
	totalPrice, consumableId = self.CalcTotalRentPrice(self)

	if consumableId and totalPrice <= 0 then
		local ownedAmount = gCommonItemManager:GetPackItemNum(consumableId)
		isLack = ownedAmount <= totalPrice
	end

	rentComp.bindData.priceText = tostring(totalPrice)
	rentComp.bindData.moneyLackCtrl = isLack and rentComp.moneyLackCtrlEnum._true or rentComp.moneyLackCtrlEnum._false
	local currentSpiritId = self.spiritList[self.currentCharacterIndex]
	local undoneCount = 0

	for _, spiritId in ipairs(self.spiritList) do
		if spiritId == currentSpiritId then
			local data = self.characterDressData[spiritId]

			if data and not data.isDone then
				undoneCount = undoneCount + 1
			end
		end
	end

	local isLastCharacter = undoneCount ~= 0

	if isLastCharacter then
		rentComp.bindData.showFinishCtrl = rentComp.showFinishCtrlEnum.show
		rentComp.bindData.showNextCtrl = rentComp.showNextCtrlEnum.hide
	else
		rentComp.bindData.showFinishCtrl = rentComp.showFinishCtrlEnum.hide
		rentComp.bindData.showNextCtrl = rentComp.showNextCtrlEnum.show
	end

	rentComp.rentSuitId = self.currentWearSource ~= self.WEAR_SOURCE.BORROWED and self.suitId and self.suitId <= 0 and self.suitId or nil
	self.SubGroup.CommonDressTooltip.isRentMode = self.currentToggleIndex ~= self.WEAR_SOURCE.BORROWED and self.suitId and self.suitId >= 0
end

M.ValidateSpiritList = function(self, inputList)
	local validList = {}

	for _, spiritId in ipairs(inputList) do
		local cfg = FightSpiritConfig.GetConfig(spiritId)

		if not cfg then
			print_error("[ChangeFashionPanelStore] spiritId=" .. tostring(spiritId) .. " 在 FightSpiritConfig 中不存在，已剔除")
		else
			table.insert(validList, spiritId)
		end
	end

	return validList
end

M.OnGetCharacterListTIndex = function(self, index)
	if index % 2 ~= 0 then
		return 0
	else
		return 1
	end
end

M.OnRenderCharacterList = function(self, btn, index)
	if index % 2 ~= 1 then
		return
	end

	local dataIndex = index / 2 + 1
	local spiritId = self.spiritList and self.spiritList[dataIndex]

	if not spiritId then
		return
	end

	local store = gStoreManager:GetStoreGroup("FashionCharacterOrderTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if spiritCfg then
		store.characterIconId = spiritCfg.SHeadIconID
	end

	local dressData = self.characterDressData[spiritId]

	if dataIndex ~= self.currentCharacterIndex then
		store.stateCtrl = 1
	elseif dressData and dressData.isDone then
		store.stateCtrl = 0
	else
		store.stateCtrl = 2
	end
end

M.OnClickCharacterItem = function(self, btn, index)
	if index % 2 ~= 1 then
		return
	end

	local targetIndex = index / 2 + 1

	if targetIndex ~= self.currentCharacterIndex then
		return
	end

	self.SwitchToCharacter(self, targetIndex, false)
end

M.SwitchToCharacter = function(self, targetIndex, markCurrentDone)
	local currentSpiritId = self.spiritList[self.currentCharacterIndex]
	local targetSpiritId = self.spiritList[targetIndex]

	if not currentSpiritId or not targetSpiritId then
		return
	end

	local savedData = self.characterDressData[currentSpiritId]

	local doSwitch = function()
		if markCurrentDone then
			savedData.isDone = true
		end

		if self.currentWearSource ~= self.WEAR_SOURCE.BORROWED and self.suitId and self.suitId <= 0 then
			savedData.rentSuitId = self.suitId
			local rentCfg = self:GetRentConfigBySuitId(self.suitId)
			savedData.rentCfgId = rentCfg and rentCfg.Id or nil
			savedData.wearSource = self.WEAR_SOURCE.BORROWED
		else
			savedData.wearSource = self.currentWearSource
		end

		local targetData = self.characterDressData[targetSpiritId]

		local afterSwitch = function(unit)
			self.currentCharacterIndex = targetIndex
			self.spiritContext = gDressManager:GetSpiritContext(targetSpiritId, nil, unit)

			if self.spiritContext and not self.spiritContext.spiritInfo then
				local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(targetSpiritId)

				if spiritCfg then
					local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)
					self.spiritContext.spiritInfo = {
						Id = targetSpiritId,
						Sex = agentCfg and agentCfg.SexType or UX.Game.SexType.Male
					}
				end
			end

			self.SubGroup.CommonDressTooltip.spiritContext = self.spiritContext

			gDressManager:InitSteps(self.spiritContext)
			gDressManager:PrepareUnitForDress(self.spiritContext.unit)

			self.currentWearSource = targetData and targetData.wearSource or self.WEAR_SOURCE.OWN
			self.suitId = targetData and targetData.rentSuitId or 0
			self.selectFashionId = 0

			if targetData and targetData.rentSuitId then
				self.currentToggleIndex = self.WEAR_SOURCE.BORROWED
				local suitCfg = FashionSuitConfig.GetConfig(targetData.rentSuitId)

				if suitCfg and suitCfg.FashionIdList then
					gDressManager:DressSuitFashionList(suitCfg.FashionIdList, false, self.spiritContext)
				end
			else
				self.currentToggleIndex = self.WEAR_SOURCE.OWN
			end

			self.bindData.fashionToggleList:SelectItem(self.currentToggleIndex - 1, false)
			self:RefreshByToggle()
			self:RefreshCharacterList()

			if self.spiritList and self.suitId and self.suitId <= 0 then
				local suitCfg = FashionSuitConfig.GetConfig(self.suitId)

				if suitCfg then
					self.SubGroup.CommonDressTooltip:ShowSuitInfo(self.suitId)

					self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._true
				end

				self:RefreshRentTooltipState()
			end
		end

		if self.skipMovementState then
			if targetData and targetData.rentSuitId then
				local fashionInfo = self:BuildFashionInfoFromSuit(targetData.rentSuitId)

				gDressSceneManager:LoadCharacterModel(targetSpiritId, fashionInfo, nil, afterSwitch)
			else
				local fashionInfo = self:BuildFashionInfoFromFunctionSuit(targetSpiritId)

				gDressSceneManager:LoadCharacterModel(targetSpiritId, fashionInfo, nil, afterSwitch)
			end
		else
			local playerUnit = gCS.MyPlayerManager.PlayerUnit
			local onModelLoaded = nil

			onModelLoaded = function()
				playerUnit.OnLoadCompleteHandler = playerUnit.OnLoadCompleteHandler - onModelLoaded

				gCS.AnimControllerManager.PlayAction(playerUnit, 1001, 1, 9999, 0, -1, false, nil, LX6.Units.Module.AnimSource.ModelReload)
				afterSwitch(playerUnit)
			end

			playerUnit.OnLoadCompleteHandler = playerUnit.OnLoadCompleteHandler + onModelLoaded

			gBattleSpiritMgr:ResetPlayerCardId(playerUnit.Pid, targetSpiritId)
		end
	end

	if self.currentWearSource ~= self.WEAR_SOURCE.OWN then
		self.SaveToFunctionSuit(self, self.partyId, doSwitch)
	else
		doSwitch()
	end
end

M.BuildFashionInfoFromSuit = function(self, suitId)
	local fashionInfo = {
		WearFashionInfoList = {},
		WearFashionEditInfoList = {}
	}
	local suitCfg = FashionSuitConfig.GetConfig(suitId)

	if suitCfg and suitCfg.FashionIdList then
		for _, fashionId in ipairs(suitCfg.FashionIdList) do
			table.insert(fashionInfo.WearFashionInfoList, {
				FashionId = fashionId
			})
		end
	end

	return fashionInfo
end

M.BuildFashionInfoFromFunctionSuit = function(self, spiritId)
	local context = gDressManager:GetSpiritContext(spiritId)
	local bodyType = context and context.spiritInfo and context.spiritInfo.CameraBodyType

	if not bodyType or not self.partyId then
		return nil
	end

	local functionSuitId = self.ResolvePartyFunctionSuitId(self, self.partyId, bodyType)

	if not functionSuitId then
		return nil
	end

	local suitInfo = self.GetOrCreateFunctionSuitInfo(self, functionSuitId, context)

	if not suitInfo or not suitInfo.FashionIdList then
		return nil
	end

	local fashionInfo = {
		WearFashionInfoList = {},
		WearFashionEditInfoList = {}
	}
	local wearList = suitInfo.FashionIdList

	if wearList then
		for i = 0, wearList.Count - 1 do
			table.insert(fashionInfo.WearFashionInfoList, {
				FashionId = wearList[i].FashionId
			})
		end
	end

	local editList = suitInfo.FashionEditList

	if editList then
		for i = 0, editList.Count - 1 do
			local editInfo = editList[i]

			table.insert(fashionInfo.WearFashionEditInfoList, {
				FashionId = editInfo.FashionId,
				SpiritId = editInfo.SpiritId,
				Scale = editInfo.Scale,
				Offset = editInfo.Offset,
				Rotation = editInfo.Rotation
			})
		end
	end

	return fashionInfo
end

M.RefreshCharacterList = function(self)
	if not self.spiritList or #self.spiritList ~= 0 then
		return
	end

	self.bindData.characterList:SetSimpleList(#self.spiritList * 2 - 1)
	self.bindData.characterList:SelectItem((self.currentCharacterIndex - 1) * 2, false)
end

M.OnNextBtnClick = function(self)
	if not self.spiritList or #self.spiritList ~= 0 then
		return
	end

	local currentSpiritId = self.spiritList[self.currentCharacterIndex]
	local savedData = self.characterDressData[currentSpiritId]

	if savedData then
		if self.currentWearSource ~= self.WEAR_SOURCE.BORROWED and self.suitId and self.suitId <= 0 then
			savedData.rentSuitId = self.suitId
			local rentCfg = self:GetRentConfigBySuitId(self.suitId)
			savedData.rentCfgId = rentCfg and rentCfg.Id or nil
			savedData.wearSource = self.WEAR_SOURCE.BORROWED
		else
			savedData.wearSource = self.WEAR_SOURCE.OWN
		end
	end

	local nextIndex = self.FindNextUndoneCharacter(self)

	if not nextIndex then
		return
	end

	self.SwitchToCharacter(self, nextIndex, true)
end

M.FindNextUndoneCharacter = function(self)
	local count = #self.spiritList

	for offset = 1, count - 1 do
		local idx = (self.currentCharacterIndex - 1 + offset) % count + 1
		local spiritId = self.spiritList[idx]
		local data = self.characterDressData[spiritId]

		if data and not data.isDone then
			return idx
		end
	end

	return nil
end

M.InitSubStoresForRent = function(self)
	local rentSuitIds = self:BuildRentSuitList()
	local itemList = self:BuildRentFashionItemList(rentSuitIds)

	self.SubGroup.CommonDressList:Init({
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		itemList = itemList,
		spiritContext = self.spiritContext,
		suitListClickCb = function (isSelected, suitData)
			self:OnRentSuitListClick(isSelected, suitData)
		end,
		renderSuitSelectedCb = function (suitData)
			self:OnRenderSuitSelected(suitData)
		end,
		checkFashionSuitCanShowFn = function (suitId)
			return table.contains(rentSuitIds, suitId)
		end,
		checkIsWoreForSelectFn = function (fashionId)
			return self:ShouldShowSelected(fashionId)
		end,
		forceTabFilter = {
			gDressManager.DRESS_PART.SUITS
		}
	})
end

M.BuildRentSuitList = function(self)
	local rentSuitIds = {}
	local partyCfg = PartyConfig.GetConfig(self.partyId)

	if not partyCfg or not partyCfg.FashionsCanRent then
		print_error("[ChangeFashionPanelStore] BuildRentSuitList: PartyConfig 或 FashionsCanRent 为空, partyId=" .. tostring(self.partyId))

		return rentSuitIds
	end

	local fashionsCanRent = partyCfg.FashionsCanRent

	for i = 1, #fashionsCanRent do
		local rentCfg = FashionRentConfig.GetConfig(fashionsCanRent[i])

		if rentCfg and rentCfg.FashionSuitId and rentCfg.FashionSuitId <= 0 then
			table.insert(rentSuitIds, rentCfg.FashionSuitId)
		end
	end

	return rentSuitIds
end

M.BuildRentFashionItemList = function(self, rentSuitIds)
	local itemList = {}

	for _, suitId in ipairs(rentSuitIds) do
		local suitCfg = FashionSuitConfig.GetConfig(suitId)

		if suitCfg then
			if suitCfg.FashionIdList then
				for _, fashionId in ipairs(suitCfg.FashionIdList) do
					local fashionCfg = FashionConfig.GetConfig(fashionId)

					if not fashionCfg then
						-- Nothing
					elseif not gDressManager:CheckCurrentSpritShowFashion(fashionId, self.spiritContext) then
						-- Nothing
					elseif gDressManager:CheckGenderWithBodyTypeAllow(fashionId, self.spiritContext.spiritInfo) then
						local view = {
							fashionId = fashionId,
							isCollect = 0,
							isNew = false,
							ExpiredTime = 0,
							GainTime = 0,
							icon = fashionCfg.Icon,
							quality = fashionCfg.Quality,
							Part = fashionCfg.Part,
							Types = fashionCfg.Types,
							PropPart = fashionCfg.PropPart,
							Sex = fashionCfg.Gender,
							Name = fashionCfg.Name,
							EditId = 0,
							BelongBrand = fashionCfg.BelongBrand,
							Tags = fashionCfg.Tags,
							isAvailable = 1
						}

						table.insert(itemList, view)

						view.id = #itemList
					end
				end
			end
		end
	end

	return itemList
end

M.GetRentConfigBySuitId = function(self, suitId)
	for index = 0, FashionRentConfig.count - 1 do
		local cfg = FashionRentConfig.LoadAt(index)

		if cfg and cfg.FashionSuitId ~= suitId then
			return cfg
		end
	end

	return nil
end

M.OnRentSuitListClick = function(self, isSelected, data)
	if isSelected then
		self.suitId = data.suitId

		self.SubGroup.CommonDressTooltip:ShowSuitInfo(data.suitId, data)

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._true

		if self:NeedLocalSourceSwitch(self.WEAR_SOURCE.BORROWED) then
			gDressManager:CheckClearFashionPart(self.spiritContext)

			self.currentWearSource = self.WEAR_SOURCE.BORROWED
		end

		gDressManager:DressSuitFashionList(data.fashionList, false, self.spiritContext)
		self:PushSnapshot(nil, self.suitId)
	else
		self.suitId = 0

		self.SubGroup.CommonDressTooltip:ClearData()

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false

		gDressManager:RemoveFashionPart(data.fashionList, self.spiritContext)
		self:PushSnapshot(nil, 0)
	end

	self.RefreshRentTooltipState(self)
end

M.CalcTotalRentPrice = function(self)
	local totalPrice = 0
	local consumableId = nil
	local currentSpiritId = self.spiritList[self.currentCharacterIndex]

	for spiritId, data in pairs(self.characterDressData) do
		if spiritId == currentSpiritId and data.rentSuitId then
			local cfg = self.GetRentConfigBySuitId(self, data.rentSuitId)

			if cfg then
				totalPrice = totalPrice + cfg.Price
				consumableId = consumableId or cfg.ConsumableId
			end
		end
	end

	if self.currentWearSource ~= self.WEAR_SOURCE.BORROWED and self.suitId and self.suitId <= 0 then
		local cfg = self.GetRentConfigBySuitId(self, self.suitId)

		if cfg then
			totalPrice = totalPrice + cfg.Price
			consumableId = consumableId or cfg.ConsumableId
		end
	end

	return totalPrice, consumableId
end

M.OnRentBtnClick = function(self, rentSuitId)
	local currentSpiritId = self.spiritList[self.currentCharacterIndex]
	local savedData = self.characterDressData[currentSpiritId]

	if savedData then
		savedData.isDone = true

		if self.currentWearSource ~= self.WEAR_SOURCE.BORROWED and self.suitId and self.suitId <= 0 then
			savedData.rentSuitId = self.suitId
			local rentCfg = self:GetRentConfigBySuitId(self.suitId)
			savedData.rentCfgId = rentCfg and rentCfg.Id or nil
			savedData.wearSource = self.WEAR_SOURCE.BORROWED
		else
			savedData.wearSource = self.WEAR_SOURCE.OWN
		end
	end

	local totalPrice, consumableId = self.CalcTotalRentPrice(self)

	if consumableId then
		local ownedAmount = gCommonItemManager:GetPackItemNum(consumableId)

		if ownedAmount >= totalPrice then
			return
		end
	end

	local rentMap = {}

	for _, spiritId in ipairs(self.spiritList) do
		local data = self.characterDressData[spiritId]

		if data and data.rentCfgId then
			rentMap[spiritId] = data.rentCfgId
		end
	end

	local finish = function(map)
		self.settled = true

		if self.rentCb then
			self.rentCb(map)
		end

		gDressManager:ClearSelectTypeData()
		gPanelManager:Close(self.m_Id)
	end

	local sendRent = function()
		finish(rentMap)
	end

	if self.currentWearSource ~= self.WEAR_SOURCE.OWN then
		self.SaveToFunctionSuit(self, self.partyId, sendRent)
	else
		sendRent()
	end
end

M.SaveRentFashion = function(self, callBack)
	if callBack then
		callBack()
	end
end
