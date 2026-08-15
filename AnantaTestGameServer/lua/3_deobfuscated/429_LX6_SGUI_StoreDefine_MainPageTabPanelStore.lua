C_MainPageTabPanelStore = DefClass("C_MainPageTabPanelStore", C_MainPageTabPanelStore, C_StoreGroup)
GroupName2Class.MainPageTabPanelStore = C_MainPageTabPanelStore
local M = C_MainPageTabPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.Control = {
		False = 0,
		True = 1
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.openState = false
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.tabs = gMainPageManager:GetTabList()
	self.currTabName = data
	self.currTabIndex = -1

	self.bindData.tabList:SetSimpleList(#self.tabs)

	for i = 1, #self.tabs do
		if self.tabs[i].cfg.CheckName == self.currTabName then
			self.bindData.tabList:SelectItem(i - 1, false)

			self.currTabIndex = i
			self.bindData.title = self.tabs[i].cfg.Name

			break
		end
	end

	self.specialType = false

	if self.currTabIndex > 0 and self.currTabIndex <= #self.tabs then
		self.specialType = self.tabs[self.currTabIndex].cfg.TypeMobile == 1
	end

	self.openState = false

	self:RefreshView()
	self:RefreshRedPoint()
	self:RefreshHide()
end

function M:OnClose()
	self.openState = false

	gMainPageManager:SetMainPageHide(false, true)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.LANGUAGE_CHANGE] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.RED_POINT_PANEL_UPDATE] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.REFRESH_MAIN_BUTTON_RED_POT] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.ADJUST_WORLD_LEVEL] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.PALYER_LEVEL_UP] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.SYNC_CURRENT_SPIRIT] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.UPDATE_NOTICE_RED_POT] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self:CreateAction("RefreshRedPointByMessage"),
		[gEventConstants.TASK_ACCEPTED] = self:CreateAction("RefreshRedPointByMessage")
	}
end

function M:RegisterWidget()
	self.bindData.btnOpen.luaClick = self:CreateAction("OnClickBtnOpen")
	self.bindData.btnClose.luaClick = self:CreateAction("OnClickBtnClose")
	self.bindData.btnBack.luaClick = self:CreateAction("OnClickBtnBack")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRenderTabListItem")
	self.bindData.tabList.luaSimpleClick = self:CreateAction("OnClickTabList")
	self.openState = false
end

function M:OnClickBtnOpen()
	self.openState = not self.openState

	self:RefreshView()
end

function M:OnClickBtnClose()
	self.openState = false

	self:RefreshView()
end

function M:OnClickBtnBack()
	gMainPageManager:CloseMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

function M:OnRenderTabListItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local data = self.tabs[index + 1]

	if store and data then
		store.name = data.cfg.Name
		store.icon = data.cfg.SGUIImage
		store.redKey = "MainPage." .. data.cfg.AppId
		btn.redId = data.cfg.RedDotId
	end
end

function M:OnClickTabList(btn, index)
	if self.currTabIndex == index + 1 then
		self.openState = false

		self:RefreshView()

		return
	end

	self.currTabIndex = index + 1

	gMainPageManager:ShowMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

function M:RefreshView()
	local showTypeBg = self.specialType and not self.openState
	self.bindData.TypeCtrl = showTypeBg and self.Control.True or self.Control.False
	self.bindData.StatusCtrl = self.openState and self.Control.True or self.Control.False
	local showTitle = self.openState or not self.specialType
	self.bindData.ShowTitleCtrl = showTitle and self.Control.True or self.Control.False
end

function M:RefreshRedPoint()
	for i = 1, #self.tabs do
		local appId = self.tabs[i].cfg.AppId
		local redDotId = self.tabs[i].cfg.RedDotId or 0

		if appId > 0 and redDotId == 0 then
			local redKey = "MainPage." .. self.tabs[i].cfg.AppId

			gMainPhoneUtils.GetAppHasRedDot(appId, function (hasRedDot)
				SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redKey)
			end)
		end
	end
end

function M:RefreshRedPointByMessage()
	if not self.STATE_OnShowOnce then
		return
	end

	self:RefreshRedPoint()
end

function M:OnLanguageChange()
	if self.STATE_OnShowOnce then
		self.bindData.tabList:RefreshList()
	end
end

function M:RefreshHide()
	if self.STATE_OnShowOnce then
		self.bindData.HideCtrl = gMainPageManager:GetMainPageHide() and self.Control.True or self.Control.False
	end
end
