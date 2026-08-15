local AtmosphereManager = LX6.Manager.AtmosphereManager
local AnimMgr = SGUI.AnimMgr
C_MainPageTabPanelStore_PC = DefClass("C_MainPageTabPanelStore_PC", C_MainPageTabPanelStore_PC, C_StoreGroup)
GroupName2Class.MainPageTabPanelStore_PC = C_MainPageTabPanelStore_PC
local M = C_MainPageTabPanelStore_PC

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.SIGNAL_STATE = {
		Weak = 0,
		Middle = 2,
		Low = 1,
		Strong = 3
	}
	self.TOTAL_ANI_TIME = 0.3
	self.TAB_ANI_NAME = "MainPageTabMove"
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnGroupEnable()
	self.moveBarSize = Vector2.New(0, self.bindData.selectedMoveBar.rect.height)

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
	self:ClearDataSetEvents()

	self.moveBarSize = nil
end

function M:GetStoreByWidgetSource(widget)
	return gStoreManager:GetStoreGroup("MainPageTabPanelStore"):GetStoreByWidget(widget)
end

function M:GetStoreByIdSource(id)
	return gStoreManager:GetStoreGroup("MainPageTabPanelStore"):GetStoreByWidget(id)
end

function M:OnShow(panelId, data)
	self.currTabName = data
	self.currTabIndex = -1

	if not self.STATE_OnShowOnce then
		self.layOutInit = false
		self.tabBtnList = {}
		self.tabs = gMainPageManager:GetTabList()

		self.bindData.selectedMoveBar.gameObject:SetActive(false)
		self.bindData.tabList:SetSimpleList(#self.tabs)

		for i = 1, #self.tabs do
			if self.tabs[i].cfg.CheckName == self.currTabName then
				self.bindData.tabList:SelectItem(i - 1, false)

				self.currTabIndex = i

				break
			end
		end

		if #self.tabs <= 1 then
			self.bindData.HideButtonsCtrl = 1
		else
			self.bindData.HideButtonsCtrl = 0
		end
	else
		self.layOutInit = true

		for i = 1, #self.tabs do
			if self.tabs[i].cfg.CheckName == self.currTabName then
				self.currTabIndex = i

				break
			end
		end

		local targetBtn = self.tabBtnList[self.currTabIndex]

		if targetBtn and self.bindData.selectedMoveBar then
			self.bindData.tabList:DeselectAll(false)

			if self.timer then
				self.timer:Stop()

				self.timer = nil
			end

			self:AdjustBarSize(targetBtn)

			self.timer = Timer.New(function ()
				if self.STATE_OnShowOnce then
					self.bindData.tabList:SelectItem(self.currTabIndex - 1, false)
				end
			end, self.TOTAL_ANI_TIME - 0.1):Start()

			AnimMgr.Kill(self.bindData.selectedMoveBar, self.TAB_ANI_NAME)
			AnimMgr.Move(self.bindData.selectedMoveBar, self.TAB_ANI_NAME, self:GetTargetPosition(targetBtn), self.TOTAL_ANI_TIME, 0, DG.Tweening.Ease.OutCubic, nil)
		end
	end

	self:RefreshRedPoint()

	self.bindData.semitranslucentBgCtrl = data == "UrbanAbility" and 1 or 0
end

function M:OnUpdate()
	self:UpdateSignal()
	self:UpdateTime()
end

function M:OnClose()
	AnimMgr.Kill(self.bindData.selectedMoveBar, self.TAB_ANI_NAME)

	self.tabBtnList = nil
	self.tabs = nil

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
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
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self:CreateAction("RefreshRedPointByMessage")
	}
end

function M:RegisterWidget()
	self.bindData.btnLeft.luaClick = self:CreateAction("OnClickBtnLeft")
	self.bindData.btnRight.luaClick = self:CreateAction("OnClickBtnRight")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnTabListRenderItem")
	self.bindData.tabList.luaSimpleClick = self:CreateAction("OnTabListClick")
	self.bindData.tabList.luaLayoutSet = self:CreateAction("OnTabListLayoutSet")
end

function M:OnClickBtnLeft()
	self.currTabIndex = self.currTabIndex - 1

	if self.currTabIndex < 1 then
		self.currTabIndex = #self.tabs
	end

	gMainPageManager:ShowMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

function M:OnClickBtnRight()
	self.currTabIndex = self.currTabIndex + 1

	if self.currTabIndex > #self.tabs then
		self.currTabIndex = 1
	end

	gMainPageManager:ShowMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

function M:OnTabListRenderItem(btn, index)
	local store = self:GetStoreByWidgetSource(btn)
	local data = self.tabs[index + 1]

	if store and data then
		local redId = data.cfg.RedDotId or 0
		store.name = data.cfg.Name

		if redId > 0 then
			btn.redId = redId
		else
			store.redKey = "MainPage." .. data.cfg.AppId
		end
	end

	self.tabBtnList[index + 1] = btn
end

function M:OnTabListClick(btn, index)
	if self.currTabIndex == index + 1 then
		return
	end

	self.currTabIndex = index + 1

	gMainPageManager:ShowMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

function M:OnTabListLayoutSet()
	if self.layOutInit then
		return
	end

	local targetBtn = self.tabBtnList[self.currTabIndex]

	if targetBtn then
		self:AdjustBarSize(targetBtn)
		self.bindData.selectedMoveBar.gameObject:SetActive(true)

		self.bindData.selectedMoveBar.localPosition = self:GetTargetPosition(targetBtn)
	end
end

function M:UpdateSignal()
	local state = self.SIGNAL_STATE.Weak

	if gCS.NetworkManager.IsNormalConnected then
		local ping = gCS.TimeManager.DelayTime * 1000

		if ping >= 200 then
			state = self.SIGNAL_STATE.Low
		elseif ping >= 100 and ping < 200 then
			state = self.SIGNAL_STATE.Middle
		else
			state = self.SIGNAL_STATE.Strong
		end
	end

	self.bindData.signalStateCtrl = state
end

function M:UpdateTime()
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)
	local hourTime = gUIUtils:NumberTo2String(hour)
	local minTime = gUIUtils:NumberTo2String(min)
	self.bindData.time = ("%s:%s"):format(hourTime, minTime)
end

function M:GetTargetPosition(targetBtn)
	local targetPos = self.bindData.tabList.rectTransform:InverseTransformPoint(targetBtn.position)
	targetPos.y = targetPos.y - targetBtn.rectTransform.rect.height * 0.5

	return targetPos
end

function M:AdjustBarSize(targetBtn)
	self.moveBarSize.x = targetBtn.rectTransform.rect.width - 30
	self.bindData.selectedMoveBar.sizeDelta = self.moveBarSize
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
		self.layOutInit = false

		self.bindData.tabList:RefreshList()
	end
end
