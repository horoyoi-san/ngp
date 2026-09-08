-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyCreatePanelStore.lua
-- Decompiled from: 01070_PartyCreatePanelStore.lua_68d0a175746c.luajit

local PartyConfig = LTConfig.PartyConfig
local PartyPartyTypeConfig = LTConfig.PartyPartyTypeConfig
C_PartyCreatePanelStore = DefClass("C_PartyCreatePanelStore", C_PartyCreatePanelStore, C_StoreGroup)
GroupName2Class.PartyCreatePanelStore = C_PartyCreatePanelStore
local M = C_PartyCreatePanelStore
local PrivateRoomPasswordLength = 4
M.Visibility = {
	[":Z\\x98\\x8b\\x8dE"] = 1,
	[",]\\x93\\x82\\x8aB"] = 0,
	["\\xe9\\xc90\\xf4"] = 2
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.partyTypeList = {}
	self.partyMapList = {}
	self.selectedPartyTypeId = nil
	self.singlePartyId = nil
	self.visibilityIndex = self.Visibility.Public
	self.roomNameText = ""
	self.oldRoomNameText = ""
	self.oldRoomNameVisualLength = 0
	self.passwordText = ""
	self.enableLottery = false
	self.enableGift = false
	self.ownerJoinLottery = false
	self.lotteryItemId = 0
	self.lotteryItemCount = 0
	self.giftItemId = 0
	self.giftItemCount = 0
	self.startPartyCostEnough = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.showPasswordCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.moneyLackCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showChooseMapCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.roomNameStateCtrlEnum = {
		["\\xce\\xda*\\xf6"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.partyGameLockCtrlEnum = {
		["v-~P"] = 0,
		["G\\x83\\x83\\x82M"] = 1
	}
	self.passwordStateCtrlEnum = {
		["\\xce\\xda*\\xf6"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.giftStateCtrlEnum = {
		["\\x8flb"] = 0,
		s6xV = 1
	}
	self.lotteryStateCtrlEnum = {
		["\\x8flb"] = 0,
		s6xV = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showPasswordCtrlEnum = nil
	self.moneyLackCtrlEnum = nil
	self.showChooseMapCtrlEnum = nil
	self.roomNameStateCtrlEnum = nil
	self.partyGameLockCtrlEnum = nil
	self.passwordStateCtrlEnum = nil
	self.giftStateCtrlEnum = nil
	self.lotteryStateCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.RefreshCreatePanelData(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshCreatePanelData(self, data)
end

M.ShowPanel = function(self, data)
	self.RefreshCreatePanelData(self, data)
end

M.OnClose = function(self)
	self.ClearPasswordCache(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.RegisterWidget = function(self)
	self.bindData.lottery.luaClick = self.CreateAction(self, "OnClickLottery")
	self.bindData.gift.luaClick = self.CreateAction(self, "OnClickGift")
	self.bindData.addLotteryBtn.luaClick = self.CreateAction(self, "OnClickAddLotteryBtn")
	self.bindData.addGiftBtn.luaClick = self.CreateAction(self, "OnClickAddGiftBtn")
	self.bindData.selfJoinLottryBtn.luaClick = self.CreateAction(self, "OnClickSelfJoinLottryBtn")
	self.bindData.startPartyBtn.luaClick = self.CreateAction(self, "OnClickStartPartyBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.partyList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderPartyListItem")
	self.bindData.partyList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickPartyList")
	self.bindData.visibility.luaSimpleOptionClick = self.CreateAction(self, "OnVisibilityOptionClick")
	self.bindData.map.luaSimpleOptionClick = self.CreateAction(self, "OnMapOptionClick")
	self.bindData.roomName.luaValueChanged = self.CreateAction(self, "OnRoomNameInputValueChanged")
	self.bindData.roomName.characterLimit = 0
	self.bindData.password.luaValueChanged = self.CreateAction(self, "OnPasswordInputValueChanged")
	self.bindData.password.characterLimit = PrivateRoomPasswordLength
end

M.OnClickLottery = function(self)
	self.enableLottery = not self.enableLottery

	self.RefreshOptionButtons(self)
end

M.OnClickGift = function(self)
	self.enableGift = not self.enableGift

	self.RefreshOptionButtons(self)
end

M.OnClickAddLotteryBtn = function(self)
	if not self.enableLottery then
		return
	end

	self.OpenLotteryItemPicker(self)
end

M.OnClickAddGiftBtn = function(self)
	if not self.enableGift then
		return
	end

	self.OpenGiftItemPicker(self)
end

M.OpenLotteryItemPicker = function(self)
	local maxMembers = self.GetSelectedPartyMaxMembers(self)

	self.OpenItemPicker(self, {
		rangeCallback = function (item)
			local itemId = item.TemplateId or item.itemId

			return {
				1,
				math.min(math.max(gCommonItemManager:GetPackItemNum(itemId), 1), maxMembers)
			}
		end,
		itemAvailableCallback = function (item)
			return self:CheckLotteryItemAvailable(item)
		end,
		confirmCallback = function (itemId, count)
			self:SetLotteryItem(self:GetLotteryConsumableItemId(itemId), count)
		end
	})
end

M.GetLotteryConsumableItemId = function(self, itemId)
	if table.contains(PartyConfig.PartyLotteryList, itemId) then
		return itemId
	end

	for i = 1, #PartyConfig.PartyLotteryList do
		local lotteryItemId = PartyConfig.PartyLotteryList[i]
		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(lotteryItemId)

		if consumableCfg.BindId ~= itemId then
			return lotteryItemId
		end
	end

	return itemId
end

M.CheckLotteryItemAvailable = function(self, item)
	local itemId = item.TemplateId or item.itemId

	return table.contains(PartyConfig.PartyLotteryList, self:GetLotteryConsumableItemId(itemId))
end

M.OpenGiftItemPicker = function(self)
	local maxMembers = self.GetSelectedPartyMaxMembers(self)

	self.OpenItemPicker(self, {
		rangeCallback = function ()
			return {
				maxMembers,
				maxMembers
			}
		end,
		itemAvailableCallback = function (item)
			local itemId = item.TemplateId or item.itemId

			return maxMembers > gCommonItemManager:GetPackItemNum(itemId)
		end,
		confirmCountCallback = function ()
			return maxMembers
		end,
		confirmCallback = function (itemId, count)
			self:SetGiftItem(itemId, count)
		end
	})
end

M.GetSelectedPartyMaxMembers = function(self)
	return PartyConfig.GetConfig(self.singlePartyId).MaxNum
end

M.OpenItemPicker = function(self, data)
	data.mode = gCommonItemManager.INVENTORY_MODE.SELECT
	data.confirmTitle = tostring(PartyConfig.SelectGiftTitle)

	gCommonItemManager:OpenInventoryPanel(data, true)
end

M.OnClickSelfJoinLottryBtn = function(self)
	self.ownerJoinLottery = not self.ownerJoinLottery

	self.RefreshOptionButtons(self)
end

M.OnClickStartPartyBtn = function(self)
	if not self.ValidateCreateRoomParam(self) then
		return
	end

	local param = self:BuildCreateRoomParam()

	gClientToGameDelegate:AskCreatePartyRoom(param).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end

	gPanelManager:Close(gPanelId.PARTY_CREATE_PANEL)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.PARTY_CREATE_PANEL)
end

M.OnSimpleRenderPartyListItem = function(self, btn, index)
	local data = self.partyTypeList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.name
	store.guideId = data.guideId

	store:Commit("iconId", data.iconId, COMMIT_FORCE)

	store.lockCtrl = data.unlocked and self.partyGameLockCtrlEnum.normal or self.partyGameLockCtrlEnum.lock
end

M.OnSimpleClickPartyList = function(self, btn, index)
	local data = self.partyTypeList[index + 1]

	if not data then
		return
	end

	self.selectedPartyTypeId = data.typeId
	self.singlePartyId = nil

	self.RefreshMapSelector(self)
	self.RefreshConsume(self)
end

M.OnVisibilityOptionClick = function(self, btn, index)
	if self.visibilityIndex == index then
		self.ClearPasswordCache(self)
	end

	self.visibilityIndex = index

	self.RefreshPasswordCtrl(self)
end

M.OnMapOptionClick = function(self, btn, index)
	local data = self.partyMapList[index + 1]

	if not data then
		return
	end

	self.singlePartyId = data.partyId

	self.RefreshConsume(self)
end

M.OnRoomNameInputValueChanged = function(self, text)
	local visualLength = LX6.Utils.TextUtils.GetVisualLength(text)
	local oldVisualLength = self.oldRoomNameVisualLength

	if oldVisualLength >= visualLength and PartyConfig.PartyRoomMaxName >= visualLength then
		self.bindData.roomName.text = self.oldRoomNameText
		self.roomNameText = self.oldRoomNameText

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.NameTooLong)

		return
	end

	self.roomNameText = text
	self.oldRoomNameText = text
	self.oldRoomNameVisualLength = visualLength

	if not string.is_null_or_empty(self.roomNameText) then
		self.bindData.roomNameStateCtrl = self.roomNameStateCtrlEnum.normal
	end
end

M.OnPasswordInputValueChanged = function(self, text)
	self.passwordText = text

	if self.visibilityIndex ~= self.Visibility.Private then
		self.bindData.passwordStateCtrl = self.passwordStateCtrlEnum.normal
	end
end

M.SetLotteryItem = function(self, itemId, itemCount)
	self.lotteryItemId = itemId or 0
	self.lotteryItemCount = itemCount or 0
	self.enableLottery = self.lotteryItemId == 0 and self.lotteryItemCount == 0

	self:RefreshLotteryStateCtrl()
	self:RefreshOptionButtons()
end

M.SetGiftItem = function(self, itemId, itemCount)
	self.giftItemId = itemId or 0
	self.giftItemCount = itemCount or 0
	self.enableGift = self.giftItemId == 0 and self.giftItemCount == 0

	self:RefreshGiftStateCtrl()
	self:RefreshOptionButtons()
end

M.RefreshGiftStateCtrl = function(self)
	local hasItem = self.giftItemId == 0 and self.giftItemCount == 0
	self.bindData.giftStateCtrl = hasItem and self.giftStateCtrlEnum.item or self.giftStateCtrlEnum.add

	if hasItem then
		local renderData = gCommonItemManager:GetItemRenderData({
			["iy\\xbetI\\x81\\xfaH}TkA"] = true,
			itemId = self.giftItemId,
			itemNum = self.giftItemCount
		})

		gCommonItemManager:OnCommonItemRender(self.bindData.giftItem, 0, renderData)
	end
end

M.RefreshLotteryStateCtrl = function(self)
	local hasItem = self.lotteryItemId == 0 and self.lotteryItemCount == 0
	self.bindData.lotteryStateCtrl = hasItem and self.lotteryStateCtrlEnum.item or self.lotteryStateCtrlEnum.add

	if hasItem then
		local renderData = gCommonItemManager:GetItemRenderData({
			["iy\\xbetI\\x81\\xfaH}TkA"] = true,
			itemId = self.lotteryItemId,
			itemNum = self.lotteryItemCount
		})

		gCommonItemManager:OnCommonItemRender(self.bindData.lotteryItem, 0, renderData)
	end
end

M.RefreshCreatePanelData = function(self, data)
	self.visibilityIndex = self.Visibility.Public
	self.passwordText = ""
	self.enableLottery = false
	self.enableGift = false
	self.ownerJoinLottery = false
	self.lotteryItemId = 0
	self.lotteryItemCount = 0
	self.giftItemId = 0
	self.giftItemCount = 0

	if data then
		self:RefreshPartyItemData(data.PartyInfo or data.partyInfo or data)
	end

	self.roomNameText = PartyConfig.DefaultRoomName:format(gPlayerManager.infoLogin.bindData.playerName)
	self.oldRoomNameText = self.roomNameText
	self.oldRoomNameVisualLength = LX6.Utils.TextUtils.GetVisualLength(self.roomNameText)
	self.bindData.roomName.text = self.roomNameText
	self.bindData.password.text = self.passwordText
	self.bindData.roomNameStateCtrl = self.roomNameStateCtrlEnum.normal
	self.bindData.passwordStateCtrl = self.passwordStateCtrlEnum.normal

	self:RefreshGiftStateCtrl()
	self:RefreshLotteryStateCtrl()

	self.partyTypeList = self:BuildPartyTypeList()

	self.bindData.partyList:SetSimpleList(#self.partyTypeList)
	self:RefreshVisibilitySelector()
	self:RefreshOptionButtons()

	local firstPartyType = self.partyTypeList[1]
	self.selectedPartyTypeId = firstPartyType and firstPartyType.typeId or nil

	self:RefreshMapSelector()

	if firstPartyType then
		self.bindData.partyList:SelectItem(0)
	end

	self.RefreshConsume(self)
end

M.BuildPartyTypeList = function(self)
	local typeIdSet = {}

	for i = 0, PartyConfig.count - 1 do
		local partyCfg = PartyConfig.LoadAt(i)

		if partyCfg and partyCfg.OnlineParty then
			typeIdSet[partyCfg.Type] = true
		end
	end

	local typeIdList = {}

	for typeId in pairs(typeIdSet) do
		table.insert(typeIdList, typeId)
	end

	table.sort(typeIdList)

	local list = {}

	for _, typeId in ipairs(typeIdList) do
		local typeCfg = PartyPartyTypeConfig.GetConfig(typeId)

		if typeCfg then
			table.insert(list, {
				typeId = typeId,
				name = typeCfg.Name,
				guideId = typeCfg.GuideId,
				iconId = typeCfg.IconId,
				unlocked = self.CheckPartyTypeUnlocked(self, typeId)
			})
		end
	end

	return list
end

M.BuildPartyMapList = function(self, partyTypeId)
	local list = {}

	for i = 0, PartyConfig.count - 1 do
		local partyCfg = PartyConfig.LoadAt(i)

		if partyCfg and partyCfg.OnlineParty and partyCfg.Type ~= partyTypeId then
			table.insert(list, {
				partyId = partyCfg.Id,
				name = partyCfg.Location
			})
		end
	end

	table.sort(list, function (a, b)
		return a.partyId <= b.partyId
	end)

	return list
end

M.RefreshVisibilitySelector = function(self)
	local visibilityNameList = PartyConfig.VisibilityName

	self.bindData.visibility:SetSimpleOptions(#visibilityNameList)

	for i = 1, #visibilityNameList do
		self.bindData.visibility:SetItemLabel(i - 1, visibilityNameList[i])
	end

	self.bindData.visibility:SelectOption(self.visibilityIndex, false)
	self:RefreshPasswordCtrl()
end

M.RefreshMapSelector = function(self)
	self.partyMapList = self:BuildPartyMapList(self.selectedPartyTypeId)
	self.singlePartyId = nil
	self.bindData.showChooseMapCtrl = #self.partyMapList <= 1 and self.showChooseMapCtrlEnum.show or self.showChooseMapCtrlEnum.hide

	self.bindData.map:SetSimpleOptions(#self.partyMapList)

	for i = 1, #self.partyMapList do
		self.bindData.map:SetItemLabel(i - 1, self.partyMapList[i].name)
	end

	local selectedIndex = 0

	if #self.partyMapList <= 0 then
		self.singlePartyId = self.partyMapList[1].partyId

		self.bindData.map:SelectOption(selectedIndex, false)
	end
end

M.RefreshConsume = function(self)
	if not self.singlePartyId then
		self.bindData.consume = ""
		self.startPartyCostEnough = false
		self.bindData.moneyLackCtrl = self.moneyLackCtrlEnum._true

		self.RefreshStartPartyBtnState(self)

		return
	end

	local partyCfg = PartyConfig.GetConfig(self.singlePartyId)
	local exchangeCost = gCommonItemManager:GetExchangeRate(partyCfg.Price)
	self.bindData.consume = string.format("%s%d", gCommonItemManager:GetCurrMoneyRichText(), exchangeCost)
	self.startPartyCostEnough = self:CheckPartyCostEnough(partyCfg)
	self.bindData.moneyLackCtrl = self.startPartyCostEnough and self.moneyLackCtrlEnum._false or self.moneyLackCtrlEnum._true

	self:RefreshStartPartyBtnState()
end

M.RefreshOptionButtons = function(self)
	self.bindData.lottery:SetSelected(self.enableLottery)
	self.bindData.gift:SetSelected(self.enableGift)

	self.bindData.addLotteryRootBtn.interactable = self.enableLottery
	self.bindData.addGiftRootBtn.interactable = self.enableGift

	self.bindData.selfJoinLottryBtn:SetSelected(self.ownerJoinLottery)
	self:RefreshStartPartyBtnState()
end

M.RefreshPasswordCtrl = function(self)
	self.bindData.showPasswordCtrl = self.visibilityIndex ~= self.Visibility.Private and self.showPasswordCtrlEnum.show or self.showPasswordCtrlEnum.hide
end

M.ClearPasswordCache = function(self)
	self.passwordText = ""
	self.bindData.password.text = self.passwordText
	self.bindData.passwordStateCtrl = self.passwordStateCtrlEnum.normal
end

M.RefreshPartyItemData = function(self, partyInfo)
	self.lotteryItemId = partyInfo.LotteryItemId or partyInfo.lotteryItemId or 0
	self.lotteryItemCount = partyInfo.LotteryItemCount or partyInfo.lotteryItemCount or 0
	self.giftItemId = partyInfo.GiftItemId or partyInfo.giftItemId or 0
	self.giftItemCount = partyInfo.GiftItemCount or partyInfo.giftItemCount or 0
	self.enableLottery = partyInfo.Lottery or partyInfo.lottery or self.lotteryItemId == 0 and self.lotteryItemCount == 0
	self.enableGift = partyInfo.HasGift or partyInfo.hasGift or self.giftItemId == 0 and self.giftItemCount == 0
	self.ownerJoinLottery = partyInfo.OwnerJoinLottery or partyInfo.ownerJoinLottery
end

M.RefreshStartPartyBtnState = function(self)
	self.bindData.startPartyBtn.interactable = self.singlePartyId == nil and self.startPartyCostEnough
end

M.CheckPartyCostEnough = function(self, partyCfg)
	if partyCfg.ComsumableId ~= 0 or partyCfg.Price < 0 then
		return true
	end

	return partyCfg.Price > gCommonItemManager:GetPackItemNum(partyCfg.ComsumableId)
end

M.HasSelectedPartyItemMissing = function(self)
	return self.enableGift and (self.giftItemId ~= 0 or self.giftItemCount ~= 0) or self.enableLottery and (self.lotteryItemId ~= 0 or self.lotteryItemCount ~= 0)
end

M.CheckPartyItemParamValid = function(self)
	return not self.HasSelectedPartyItemMissing(self)
end

M.ValidateCreateRoomParam = function(self)
	if not self.singlePartyId then
		return false
	end

	local valid = true
	local roomNameVisualLength = LX6.Utils.TextUtils.GetVisualLength(self.roomNameText)

	if string.is_null_or_empty(self.roomNameText) or PartyConfig.PartyRoomMaxName >= roomNameVisualLength then
		self.bindData.roomNameStateCtrl = self.roomNameStateCtrlEnum.warning

		if PartyConfig.PartyRoomMaxName >= roomNameVisualLength then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.NameTooLong)
		end

		valid = false
	else
		self.bindData.roomNameStateCtrl = self.roomNameStateCtrlEnum.normal
	end

	if self.visibilityIndex ~= self.Visibility.Private and not self.passwordText:match("^%d%d%d%d$") then
		self.bindData.passwordStateCtrl = self.passwordStateCtrlEnum.warning

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SetPartyPasswordWrong)

		valid = false
	else
		self.bindData.passwordStateCtrl = self.passwordStateCtrlEnum.normal
	end

	if not valid then
		return false
	end

	if not self.CheckPartyItemParamValid(self) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.NoPartyGift)

		return false
	end

	return self.startPartyCostEnough
end

M.CheckPartyUnlocked = function(self, partyCfg)
	if not partyCfg then
		return false
	end

	return gEventConditionUtils.CheckHasUnlocked(partyCfg, UX.Game.EventConditionImplModule.Party)
end

M.CheckPartyTypeUnlocked = function(self, partyTypeId)
	for i = 0, PartyConfig.count - 1 do
		local partyCfg = PartyConfig.LoadAt(i)

		if partyCfg and partyCfg.OnlineParty and partyCfg.Type ~= partyTypeId and self.CheckPartyUnlocked(self, partyCfg) then
			return true
		end
	end

	return false
end

M.BuildCreateRoomParam = function(self)
	local partyCfg = PartyConfig.GetConfig(self.singlePartyId)
	local param = {
		Name = self.roomNameText,
		Type = UX.Game.CustomRoomType.Party,
		Password = self.visibilityIndex ~= self.Visibility.Private and self.passwordText or nil,
		FriendOnly = self.visibilityIndex ~= self.Visibility.Friend,
		MaxMembers = partyCfg.MaxNum,
		OwnerLeaveDisband = false
	}
	local partyInfo = {
		PartyConfigId = self.singlePartyId,
		Lottery = self.enableLottery,
		LotteryItemId = self.enableLottery and self.lotteryItemId or 0,
		LotteryItemCount = self.enableLottery and self.lotteryItemCount or 0,
		HasGift = self.enableGift,
		GiftItemId = self.enableGift and self.giftItemId or 0,
		GiftItemCount = self.enableGift and self.giftItemCount or 0,
		OwnerJoinLottery = self.ownerJoinLottery,
		EnableLiveBarrage = false,
		EnableRoomAudio = false
	}
	param.PartyInfo = partyInfo

	return param
end
