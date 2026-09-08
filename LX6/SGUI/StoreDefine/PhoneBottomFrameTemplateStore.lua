-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneBottomFrameTemplateStore.lua
-- Decompiled from: 00848_PhoneBottomFrameTemplateStore.lua_81e0ae92b7d3.luajit

C_PhoneBottomFrameTemplateStore = DefClass("C_PhoneBottomFrameTemplateStore", C_PhoneBottomFrameTemplateStore, C_StoreGroup)
GroupName2Class.PhoneBottomFrameTemplateStore = C_PhoneBottomFrameTemplateStore
local M = C_PhoneBottomFrameTemplateStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.bottomAppList.luaSimpleRenderItem = self.CreateAction(self, "OnPhoneRenderItem")

	self.InitMessageEvents(self)
end

M.InitMessageEvents = function(self)
	local refreshViewFunc = self.CreateAction(self, "RefreshView")
	local msgEvents = {
		[gEventConstants.UPDATE_NOTICE_RED_POT] = refreshViewFunc,
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = refreshViewFunc
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnStart = function(self)
	self.InitView(self)
end

M.InitView = function(self)
	self.RefreshView(self)
end

M.RefreshView = function(self)
	self.phoneAppDataList = gMainPhoneUtils.GetBottomPhoneAppViewDataList()

	self.bindData.bottomAppList:SetSimpleList(#self.phoneAppDataList)
end

M.OnPhoneRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.phoneAppDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup("PhoneBottomButtonTemplateStore"):GetStoreByWidget(btn)
	local appId = data.id
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(appId)
	store.icon = gUIUtils:GetSguiImagePath(mobileMenuSGuiCfg.SIconId)
	store.button.luaClick = self:CreateActionWithArgs("OnAppItemClick", appId)
	store.guideId = mobileMenuSGuiCfg.GuideId

	gMainPhoneUtils.RefreshAppItemRedDot(appId)

	btn.interactable = gMainPhoneUtils.CheckAppCanInteractable(data.id)
end

M.OnAppItemClick = function(self, appId)
	gMainPhoneUtils.OnAppItemClick(appId)
end

M.OnDestroy = function(self)
	self.ClearDataSetEvents(self)
	self.ClearMessageEvents(self)
end
