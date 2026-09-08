-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerHomePanelStore.lua
-- Decompiled from: 02104_CleanerHomePanelStore.lua_bc29d6348f4f.luajit

local EShowBeginPanel = {
	["k\\xaf\\xae\\xbc\\xb3"] = 0,
	["N0h^"] = 1
}
C_CleanerHomePanelStore = DefClass("C_CleanerHomePanelStore", C_CleanerHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.CleanerHomePanelStore = C_CleanerHomePanelStore
local M = C_CleanerHomePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	gWasherManager:OnAppOpen()
	self:SetShowBeginPanel(true)

	local appBeginPanelStore = gStoreManager:GetStoreGroup(self.bindData.appBeginPanelWidget.Store):GetStoreByWidget(self.bindData.appBeginPanelWidget)

	gUIUtils:PlayAniCallback(appBeginPanelStore.mainAnim, "S_Vx_CleanerAPPBeginPanel_open", function ()
		self:SetShowBeginPanel(false)
	end)
	self.bindData.mainAnim:Play("S_Vx_CleanerHomePanel_fromMainPhone")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_WASHER_APP_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_WASHER_APP_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, self.OnJobChanged)
	}
end

M.CloseContentPanel = function(self, args)
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

	if self.stackPanel.count ~= 0 then
		self.OnExit(self)

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

M.OnExitClick = function(self)
	self.OnExit(self)
end

M.OnExit = function(self)
	self.bindData.mainAnim:Play("S_Vx_CleanerHomePanel_toMainPhone")
	M.base.OnExit(self)
end

M.OnJobChanged = function(self)
end

M.OnRenderTab = function(self, index, widget)
	if self.panelArgs.panelId then
		gClientUtils.InitNavAreasInChildren(widget, self.panelArgs.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

M.OnExecuteExitAction = function(self)
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

M.SetShowBeginPanel = function(self, isShow)
	self.bindData.showBeginPanelCtrl = isShow and EShowBeginPanel.True or EShowBeginPanel.False
end

M.ClearData = function(self)
	gWasherManager:OnAppClose()
end
