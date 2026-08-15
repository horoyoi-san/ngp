local EShowBeginPanel = {
	False = 0,
	True = 1
}
C_CleanerHomePanelStore = DefClass("C_CleanerHomePanelStore", C_CleanerHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.CleanerHomePanelStore = C_CleanerHomePanelStore
local M = C_CleanerHomePanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnExitClick)
end

function M:InitModel(args)
	M.base.InitModel(self, args)
end

function M:InitView(args)
	M.base.InitView(self, args)

	gWasherManager.appShown = true

	self:SetShowBeginPanel(true)

	local appBeginPanelStore = gStoreManager:GetStoreGroup(self.bindData.appBeginPanelWidget.Store):GetStoreByWidget(self.bindData.appBeginPanelWidget)

	gUIUtils:PlayAniCallback(appBeginPanelStore.mainAnim, "S_Vx_CleanerAPPBeginPanel_open", function ()
		self:SetShowBeginPanel(false)
	end)
	self.bindData.mainAnim:Play("S_Vx_CleanerHomePanel_fromMainPhone")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_WASHER_APP_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_WASHER_APP_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction(self.OnJobChanged)
	}
end

function M:CloseContentPanel(args)
	local lastStackPanel = self.stackPanel:Pop()

	if lastStackPanel.isFromFinish then
		lastStackPanel.isFromFinish = false

		gWasherManager:RefreshWasherJobInfo()
		self:ShowContentPanel({
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.ORDER,
			washerJobInfo = gWasherManager.washerJobInfo
		})

		return
	end

	if self.stackPanel.count == 0 then
		self:OnExit()

		if self.bindData.tabAnimRoot and self.currentTabStore then
			local lastShowType = self:GetShowType(lastStackPanel)

			self.bindData.tabAnimRoot:PlaySwitchTabAnim(lastShowType, self.currentTabStore.rootWidget, -1)
		end
	else
		local stackInfo = self.stackPanel:Peek()
		stackInfo.lastShowType = self:GetShowType(lastStackPanel)
		local showType = self:GetShowType(stackInfo)

		if self.bindData.tabAnimRoot and self.currentTabStore then
			self.bindData.tabAnimRoot:PlaySwitchTabAnim(stackInfo.lastShowType, self.currentTabStore.rootWidget, showType)
		end

		self.bindData.tabRect:SelectIndexWithClose(showType)
	end
end

function M:OnExitClick()
	self:OnExit()
end

function M:OnExit()
	self.bindData.mainAnim:Play("S_Vx_CleanerHomePanel_toMainPhone")
	M.base.OnExit(self)
end

function M:OnJobChanged()
	return
end

function M:OnRenderTab(index, widget)
	if self.panelArgs.panelId then
		gClientUtils.InitNavAreasInChildren(widget, self.panelArgs.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

function M:OnExecuteExitAction()
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

function M:SetShowBeginPanel(isShow)
	self.bindData.showBeginPanelCtrl = isShow and EShowBeginPanel.True or EShowBeginPanel.False
end

function M:ClearData()
	gWasherManager.appShown = false
end
