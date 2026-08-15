C_PhoneAppHomePanelStore = DefClass("C_PhoneAppHomePanelStore", C_PhoneAppHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.PhoneAppHomePanelStore = C_PhoneAppHomePanelStore
local M = C_PhoneAppHomePanelStore

function M:OnAwake()
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.mainTabRect.OnRenderTab = self:CreateAction(self.OnMainRenderTab)
	self.bindData.frontTabRect.OnRenderTab = self:CreateAction(self.OnFrontRenderTab)
end

function M:OnShow(panelId, args, store)
	local isIgnorePlaySound = args and args.preLoad

	if not isIgnorePlaySound then
		gSoundMgr:PlaySoundByTid(70600299)

		self.isPlayShowSound = true
	end

	self.panelId = panelId

	if gClientUtils.IsNil(self.rootGo) then
		return
	end

	self.bindData.tabRect:ResetAllTabInstances()

	self.hasDestroy = nil

	gClientUtils.OnMainPhonePanelOpen()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
	gMessageManager:SendMessage(gEventConstants.ENABLE_CAMERA_FOLLOW, true)
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.panelRootNavArea)
	gMainPhoneUtils.SetSGUIGlobalBarVisible(false)
	self:SetShowJoystick(true)

	args = args or {}
	local showTypeField = self:GetShowTypeField()
	args[showTypeField] = args[showTypeField] or -1
	args.store = store

	self:ShowPanel(args)
end

function M:SetShowJoystick(isShow)
	if self.m_Id then
		local panelCfg = LTConfig.PanelConfig.GetConfig(self.m_Id)

		if panelCfg.isFullScreen then
			return
		end

		if isShow then
			local sortingInOrder = gCS.LuaUtils.GetSortingInOrder(self.rootGo)

			SGUI.SguiJoystick.EnableTempSorting(isShow, sortingInOrder + 10)
		else
			SGUI.SguiJoystick.EnableTempSorting(isShow, 0)
		end
	end
end

function M:ShowPanel(args)
	M.base.ShowPanel(self, args)

	if args.mainHomeType and args.mainHomeType > 0 then
		if self.bindData.mainTabRect.selectedIndex ~= 0 then
			self.bindData.mainTabRect:SelectIndexWithClose(0)
		end

		self.bindData.mainTabRect.selectedIndex = args.mainHomeType

		return
	end

	local showTypeField = self:GetShowTypeField()
	local showType = args[showTypeField] or -1
	local showIndex = showType == -1 and gClientConst.MainHomeType.MainPhone or -1

	if showIndex >= 0 then
		local exist, widget = self.bindData.mainTabRect:TryGetTabInstance(showIndex, nil)

		if exist and gClientUtils.NotNil(widget) then
			widget:SetActive(true)

			local uNavigationArea = widget.gameObject:GetComponent("UNavigationArea")

			if uNavigationArea then
				uNavigationArea.enabled = false
				uNavigationArea.enabled = true
			end

			self:OnMainRenderTab(nil, widget)
		else
			self.bindData.mainTabRect.selectedIndex = showIndex
		end
	else
		local exist, widget = self.bindData.mainTabRect:TryGetTabInstance(0, nil)

		if exist and gClientUtils.NotNil(widget) then
			widget:SetActive(false)
		end
	end
end

function M:CheckMainHomeWidgetValid()
	return not self.hasDestroy and self.currentMainStore and gClientUtils.NotNil(self.currentMainStore.rootWidget)
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_PHONE_APP_HOME_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.ON_PHONE_INPUT_FIELD_ACTIVE] = self:CreateAction("OnInputFieldActive"),
		[gEventConstants.ON_PHONE_INPUT_FIELD_DE_ACTIVE] = self:CreateAction("OnInputFieldDeActive"),
		[gEventConstants.ON_ENTER_PREVIEW_SKIN_MODE] = self:CreateAction("OnEnterPreviewSkinMode"),
		[gEventConstants.ON_EXIT_PREVIEW_SKIN_MODE] = self:CreateAction("OnExitPreviewSkinMode"),
		[gEventConstants.ON_CLOSE_MAIN_PHONE_PANEL] = self:CreateAction("OnCloseMainPhonePanel"),
		[gEventConstants.ON_CLOSE_PHONE_APP_CONFIRM_PANEL] = self:CreateAction("OnCloseConfirmPanel"),
		[gEventConstants.ON_CLOSE_PHONE_APP_CONFIRM_PANEL] = self:CreateAction("OnCloseConfirmPanel"),
		[gEventConstants.SYNC_CURRENT_SPIRIT] = self:CreateAction("OnCurrentSpiritChange"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.ON_SHOW_PHONE_MESSAGE_TIPS] = self:CreateAction("ShowMessageTips"),
		[gEventConstants.PAOKU_STATE_CHANGE] = function ()
			gClientUtils.PlayPhoneAction()
		end,
		[gEventConstants.MY_UNIT_STATE_CHANGE] = function ()
			gClientUtils.PlayPhoneAction()
		end,
		[gEventConstants.PHONE_SET_SCREEN_BTN_ACTIVE] = function (_, active)
			self.bindData.fullScreenButton:SetActive(active)
		end
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.isLogout = nil
end

function M:InitView(args)
	if gClientUtils.IsNil(self.rootGo) or gClientUtils.IsNil(self.bindData.panelAnimation) then
		return
	end

	self.bindData.messageWidget:SetActive(false)
	M.base.InitView(self, args)
	gClientUtils.InitNavAreasInChildren(self.rootWidget, self.panelId)
	self.bindData.fullScreenButton:SetActive(true)
	gCS.GuiUtils.SetPanelHideCursor(self.panelId, false)

	self.bindData.panelAnimation = self.rootGo:GetComponent("Animation")

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneAppHomePanel_open")
end

function M:OnRenderTab(index, widget)
	gClientUtils.InitNavAreasInChildren(widget, self.panelId, self.bindData.gamepadBar)
	M.base.OnRenderTab(self, index, widget)

	self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)
	self.hideMainViewCo = coroutine.start(function ()
		coroutine.wait(0.5)

		if self:CheckMainHomeWidgetValid() then
			self.currentMainStore.rootWidget:SetActive(false)
		end
	end)
end

function M:OnMainRenderTab(_, widget)
	if self.panelArgs then
		local store = gStoreManager:GetStoreGroup(widget.Store)
		self.currentMainStore = store
		self.panelArgs.panelId = self.m_Id

		store:ShowPanel(self.panelArgs)

		self.homeScreenNavArea = widget:GetComponent(typeof(SGUI.UNavigationArea))

		gClientUtils.InitNavAreasInChildren(widget, self.panelId, self.bindData.gamepadBar)
	end
end

function M:ShowFrontContent(args)
	if gClientUtils.NotNil(self.rootGo) and args then
		self.frontContentArgs = args
		self.bindData.frontTabRect.selectedIndex = args.showType
	end
end

function M:OnFrontRenderTab(_, widget)
	gClientUtils.InitNavAreasInChildren(widget, self.panelId, self.bindData.gamepadBar)

	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:ShowPanel(self.frontContentArgs)

	self.frontContentArgs = nil
end

function M:OnExecuteExitAction()
	if self.hasDestroy then
		return
	end

	local closeAnimationName = "S_Vx_PhoneAppHomePanel_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)

	self.playCloseAnimationCo = coroutine.stop(self.playCloseAnimationCo)
	self.playCloseAnimationCo = coroutine.start(function ()
		coroutine.wait(clipTime)
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnExitClick()
	if self.bindData.tabRect.selectedIndex == gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.WallPaper then
		gMessageManager:SendMessage(gEventConstants.ON_EXIT_WALL_PAPER_PREVIEW_MODE)
		self:CloseContentPanel()

		return
	end

	if gNpcChatUtils.IsChatPanelShowing() then
		local npcChatBasePanel = gNpcChatUtils.GetBasePanelStore()

		if npcChatBasePanel.closeType == gNpcChatConst.CloseButtonType.Hide then
			return
		end
	end

	self:OnExit()
end

function M:CloseContentPanel(args)
	M.base.CloseContentPanel(self)

	self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)

	if self.bindData.tabRect.selectedIndex < 0 and self:CheckMainHomeWidgetValid() then
		gClientUtils.FinishAnimation(self.currentMainStore.bindData.panelAnimation, "S_Vx_MainPhonePanel_open")
		self.currentMainStore.rootWidget:SetActive(true)

		if (not args or not args.ignoreBackToMainAnimation) and self.currentMainStore.PlayBackToMainAnimation then
			self.currentMainStore:PlayBackToMainAnimation()
		end

		if self.currentMainStore.StartIsClickCdIng then
			self.currentMainStore:StartIsClickCdIng()
		end
	end
end

function M:OnEnterPreviewSkinMode()
	self.hasEnterPreviewSkinMode = true
	self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)

	self.currentMainStore.rootWidget:SetActive(true)

	self.bindData.childNodeActive = false
end

function M:OnExitPreviewSkinMode()
	self.hasEnterPreviewSkinMode = false

	self.currentMainStore.rootWidget:SetActive(false)

	self.bindData.childNodeActive = true
end

function M:OnCloseMainPhonePanel(_, force)
	if force then
		gPanelManager:Close(self.m_Id)
	else
		self:OnExitClick()
	end
end

function M:OnCloseConfirmPanel()
	self.bindData.frontTabRect:SelectIndexWithClose(-1)
end

function M:OnCurrentSpiritChange()
	self:OnExitClick()
end

function M:OnPanelClose(_, panelId)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panelId)

	if panelCfg and panelCfg.isFullScreen then
		self.bindData.fullScreenButton:SetActive(true)

		if self.bindData.tabRect.selectedIndex >= 0 then
			return
		end

		self.checkPanelCo = coroutine.stop(self.checkPanelCo)
		local rootGo = self.rootGo
		local localPosition = self.bindData.rootWidget.transform.localPosition
		self.bindData.rootWidget.transform.localPosition = Vector3.Fetch(localPosition.x, localPosition.y, -100000)
		self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)
		self.checkPanelCo = coroutine.start(function ()
			coroutine.step()

			if gClientUtils.IsNil(rootGo) then
				return
			end

			self.bindData.rootWidget:SetActive(false)
			self.bindData.rootWidget:SetActive(true)

			self.bindData.rootWidget.transform.localPosition = Vector3.Fetch(localPosition.x, localPosition.y, 0)

			if self:CheckMainHomeWidgetValid() then
				self.currentMainStore:PlayBackToMainAnimation()
			end
		end)
	end
end

function M:OnInputFieldActive()
	self.isInputMode = true

	LX6.Manager.GameInputManager.SetDisableInput(self.panelId, false, false, true)
end

function M:OnInputFieldDeActive()
	self.isInputMode = nil

	LX6.Manager.GameInputManager.SetEnableInput(self.panelId, true, true, true)
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.FirstLevel
end

function M:ShowMessageTips(_, args)
	self.bindData.messageTips = args.text

	self.bindData.messageWidget:SetActive(true)

	self.showMessageCo = coroutine.stop(self.showMessageCo)
	self.showMessageCo = coroutine.start(function ()
		coroutine.wait(2.5)
		self.bindData.messageWidget:SetActive(false)
	end)
end

function M:ClearData()
	self.hasEnterPreviewSkinMode = nil
	self.frontContentArgs = nil
	self.isInputMode = nil
	self.hideMainViewCo = coroutine.stop(self.hideMainViewCo)
	self.homeScreenNavArea = nil

	if self.panelId then
		gCS.GuiUtils.SetPanelHideCursor(self.panelId, false)
		LX6.Manager.GameInputManager.SetEnableInput(self.panelId, true, true, true)
		gCS.GuiUtils.SetPanelHideCursor(self.panelId, false)
	end

	local _ = not self.isLogout and gSocialNetworkUtils.AskTwitterPageClose(UX.Game.CloseTwitterPanelType.PhonePanel)

	gClientUtils.OnMainPhonePanelClose()

	self.dialogMoveStatus = nil

	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
	gMessageManager:SendMessage(gEventConstants.ENABLE_CAMERA_FOLLOW, false)
	gNewGuideMgr:NotifySignal(EGuideSignal.MainPhonePanelClose)

	self.checkPanelCo = coroutine.stop(self.checkPanelCo)
	self.showMessageCo = coroutine.stop(self.showMessageCo)
	self.popUpQueue = nil

	if self.isPlayShowSound then
		gSoundMgr:PlaySoundByTid(70600334)
	end

	self.isPlayShowSound = false

	self:SetShowJoystick(false)
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.panelRootNavArea)
	gMainPhoneUtils.SetSGUIGlobalBarVisible(true)
end

function M:OnClose()
	self:ClearStoreGroupData()

	if gClientUtils.NotNil(self.bindData.tabRect) then
		self.bindData.tabRect.selectedIndex = -1

		self.bindData.tabRect:ClearUnusedTabInstances()
	end

	if gClientUtils.NotNil(self.bindData.mainTabRect) then
		local exist, widget = self.bindData.mainTabRect:TryGetTabInstance(0, nil)

		if exist and gClientUtils.NotNil(widget) then
			self.bindData.mainTabRect:SelectIndexWithClose(0)
			widget:SetActive(false)
		end
	end
end

function M:OnLogOut()
	self.isLogout = true

	if self.panelId then
		gPanelManager:Close(self.panelId)
	end
end
