-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneCallHomePageStore.lua
-- Decompiled from: 02096_PhoneCallHomePageStore.lua_7ec75b35c3d2.luajit

C_PhoneCallHomePageStore = DefClass("C_PhoneCallHomePageStore", C_PhoneCallHomePageStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.PhoneCallHomePageStore = C_PhoneCallHomePageStore
local M = C_PhoneCallHomePageStore
local BottomTabControl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.rootNavArea = self.rootWidget and self.rootWidget:GetComponentInChildren(typeof(SGUI.UNavigationArea))

	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.rootNavArea)
end

M.OnDestroy = function(self)
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.rootNavArea)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_PHONE_CALL_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

M.OnRenderTab = function(self, index, widget)
	M.base.OnRenderTab(self, index, widget)

	local showType = index
	local isShowBottomTab = showType ~= gClientConst.CallPhoneShowType.Contact or showType ~= gClientConst.CallPhoneShowType.Dialing
	self.bindData.bottomTabCtrl = isShowBottomTab and BottomTabControl.Show or BottomTabControl.Hide
end

M.CloseContentPanel = function(self, backToShowType)
	if gClientUtils.IsNil(self.bindData.tabRect) then
		return
	end

	if backToShowType then
		local targetShowTypeIndex = self.stackPanel:IndexOf(backToShowType)

		self.stackPanel:PopToIndex(targetShowTypeIndex)

		local stackInfo = self.stackPanel:Peek()
		local showType = self:GetShowType(stackInfo)

		self.bindData.tabRect:SelectIndexWithClose(showType)
	else
		local currentStackInfo = self.stackPanel:Peek()
		local currentShowType = self:GetShowType(currentStackInfo)

		if currentShowType ~= gClientConst.CallPhoneShowType.Contact or currentShowType ~= gClientConst.CallPhoneShowType.Dialing then
			self.OnExit(self)

			return
		end

		local lastStackPanel = self.stackPanel:Pop()

		if self.stackPanel.count ~= 0 then
			self.OnExit(self)
		else
			local stackInfo = self.stackPanel:Peek()
			stackInfo.lastShowType = self:GetShowType(lastStackPanel)
			local showType = self:GetShowType(stackInfo)

			self.bindData.tabRect:SelectIndexWithClose(showType)
		end
	end
end

M.OnExitClick = function(self)
	gMainPhoneUtils.CloseFrontContent()
	self.OnExit(self)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
