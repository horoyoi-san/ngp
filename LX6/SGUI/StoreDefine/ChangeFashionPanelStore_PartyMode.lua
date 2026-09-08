-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChangeFashionPanelStore_PartyMode.lua
-- Decompiled from: 01456_ChangeFashionPanelStore_PartyMode.lua_1249f46bcd65.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local PartyConfig = LTConfig.PartyConfig
local PartyPartyTypeConfig = LTConfig.PartyPartyTypeConfig
local FashionFunctionSuitConfig = LTConfig.FashionFunctionSuitConfig
local M = C_ChangeFashionPanelStore

M.DefinePartyVariables = function(self)
	self.settled = false
	self.partyPartyId = nil
	self.partyFunctionSuitId = nil
end

M.InitPartyMode = function(self, data)
	if data then
		self.partyInitData = data
	end

	local initData = self.partyInitData

	if initData and initData.partyId then
		self.partyPartyId = initData.partyId
		local bodyType = self.spiritContext and self.spiritContext.spiritInfo and self.spiritContext.spiritInfo.CameraBodyType

		if bodyType then
			self.partyFunctionSuitId = self.ResolvePartyFunctionSuitId(self, self.partyPartyId, bodyType)
		end
	end

	if self.partyFunctionSuitId then
		local suitInfo = self.GetOrCreateFunctionSuitInfo(self, self.partyFunctionSuitId, self.spiritContext)

		if suitInfo and suitInfo.FashionIdList then
			gDressManager:DressNewFashionListAndEdit(suitInfo.FashionIdList, suitInfo.FashionEditList, self.spiritContext)
		end
	end

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

	if initData and not table.isNilOrEmpty(initData.tagIdList) then
		self.bindData.showTaskCtrl = self.showTaskCtrlEnum.show

		self.SubGroup.CommonDressTaskPart:SetTagIdList(initData.tagIdList)

		self.bindData.showTaskCtrl = self.showTaskCtrlEnum.show

		self.SubGroup.CommonDressTaskPart:SetTaskData(LTConfig.PartyConfig.PartyTagText, nil)
		self.SubGroup.CommonDressTaskPart:SetShowRecommend(true)
	end

	self.RegisterPartyEvents(self)
	self.RefreshByToggle(self)
end

M.OnRefreshPartyMode = function(self)
	gDressManager:CheckClearFashionPart(self.spiritContext)

	self.currentWearSource = self.WEAR_SOURCE.OWN
end

M.DestroyPartyMode = function(self)
	self.UnregisterPartyEvents(self)

	if not self.settled and self.currentWearSource ~= self.WEAR_SOURCE.BORROWED then
		gDressManager:CheckClearFashionPart(self.spiritContext)
	end

	self.partyFunctionSuitId = nil
	self.partyPartyId = nil
end

M.RegisterPartyEvents = function(self)
end

M.UnregisterPartyEvents = function(self)
	if self.partyMsgEvents then
		self.ClearMessageEvents(self, self.partyMsgEvents)

		self.partyMsgEvents = nil
	end
end

M.InitSubStoresForPartyCloset = function(self)
	local hostFashionIds = gDressManager:GetHostClosetFashionList()

	if table.isNilOrEmpty(hostFashionIds) then
		self.SubGroup.CommonDressList:Init({
			["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
			itemList = {},
			spiritContext = self.spiritContext
		})

		return
	end

	local itemList = self:BuildHostClosetItemList(hostFashionIds)

	self.SubGroup.CommonDressList:Init({
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		itemList = itemList,
		spiritContext = self.spiritContext,
		tabRefreshCb = function (tabData)
			self:OnTabRefresh(tabData)
		end,
		renderSuitSelectedCb = function (suitData)
			self:OnRenderSuitSelected(suitData)
		end,
		suitListClickCb = function (isSelected, suitData)
			self:OnPartySuitListClick(isSelected, suitData)
		end,
		renderItemSelectedCb = function (itemData)
			self:OnRenderItemSelected(itemData)
		end,
		itemListClickCb = function (isSelected, itemData)
			self:OnPartyItemListClick(isSelected, itemData)
		end,
		checkFashionSuitCanShowFn = function (suitId)
			return self:CheckHostClosetSuitCanShow(suitId)
		end,
		checkIsWoreForSelectFn = function (fashionId)
			return self:ShouldShowSelected(fashionId)
		end
	})
end

M.BuildHostClosetItemList = function(self, hostFashionIds)
	local itemList = {}

	for i = 1, hostFashionIds.Count do
		local fashionId = hostFashionIds[i]
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

	return itemList
end

M.CheckHostClosetSuitCanShow = function(self, suitId)
	local cfg = FashionSuitConfig.GetConfig(suitId)

	if not cfg then
		return false
	end

	local hostFashionIds = gDressManager:GetHostClosetFashionList()

	if table.isNilOrEmpty(hostFashionIds) then
		return false
	end

	for i = 1, #cfg.FashionIdList do
		if not gDressManager:IsInHostCloset(cfg.FashionIdList[i]) then
			return false
		end
	end

	return true
end

M.OnPartyItemListClick = function(self, isSelected, data)
	if isSelected then
		self.selectFashionId = data.fashionId

		self.SubGroup.CommonDressTooltip:ShowFashionInfo(data.fashionId, {
			["\\xca\\xd3\n:=\\xf4"] = false,
			["\\xb8\\xb9\n\\xbcO:\\xf7'"] = false
		})

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._true

		if self:NeedLocalSourceSwitch(self.WEAR_SOURCE.BORROWED) then
			gDressManager:CheckClearFashionPart(self.spiritContext)

			self.currentWearSource = self.WEAR_SOURCE.BORROWED
		end

		local conflictItems, addItems = gDressManager:CheckFashionConflict({
			data.fashionId
		}, self.spiritContext)

		table.insert(addItems, data.fashionId)
		gDressManager:CheckSetPropEditInfo(data.fashionId, self.spiritContext)
		gDressManager:SetFashionList(addItems, nil, self.spiritContext)
		self:PushSnapshot(self.selectFashionId, nil)
	else
		self.selectFashionId = 0

		self.SubGroup.CommonDressTooltip:ClearData()

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false

		gDressManager:RemoveFashionPart({
			data.fashionId
		}, self.spiritContext)
		self:PushSnapshot(0, nil)
	end
end

M.OnPartySuitListClick = function(self, isSelected, data)
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
		gDressManager:PlayDressSuitAction(self.suitId, self.spiritContext)
	else
		self.suitId = 0

		self.SubGroup.CommonDressTooltip:ClearData()

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false

		gDressManager:RemoveFashionPart(data.fashionList, self.spiritContext)
		self:PushSnapshot(nil, 0)
	end
end

M.SavePartyFashion = function(self, callBack)
	local spiritId = self.spiritContext.spiritId
	local unit = self.spiritContext.unit
	slot4 = gDressData

	slot4:AskSetSpiritFashionsForParty(spiritId, function (err)
		if err and err == LTConfig.MessageConfig.Ok then
			print_error("Party保存时装失败, err=" .. gCS.Error.GetNameById(err))
		end

		if callBack then
			callBack()
		end
	end, unit)
end

M.ClosePartyMode = function(self)
	self.SavePartyFashion(self, function ()
		gDressManager:ClearSelectTypeData()
		gPanelManager:Close(self.m_Id)
	end)
end
