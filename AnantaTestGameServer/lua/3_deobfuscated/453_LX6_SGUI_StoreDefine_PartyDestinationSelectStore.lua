C_PartyDestinationSelectStore = DefClass("C_PartyDestinationSelectStore", C_PartyDestinationSelectStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PartyDestinationSelectStore = C_PartyDestinationSelectStore
local M = C_PartyDestinationSelectStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.avatarButton.luaClick = self:CreateAction("OnClickAvatarButton")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self:CreateAction("OnSimpleClickList")
	self.bindData.cancelButton.luaClick = self:CreateAction("OnCancelClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnCancelClick")
	self.bindData.confirmButton.luaClick = self:CreateAction("OnConfirmClick")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_PARTY_INVITE_SUCCESS] = self:CreateAction("OnInviteSuccess")
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.partyIdList = args.partyIdList
	self.partyTypeId = args.partyTypeId
end

function M:InitView(args)
	M.base.InitView(self, args)
	self:RefreshAvatarView()
	self.bindData.list:SetSimpleList(#self.partyIdList)
end

function M:RefreshAvatarView()
	local partyTypeCfg = LTConfig.PartyPartyTypeConfig.GetConfig(self.partyTypeId)
	local headIcon, _ = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	self.bindData.iconId = headIcon
	self.bindData.dialogText = partyTypeCfg.DialogText
end

function M:OnClickAvatarButton()
	return
end

function M:OnSimpleRenderListItem(btn, csIndex)
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

		function store.list.luaSimpleRenderItem(childBtn, _)
			local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
			childStore.condition = partyCfg.ConditionDes
		end

		store.list:SetSimpleList(1)
	end
end

function M:CheckHasUnlocked(id)
	local partyCfg = LTConfig.PartyConfig.GetConfig(id)

	return gEventConditionUtils.CheckHasUnlocked(partyCfg, UX.Game.EventConditionImplModule.Party)
end

function M:OnSimpleClickList(btn, csIndex)
	local luaIndex = csIndex + 1
	local id = self.partyIdList[luaIndex]
	self.bindData.showConfirmControl = 0
	self.currentPartyId = id

	self:RefreshConfirmView(id)
end

function M:RefreshConfirmView(id)
	local partyCfg = LTConfig.PartyConfig.GetConfig(id)
	self.bindData.confirmText = LTConfig.PartyConfig.ComsumableIdConfirmText:format(partyCfg.Price)
end

function M:OnInviteSuccess(_, npcIdList)
	gPartyManager:StartSingleParty(self.currentPartyId, npcIdList)
end

function M:OnCancelClick()
	self.bindData.showConfirmControl = 1
end

function M:OnConfirmClick()
	gClientToGameDelegate:AskSimulationInviteNpc(_gamePlayId).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

function M:ClearData()
	self.currentPartyId = nil
end
