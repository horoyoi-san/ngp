-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyDestinationSelectStore.lua
-- Decompiled from: 02046_PartyDestinationSelectStore.lua_0d9a4a1bd1e8.luajit

C_PartyDestinationSelectStore = DefClass("C_PartyDestinationSelectStore", C_PartyDestinationSelectStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PartyDestinationSelectStore = C_PartyDestinationSelectStore
local M = C_PartyDestinationSelectStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.avatarButton.luaClick = self.CreateAction(self, "OnClickAvatarButton")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
	self.bindData.cancelButton.luaClick = self.CreateAction(self, "OnCancelClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnCancelClick")
	self.bindData.confirmButton.luaClick = self.CreateAction(self, "OnConfirmClick")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.partyTypeId = args.partyTypeId
	self.partyIdList = {}

	for _, id in ipairs(args.partyIdList) do
		if self.CheckHasUnlocked(self, id) then
			table.insert(self.partyIdList, id)
		end
	end
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self:RefreshAvatarView()
	self.bindData.list:SetSimpleList(#self.partyIdList)
end

M.RefreshAvatarView = function(self)
	local partyTypeCfg = LTConfig.PartyPartyTypeConfig.GetConfig(self.partyTypeId)
	local headIcon, _ = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	self.bindData.iconId = headIcon
	self.bindData.dialogText = partyTypeCfg.DialogText
end

M.OnClickAvatarButton = function(self)
end

M.OnSimpleRenderListItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local id = self.partyIdList[luaIndex]
	local partyCfg = LTConfig.PartyConfig.GetConfig(id)
	store.iconId = partyCfg.IconId
	store.title = partyCfg.Location
	btn.interactable = self:CheckHasUnlocked(id)

	if self:CheckHasUnlocked(id) then
		store.showConditionControl = 1

		store.list:SetSimpleList(0)
	else
		store.showConditionControl = 0

		store.list.luaSimpleRenderItem = function(childBtn, _)
			local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
			childStore.condition = partyCfg.ConditionDes
		end

		store.list:SetSimpleList(1)
	end

	store.guideId = partyCfg.GuideId
end

M.CheckHasUnlocked = function(self, id)
	local partyCfg = LTConfig.PartyConfig.GetConfig(id)

	return gEventConditionUtils.CheckHasUnlocked(partyCfg, UX.Game.EventConditionImplModule.Party)
end

M.OnSimpleClickList = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local id = self.partyIdList[luaIndex]
	self.bindData.showConfirmControl = 0

	gPartyManager:SetSinglePartyId(id)
	self:RefreshConfirmView(id)
end

M.RefreshConfirmView = function(self, id)
	local partyCfg = LTConfig.PartyConfig.GetConfig(id)
	local exchangeCost = gCommonItemManager:GetExchangeRate(partyCfg.Price)
	local priceText = string.format("%s%d", gCommonItemManager:GetCurrMoneyRichText(), exchangeCost)
	self.bindData.confirmText = LTConfig.PartyConfig.ComsumableIdConfirmText:format(priceText)
end

M.OnCancelClick = function(self)
	self.bindData.showConfirmControl = 1
end

M.OnConfirmClick = function(self)
	local partyCfg = LTConfig.PartyConfig.GetConfig(gPartyManager.singlePartyId)
	local gamePlayType = partyCfg.GamePlayType
	slot3 = gClientToGameDelegate

	slot3:AskSimulationInviteNpc(gamePlayType).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end
