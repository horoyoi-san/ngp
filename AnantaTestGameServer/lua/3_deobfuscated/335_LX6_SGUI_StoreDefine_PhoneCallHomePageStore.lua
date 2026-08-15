C_PhoneCallHomePageStore = DefClass("C_PhoneCallHomePageStore", C_PhoneCallHomePageStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.PhoneCallHomePageStore = C_PhoneCallHomePageStore
local M = C_PhoneCallHomePageStore
local BottomTabControl = {
	Hide = 0,
	Show = 1
}

function M:OnAwake()
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.rootNavArea = self.rootWidget and self.rootWidget:GetComponentInChildren(typeof(SGUI.UNavigationArea))

	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.rootNavArea)
end

function M:OnDestroy()
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.rootNavArea)
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_PHONE_CALL_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

function M:OnRenderTab(index, widget)
	M.base.OnRenderTab(self, index, widget)

	local showType = index
	local isShowBottomTab = showType == gClientConst.CallPhoneShowType.Contact or showType == gClientConst.CallPhoneShowType.Dialing
	self.bindData.bottomTabCtrl = isShowBottomTab and BottomTabControl.Show or BottomTabControl.Hide
end

function M:CloseContentPanel(backToShowType)
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

		if currentShowType == gClientConst.CallPhoneShowType.Contact or currentShowType == gClientConst.CallPhoneShowType.Dialing then
			self:OnExit()

			return
		end

		local lastStackPanel = self.stackPanel:Pop()

		if self.stackPanel.count == 0 then
			self:OnExit()
		else
			local stackInfo = self.stackPanel:Peek()
			stackInfo.lastShowType = self:GetShowType(lastStackPanel)
			local showType = self:GetShowType(stackInfo)

			self.bindData.tabRect:SelectIndexWithClose(showType)
		end
	end
end

function M:OnExitClick()
	gMainPhoneUtils.CloseFrontContent()
	self:OnExit()
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
