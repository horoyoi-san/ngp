C_PhoneBottomFrameTemplateStore = DefClass("C_PhoneBottomFrameTemplateStore", C_PhoneBottomFrameTemplateStore, C_StoreGroup)
GroupName2Class.PhoneBottomFrameTemplateStore = C_PhoneBottomFrameTemplateStore
local M = C_PhoneBottomFrameTemplateStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.bottomAppList.luaSimpleRenderItem = self:CreateAction("OnPhoneRenderItem")

	self:InitMessageEvents()
end

function M:InitMessageEvents()
	local refreshViewFunc = self:CreateAction("RefreshView")
	local msgEvents = {
		[gEventConstants.UPDATE_NOTICE_RED_POT] = refreshViewFunc,
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = refreshViewFunc
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnStart()
	self:InitView()
end

function M:InitView()
	self:RefreshView()
end

function M:RefreshView()
	self.phoneAppDataList = gMainPhoneUtils.GetBottomPhoneAppViewDataList()

	self.bindData.bottomAppList:SetSimpleList(#self.phoneAppDataList)
end

function M:OnPhoneRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.phoneAppDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup("PhoneBottomButtonTemplateStore"):GetStoreByWidget(btn)
	local appId = data.id
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)
	local imageCfg = LTConfig.SguiImageConfig.GetConfig(mobileMenuSGuiCfg.SIconId)
	store.icon = imageCfg and imageCfg.ImgPath
	store.button.luaClick = self:CreateActionWithArgs("OnAppItemClick", appId)
	store.guideId = mobileMenuSGuiCfg.GuideId
	local redDotKey = ("PhoneBottomAppItemRedDot:%d"):format(appId)

	gMainPhoneUtils.RefreshAppItemRedDot(appId, redDotKey)

	btn.interactable = gMainPhoneUtils.CheckAppCanInteractable(data.id)
end

function M:OnAppItemClick(appId)
	gMainPhoneUtils.OnAppItemClick(appId)
end

function M:OnDestroy()
	self:ClearDataSetEvents()
	self:ClearMessageEvents()
end
