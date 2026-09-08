-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FakePhonePanelStore.lua
-- Decompiled from: 02052_FakePhonePanelStore.lua_7ceaeaebf0cc.luajit

C_FakePhonePanelStore = DefClass("C_FakePhonePanelStore", C_FakePhonePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.FakePhonePanelStore = C_FakePhonePanelStore
local M = C_FakePhonePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.chatButton.luaClick = self.CreateAction(self, "OnChatClick")
	self.bindData.takePhotoButton.luaClick = self.CreateAction(self, "OnTakePhotoClick")
	self.bindData.bottomAppList.luaSimpleRenderItem = self.CreateAction(self, "OnBottomAppRenderItem")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.npcChatConfigId = args.npcChatConfigId
	self.npcPhoneId = args.npcPhoneId
	self.npcId = args.npcId

	if not self.npcId and self.npcPhoneId then
		self.npcId = LTConfig.NPCChatNpcsPhoneConfig.GetConfig(self.npcPhoneId).Owner
	end
end

M.InitView = function(self, args)
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

M.OnChatClick = function(self)
	gNpcChatNpcsPhoneManager:OpenFakePhoneChatPanel({
		npcId = self.npcId,
		npcChatConfigId = self.npcChatConfigId,
		npcPhoneId = self.npcPhoneId
	})
end

M.OnTakePhotoClick = function(self)
	local npcConfig = LTConfig.NPCChatNpcConfig.GetConfig(self.npcId)

	if npcConfig ~= nil then
		print_error("FakePhonePanelStore:OnTakePhotoClick 找不到 NPC 配置", self.npcId)

		return
	end

	local albumGroupId = npcConfig.NpcAlbumGroupId

	gMainPhoneUtils.ShowPhoneAppContent({
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.FakePhoneAlbum,
		albumGroupId = albumGroupId
	})
end

M.OnBottomAppRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.bottomAppViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup("PhoneBottomButtonTemplateStore"):GetStoreByWidget(btn)
	local appId = data.id
	local mobileSGuiMenuCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)
	store.icon = gUIUtils:GetSguiImagePath(mobileSGuiMenuCfg.SIconId)
	store.button.luaClick = self:CreateActionWithArgs("OnAppItemClick", appId)
end

M.OnAppItemClick = function(self, appId)
	if appId ~= LTConfig.MobileMenuSGuiConfig.CallPhoneId then
		gMainPhoneFunctionAction.OpenCallPhone({
			secondShowType = gClientConst.CallPhoneShowType.Dialing
		})
	elseif appId ~= LTConfig.MobileMenuSGuiConfig.TakePhotoId then
		gMainPhoneFunctionAction.OpenTakePhoto()
	end
end
