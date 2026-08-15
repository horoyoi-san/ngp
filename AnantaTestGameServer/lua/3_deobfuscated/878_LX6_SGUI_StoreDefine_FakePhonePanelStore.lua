C_FakePhonePanelStore = DefClass("C_FakePhonePanelStore", C_FakePhonePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.FakePhonePanelStore = C_FakePhonePanelStore
local M = C_FakePhonePanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.chatButton.luaClick = self:CreateAction("OnChatClick")
	self.bindData.takePhotoButton.luaClick = self:CreateAction("OnTakePhotoClick")
	self.bindData.bottomAppList.luaSimpleRenderItem = self:CreateAction("OnBottomAppRenderItem")
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	if args.isAtmosphereNpc and gGmUtils.stealPhoneMode == 0 then
		self.npcId = args.npcId
	else
		self.npcId = 84020037
	end
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.bottomAppViewDataList = {
		{
			id = LTConfig.MobileMenuSGuiConfig.TakePhotoId
		},
		{
			id = LTConfig.MobileMenuSGuiConfig.CallPhoneId
		}
	}

	self.bindData.bottomAppList:SetSimpleList(#self.bottomAppViewDataList)
end

function M:OnChatClick()
	gNpcChatNpcsPhoneManager:OpenFakePhoneChatPanel({
		npcId = self.npcId
	})
end

function M:OnTakePhotoClick()
	local npcConfig = LTConfig.NPCChatNpcConfig.GetConfig(self.npcId)
	local albumGroupId = npcConfig.NpcAlbumGroupId

	gMainPhoneUtils.ShowPhoneAppContent({
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.FakePhoneAlbum,
		albumGroupId = albumGroupId
	})
end

function M:OnBottomAppRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.bottomAppViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup("PhoneBottomButtonTemplateStore"):GetStoreByWidget(btn)
	local appId = data.id
	local mobileSGuiMenuCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)
	local imageCfg = LTConfig.SguiImageConfig.GetConfig(mobileSGuiMenuCfg.SIconId)
	store.icon = imageCfg and imageCfg.ImgPath
	store.button.luaClick = self:CreateActionWithArgs("OnAppItemClick", appId)
end

function M:OnAppItemClick(appId)
	if appId == LTConfig.MobileMenuSGuiConfig.CallPhoneId then
		gMainPhoneFunctionAction.OpenCallPhone({
			secondShowType = gClientConst.CallPhoneShowType.Dialing
		})
	elseif appId == LTConfig.MobileMenuSGuiConfig.TakePhotoId then
		gMainPhoneFunctionAction.OpenTakePhoto()
	end
end
